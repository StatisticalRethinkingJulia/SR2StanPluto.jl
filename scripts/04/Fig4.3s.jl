
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig4.3s.jl"

md"### snippet 4.7"

df1 = CSV.read(sr_datadir("Howell1.csv"), DataFrame);

md"### snippet 4.8"

md"##### Show a summary of the  DataFrame."

Particles(df1)

md"### snippet 4.9"

md"##### Show some statistics."

Text(precis(df1; io=String))

md"### snippet 4.10"

df1.height

md"### snippet 4.11"

md"##### Use only adults."

begin
	df = filter(row -> row[:age] >= 18, df1);
	Particles(df)
end

md"##### Our model:"

m4_1 = "
  height ~ Normal(μ, σ) # likelihood
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
";

md"##### Plot the prior densities."

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6);

md"### snippet 4.12"

md"##### μ prior."

begin
	d1 = Normal(178, 20)
	p[1] = plot(-300:600, [pdf(d1, μ) for μ in -300:600],
		xlab="mu",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="mu ~ Normal( 178, 20)")
end

md"### snippet 4.13"

md"##### Show σ  prior."

begin
	d2 = Uniform(0, 50)
	p[3] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
		xlab="sigma",
		ylab="density",
		leg=false,
		title="sigma ~ Uniform( 0, 50)")
end

md"### snippet 4.14"

begin
	sample_mu_20 = rand(d1, 10000)
	sample_sigma = rand(d2, 10000)

	d3 = Normal(178, 100)
	sample_mu_100 = rand(d3, 10000)

	d3 = Normal(178, 100)
	p[2] = plot(-300:600, [pdf(d3, μ) for μ in -300:600],
		xlab="mu",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="mu ~ Normal( 178, 100)")


	p[4] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
		xlab="sigma",
		ylab="density",
		leg=false,
		title="sigma ~ Uniform( 0, 50)")

	prior_height_20 = [rand(Normal(sample_mu_20[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	p[5] = density(prior_height_20,
		xlab="height",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="h ~ Normal(mu, sigma)")


	prior_height_100 = [rand(Normal(sample_mu_100[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	p[6] = density(prior_height_100,
		xlab="height",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="h ~ Normal(mu,sigma)")

	plot(p..., layout=(3, 2))
end

md"## End of Fig4.3s.jl"

