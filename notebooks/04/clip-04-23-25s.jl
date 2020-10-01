### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 421653aa-fb4e-11ea-058d-e5fe009d9ddb
using Pkg, DrWatson

# ╔═╡ 42169d10-fb4e-11ea-3e62-99de72017d1f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ a23ecd30-fb4d-11ea-2488-83b06a27c605
md"## Clip-04-23-25s.jl"

# ╔═╡ 42172f66-fb4e-11ea-390e-d7c302051f54
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df2 = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 948012ac-fb4e-11ea-2a2d-13c73ac5d3c0
Text(precis(df2; io=String))

# ╔═╡ 42262d84-fb4e-11ea-1062-7343725b142d
md"### Snippet 4.23"

# ╔═╡ 4226b72c-fb4e-11ea-29ab-8d5266cbdd37
md"##### Sample 20 random heights."

# ╔═╡ 42315646-fb4e-11ea-3ebd-bff0b0c3fc7f
begin
	n = size(df2, 1)
	selected_ind = sample(1:n, 20, replace=false);
	df3 = df2[selected_ind, :];
end;

# ╔═╡ 4231d58a-fb4e-11ea-13fb-334f25a29dfc
md"### Snippet 4.24"

# ╔═╡ 423cb2f2-fb4e-11ea-1d8e-13f34d558440
md"##### Generate approximate probabilities."

# ╔═╡ 423d4938-fb4e-11ea-2cd2-77f2ed237c3a
begin
	mu_list_1 = repeat(range(150, 170, length=200), 200);
	sigma_list_1 = repeat(range(4, 20, length=200), inner=200);
end;

# ╔═╡ 424ac14e-fb4e-11ea-0098-81d7c95323f5
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

# ╔═╡ 424c95e6-fb4e-11ea-207a-a58e1c37bcb8
begin
	mu_list = range(150, 160, length=100)
	sigma_list = range(7, 9, length=100)
	prior_mu = Normal(178.0, 20.0)
	prior_sigma = Uniform(0, 50)

	post_df = grid_prob(mu_list, sigma_list, prior_mu, prior_sigma,
		df3[:, :height])
	Text(precis(post_df; io=String))
end

# ╔═╡ 425aa7b2-fb4e-11ea-07cb-d5aa2e567741
md"##### Sample post."

# ╔═╡ 42633bc0-fb4e-11ea-3b62-57f0abb05a9b
samples = post_df[sample(1:size(post_df, 1), Weights(post_df.prob), 
	10000, replace=true), :];

# ╔═╡ 426542bc-fb4e-11ea-077c-e909400c772e
md"### Snippet 4.25"

# ╔═╡ 426cb358-fb4e-11ea-1c1c-2783f97b46f4
md"##### Density of sigma."

# ╔═╡ 427ae8f6-fb4e-11ea-0fa1-5f187ce01ac6
density(samples[:, :sigma],
	xlab="sigma",
	ylab="density",
	lab="posterior sigma (only 20 obs)"
)

# ╔═╡ 427c0f92-fb4e-11ea-3cc8-774ea42fee82
md"# End of clip-04-23-25s.jl"

# ╔═╡ Cell order:
# ╟─a23ecd30-fb4d-11ea-2488-83b06a27c605
# ╠═421653aa-fb4e-11ea-058d-e5fe009d9ddb
# ╠═42169d10-fb4e-11ea-3e62-99de72017d1f
# ╠═42172f66-fb4e-11ea-390e-d7c302051f54
# ╠═948012ac-fb4e-11ea-2a2d-13c73ac5d3c0
# ╟─42262d84-fb4e-11ea-1062-7343725b142d
# ╟─4226b72c-fb4e-11ea-29ab-8d5266cbdd37
# ╠═42315646-fb4e-11ea-3ebd-bff0b0c3fc7f
# ╟─4231d58a-fb4e-11ea-13fb-334f25a29dfc
# ╟─423cb2f2-fb4e-11ea-1d8e-13f34d558440
# ╠═423d4938-fb4e-11ea-2cd2-77f2ed237c3a
# ╠═424ac14e-fb4e-11ea-0098-81d7c95323f5
# ╠═424c95e6-fb4e-11ea-207a-a58e1c37bcb8
# ╟─425aa7b2-fb4e-11ea-07cb-d5aa2e567741
# ╠═42633bc0-fb4e-11ea-3b62-57f0abb05a9b
# ╟─426542bc-fb4e-11ea-077c-e909400c772e
# ╟─426cb358-fb4e-11ea-1c1c-2783f97b46f4
# ╠═427ae8f6-fb4e-11ea-0fa1-5f187ce01ac6
# ╟─427c0f92-fb4e-11ea-3cc8-774ea42fee82
