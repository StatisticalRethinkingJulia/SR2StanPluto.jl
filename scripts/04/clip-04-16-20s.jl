
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-16-22s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df2 = filter(row -> row[:age] >= 18, df)
end;		

md"### Snippet 4.16"

md"##### Generate approximate probabilities."

function grid_prob(x, y, prior_x, prior_y, obs)

	# Create an x vs. y grid (vector of vectors), e.g.
	# 10000-element Array{Array{Float64,1},1}:
 	#	[150.0, 7.0]
 	#	[150.1010101010101, 7.0]
 	#	[150.2020202020202, 7.0]
 	#   ...

 	df = DataFrame()
	grid = reshape([ [x,y]  for x=x, y=y ], length(x)*length(y))

	# Define the priors

	d2 = Normal(178.0, 20.0)
	d3 = Uniform(0, 50)

	# Compute the log(likelihood * prior)

	the_prod = []
	for i in 1:length(grid)
	    d1 = Normal(grid[i][1], grid[i][2])
	    ll = sum(logpdf.(d1, obs))
	    append!(df, DataFrame(mu=grid[i][1], sigma=grid[i][2],
	    	ll=ll))
		append!(the_prod, ll + log.(pdf.(prior_x, grid[i][1])) + 
			log.(pdf.(prior_y, grid[i][2])))
	end

	# Make it a probability

	df[!, :prob] = exp.(the_prod .- maximum(the_prod))
	df
end

begin
	mu_list = range(150, 160, length=100)
	sigma_list = range(7, 9, length=100)
	prior_mu = Normal(178.0, 20.0)
	prior_sigma = Uniform(0, 50)
end

md"### snippet 4.17"

post_df = grid_prob(mu_list, sigma_list, prior_mu, prior_sigma,
	df2[:, :height]);

fig1 = contour(mu_list, sigma_list, post_df[:, :prob],
	xlim = (153.5, 155.7),
	ylim = (7.0, 8.5),
	xlab="height",
	ylab="sigma",
	title="Contour")

md"### snippet 4.18"

fig2 = heatmap(mu_list, sigma_list, transpose(reshape(post_df[:, :prob], 100,100)),
	xlim = (153.5, 155.7),
	ylim = (7.0, 8.5),
	xlab="height",
	ylab="sigma",
	title="Heatmap")

md"### Snippet 4.19"

md"##### Sample post_df."

begin
	samples = post_df[sample(1:size(post_df, 1), Weights(post_df[:, :prob]), 
	10000, replace=true), :]
	PRECIS(samples)
end

md"## Snippet 4.20"

scatter(samples.mu, samples.sigma, pch=".", markersize=0.3, leg=false,
	xlab="samples.mu", ylab="samples.sigma")

md"### Snippet 4.22"

md"##### Convert to an MCMCChains.Chains object."

begin
	a2d = hcat(samples[:, :mu], samples[:, :sigma])
	a3d = reshape(a2d, (size(a2d, 1), size(a2d, 2), 1))
	chn = StanSample.convert_a3d(a3d, ["mu", "sigma"], Val(:mcmcchains); start=1)
	CHNS(chn)
end

md"##### Show hpd regions."

begin
	bnds = MCMCChains.hpd(chn)
	HPD(chn)
end

md"### Snippet 4.21"

md"##### Density of mu."

begin
	fig3 = density(samples[:, :mu],
		xlab="height",
		ylab="density",
		lab="mu",
		title="posterior mu")
	vline!([bnds[:mu, :upper]], line=:dash, lab="Lower bound")
	vline!([bnds[:mu, :lower]], line=:dash, lab="Upper bound")
end;

md"##### Density of sigma."

begin
	fig4 = density(samples[:, :sigma],
		xlab="sigma",
		ylab="density",
		lab="sigma",
		title="posterior sigma")
	vline!([bnds[:sigma, :upper]], line=:dash, lab="Lower bound")
	vline!([bnds[:sigma, :lower]], line=:dash, lab="Upper bound")
end;

plot(fig1, fig2, fig3, fig4, layout=(2,2))

md"## End of clip-04-16-20s.jl"

