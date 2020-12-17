### A Pluto.jl notebook ###
# v0.12.17

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
PRECIS(df2)

# ╔═╡ 4231d58a-fb4e-11ea-13fb-334f25a29dfc
md"### Snippet 4.24"

# ╔═╡ 423cb2f2-fb4e-11ea-1d8e-13f34d558440
md"##### Generate approximate probabilities."

# ╔═╡ cc303db6-3fd3-11eb-0c79-113cf154577f
flat_gridpoints(grids) = vec(collect(Iterators.product(grids...)))

# ╔═╡ 424c95e6-fb4e-11ea-207a-a58e1c37bcb8
begin
	df3 = sample(df2, 20, replace=true)

	mu_list = range(150, 160, length=100)
	sigma_list = range(4, 20, length=100)
	prior_mu = Normal(178.0, 20.0)
	prior_sigma = Uniform(0, 50)

 	post_df = DataFrame()
	the_grid = flat_gridpoints([mu_list, sigma_list])

	# Compute the log(likelihood * prior)

	for i in 1:length(the_grid)
	    d1 = Normal(the_grid[i][1], the_grid[i][2])
	    ll = sum(logpdf.(d1, df3.height))
		the_prod = ll + pdf(prior_mu, the_grid[i][1]) + pdf(prior_sigma, the_grid[i][2])
	    append!(post_df, DataFrame(mu=the_grid[i][1], sigma=the_grid[i][2],
	    	ll=ll, prod=the_prod))
	end

	# Make it a probability

	post_df.prob = exp.(post_df.prod .- maximum(post_df.prod))
	
	#	   mu     sigma     LL      prod
	#1  150.0000     4 -115.1337 -123.9404
	#2  150.1005     4 -114.2501 -123.0497
	#3  150.2010     4 -113.3790 -122.1717
	#4  150.3015     4 -112.5206 -121.3063
	#5  150.4020     4 -111.6748 -120.4536

	PRECIS(post_df)
end

# ╔═╡ 09d079d0-3fdc-11eb-3807-d14185b5ff8f
first(post_df, 5)

# ╔═╡ 426542bc-fb4e-11ea-077c-e909400c772e
md"### Snippet 4.25"

# ╔═╡ 426cb358-fb4e-11ea-1c1c-2783f97b46f4
md"##### Density of sigma."

# ╔═╡ 427ae8f6-fb4e-11ea-0fa1-5f187ce01ac6
begin
	samples = post_df[sample(1:size(post_df, 1), Weights(post_df.prob), 4000; replace=true), :]
	density(samples.sigma,
		xlab="sigma",
		ylab="density",
		lab="Posterior sigma",
		xlim = (3, 15)
	)
	density!(rand(Normal(mean(samples.sigma), std(samples.sigma)), 10000), lab="Normal comparison")
end

# ╔═╡ 427c0f92-fb4e-11ea-3cc8-774ea42fee82
md"# End of clip-04-23-25s.jl"

# ╔═╡ Cell order:
# ╟─a23ecd30-fb4d-11ea-2488-83b06a27c605
# ╠═421653aa-fb4e-11ea-058d-e5fe009d9ddb
# ╠═42169d10-fb4e-11ea-3e62-99de72017d1f
# ╠═42172f66-fb4e-11ea-390e-d7c302051f54
# ╠═948012ac-fb4e-11ea-2a2d-13c73ac5d3c0
# ╟─4231d58a-fb4e-11ea-13fb-334f25a29dfc
# ╟─423cb2f2-fb4e-11ea-1d8e-13f34d558440
# ╠═cc303db6-3fd3-11eb-0c79-113cf154577f
# ╠═424c95e6-fb4e-11ea-207a-a58e1c37bcb8
# ╠═09d079d0-3fdc-11eb-3807-d14185b5ff8f
# ╟─426542bc-fb4e-11ea-077c-e909400c772e
# ╟─426cb358-fb4e-11ea-1c1c-2783f97b46f4
# ╠═427ae8f6-fb4e-11ea-0fa1-5f187ce01ac6
# ╟─427c0f92-fb4e-11ea-3cc8-774ea42fee82
