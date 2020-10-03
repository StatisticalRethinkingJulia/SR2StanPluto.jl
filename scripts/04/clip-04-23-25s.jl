
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Clip-04-23-25s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df2 = filter(row -> row[:age] >= 18, df);
end;

Text(precis(df2; io=String))

md"### Snippet 4.23"

md"##### Sample 20 random heights."

begin
	n = size(df2, 1)
	selected_ind = sample(1:n, 20, replace=false);
	df3 = df2[selected_ind, :];
end;

md"### Snippet 4.24"

md"##### Generate approximate probabilities."

begin
	mu_list_1 = repeat(range(150, 170, length=200), 200);
	sigma_list_1 = repeat(range(4, 20, length=200), inner=200);
end;

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
	    ll = sum(log.(pdf.(d1, obs)))
	    append!(df, DataFrame(mu=grid[i][1], sigma=grid[i][2],
	    	ll=ll))
		append!(the_prod, ll + log.(pdf.(prior_x, grid[i][1])) + 
			log.(pdf.(prior_y, grid[i][2])))
	end

	# Make it a probability

	df.prob = exp.(the_prod .- maximum(the_prod))
	df
end

begin
	mu_list = range(150, 160, length=100)
	sigma_list = range(7, 9, length=100)
	prior_mu = Normal(178.0, 20.0)
	prior_sigma = Uniform(0, 50)

	post_df = grid_prob(mu_list, sigma_list, prior_mu, prior_sigma,
		df3[:, :height])
	Text(precis(post_df; io=String))
end

md"##### Sample post."

samples = post_df[sample(1:size(post_df, 1), Weights(post_df.prob), 
	10000, replace=true), :];

md"### Snippet 4.25"

md"##### Density of sigma."

density(samples[:, :sigma],
	xlab="sigma",
	ylab="density",
	lab="posterior sigma (only 20 obs)"
)

md"# End of clip-04-23-25s.jl"

