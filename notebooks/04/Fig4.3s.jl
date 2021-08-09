### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 30bfaa92-fb54-11ea-0497-e5ede2ec26a8
using Pkg, DrWatson

# ╔═╡ 30bfec6c-fb54-11ea-36f4-2df87c8ca599
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 6ad85d9c-fb53-11ea-2023-fda99c7ed78b
md"## Fig4.3s.jl"

# ╔═╡ 30c07e18-fb54-11ea-0e0d-d197d46c10ea
md"### snippet 4.7"

# ╔═╡ 30d01d9e-fb54-11ea-2603-8d6420825d4b
df1 = CSV.read(sr_datadir("Howell1.csv"), DataFrame);

# ╔═╡ 30d0b1e8-fb54-11ea-37e4-2be8da51c6f0
md"### snippet 4.8"

# ╔═╡ 30dc4738-fb54-11ea-1a62-4bb21a83b968
md"##### Show a summary of the  DataFrame."

# ╔═╡ 30dccee2-fb54-11ea-29ec-b730d1343e42
Particles(df1)

# ╔═╡ 30e84538-fb54-11ea-118f-810a0bf19fa6
md"### snippet 4.9"

# ╔═╡ 30e8e98e-fb54-11ea-397a-239a7c146dca
md"##### Show some statistics."

# ╔═╡ 30eeef00-fb54-11ea-0020-0fa3fe1aa1aa
PRECIS(df1)

# ╔═╡ 30fe8d34-fb54-11ea-1db7-2ffaf6b6a992
md"### snippet 4.10"

# ╔═╡ 30ff55a2-fb54-11ea-16e4-4f795537b146
df1.height

# ╔═╡ 310f03da-fb54-11ea-25a3-d582ae85e0c0
md"### snippet 4.11"

# ╔═╡ 3117936a-fb54-11ea-0a6b-23906e2f6693
md"##### Use only adults."

# ╔═╡ 311fec40-fb54-11ea-1fc5-997aa58921bc
begin
	df = filter(row -> row[:age] >= 18, df1);
	Particles(df)
end

# ╔═╡ 3123068c-fb54-11ea-24b1-e9b418d96ce1
md"##### Our model:"

# ╔═╡ 312d51b4-fb54-11ea-35af-f97dd6b0c5a9
m4_1 = "
  height ~ Normal(μ, σ) # likelihood
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
";

# ╔═╡ 313537a8-fb54-11ea-1f70-2b2ed579ed25
md"##### Plot the prior densities."

# ╔═╡ 313e5cfe-fb54-11ea-2503-41a91c3d10fd
figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6);

# ╔═╡ 31481f74-fb54-11ea-0042-8b398aa9bc77
md"### snippet 4.12"

# ╔═╡ 315049bc-fb54-11ea-1c6e-717ba7313659
md"##### μ prior."

# ╔═╡ 315af808-fb54-11ea-37f7-fd91181356d9
begin
	d1 = Normal(178, 20)
	figs[1] = plot(0:600, [pdf(d1, μ) for μ in 0:600],
		xlab="mu",
		ylab="density",
		xlim=(80, 250),
		leg=false,
		title="mu ~ Normal(178, 20)")
end

# ╔═╡ 3169f1a0-fb54-11ea-1307-cb6f253f9eee
md"### snippet 4.13"

# ╔═╡ 316db402-fb54-11ea-0db8-5164447d28e9
md"##### Show σ  prior."

# ╔═╡ 3177c38e-fb54-11ea-2cc1-796466f64413
begin
	d2 = Uniform(0, 50)
	figs[3] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
		xlab="sigma",
		ylab="density",
		leg=false,
		title="sigma ~ Uniform(0, 50)")
end

# ╔═╡ 3180a500-fb54-11ea-0c06-b155d6887126
md"### snippet 4.14"

# ╔═╡ 318aa148-fb54-11ea-379f-dbfe7e6f2750
begin
	sample_mu_20 = rand(d1, 10000)
	sample_sigma = rand(d2, 10000)

	d3 = Normal(178, 100)
	sample_mu_100 = rand(d3, 10000)

	d3 = Normal(178, 100)
	figs[2] = plot(-300:600, [pdf(d3, μ) for μ in -300:600],
		xlab="mu",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="mu ~ Normal(178, 100)")


	figs[4] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
		xlab="sigma",
		ylab="density",
		leg=false,
		title="sigma ~ Uniform(0, 50)")

	prior_height_20 = [rand(Normal(sample_mu_20[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	figs[5] = density(prior_height_20,
		xlab="height",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="h ~ Normal(mu, sigma)")


	prior_height_100 = [rand(Normal(sample_mu_100[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	figs[6] = density(prior_height_100,
		xlab="height",
		ylab="density",
		xlim=(-300, 600),
		leg=false,
		title="h ~ Normal(mu, sigma)")

	plot(figs..., layout=(3, 2))
end

# ╔═╡ 319508b8-fb54-11ea-235e-0394e3a884f6
md"## End of Fig4.3s.jl"

# ╔═╡ Cell order:
# ╟─6ad85d9c-fb53-11ea-2023-fda99c7ed78b
# ╠═30bfaa92-fb54-11ea-0497-e5ede2ec26a8
# ╠═30bfec6c-fb54-11ea-36f4-2df87c8ca599
# ╟─30c07e18-fb54-11ea-0e0d-d197d46c10ea
# ╠═30d01d9e-fb54-11ea-2603-8d6420825d4b
# ╟─30d0b1e8-fb54-11ea-37e4-2be8da51c6f0
# ╟─30dc4738-fb54-11ea-1a62-4bb21a83b968
# ╠═30dccee2-fb54-11ea-29ec-b730d1343e42
# ╟─30e84538-fb54-11ea-118f-810a0bf19fa6
# ╟─30e8e98e-fb54-11ea-397a-239a7c146dca
# ╠═30eeef00-fb54-11ea-0020-0fa3fe1aa1aa
# ╟─30fe8d34-fb54-11ea-1db7-2ffaf6b6a992
# ╠═30ff55a2-fb54-11ea-16e4-4f795537b146
# ╟─310f03da-fb54-11ea-25a3-d582ae85e0c0
# ╟─3117936a-fb54-11ea-0a6b-23906e2f6693
# ╠═311fec40-fb54-11ea-1fc5-997aa58921bc
# ╟─3123068c-fb54-11ea-24b1-e9b418d96ce1
# ╠═312d51b4-fb54-11ea-35af-f97dd6b0c5a9
# ╟─313537a8-fb54-11ea-1f70-2b2ed579ed25
# ╠═313e5cfe-fb54-11ea-2503-41a91c3d10fd
# ╟─31481f74-fb54-11ea-0042-8b398aa9bc77
# ╟─315049bc-fb54-11ea-1c6e-717ba7313659
# ╠═315af808-fb54-11ea-37f7-fd91181356d9
# ╟─3169f1a0-fb54-11ea-1307-cb6f253f9eee
# ╟─316db402-fb54-11ea-0db8-5164447d28e9
# ╠═3177c38e-fb54-11ea-2cc1-796466f64413
# ╟─3180a500-fb54-11ea-0c06-b155d6887126
# ╠═318aa148-fb54-11ea-379f-dbfe7e6f2750
# ╟─319508b8-fb54-11ea-235e-0394e3a884f6
