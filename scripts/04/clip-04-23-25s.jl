
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

PRECIS(df2)

md"### Snippet 4.24"

md"##### Generate approximate probabilities."

flat_gridpoints(grids) = vec(collect(Iterators.product(grids...)))

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

first(post_df, 5)

md"### Snippet 4.25"

md"##### Density of sigma."

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

md"# End of clip-04-23-25s.jl"

