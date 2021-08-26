### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 4cac375e-f206-11ea-2d9a-ffcfad9dd8d1
using Pkg, DrWatson

# ╔═╡ 5629f3f2-f206-11ea-3549-57a35939b10d
begin
	@quickactivate "StatisticalRethinkingStan"
	using Distributions, StanSample
	using Plots, StatsPlots
	using StatisticalRethinking
end

# ╔═╡ b8fd857a-f206-11ea-1271-fbc8487b17dc
md"## Intro-stan-02s.jl"

# ╔═╡ aa1296ea-f206-11ea-225c-156cb017cef6
md"###### Re-execute relevant parts of intro_stan/intro-stan-01.jl"

# ╔═╡ 497e79f2-ef27-40df-ab3d-17941e2bab08
stan1_1 = "
// Inferring a rate
data {
  int N;
  int<lower=1> n;
  int<lower=0> k[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}";

# ╔═╡ 007b3eec-f207-11ea-3331-fd0db71ffe96
begin
	m1_1s = SampleModel("m1.1s", stan1_1)   # Define Stan language model
	
	N = 25                             		# 25 experiments
	n = 9                               	# Each experiment has 9 tosses
	d = Binomial(9, 0.66)	              	# Binomial distribution with

	data = (
		N = N,
		k = rand(d, N),                     # Simulate 15 trial results
		n = n                               # Each experiment has 9 tosses
	)
	
	rc1_1s = stan_sample(m1_1s; data)
end;

# ╔═╡ be6e7dc0-3d8c-4187-82af-3d9758da5f68
if success(rc1_1s)
	
	x = 0:0.01:1

 	# Allocate array of 4 Normal fits

	fits = Vector{Normal{Float64}}(undef, 4);

	# Fit a normal distribution to each chain.

	chns1_1s = read_samples(m1_1s)
	chns1_1s_theta = chns1_1s(param=:theta)

	for i in 1:4
		fits[i] = fit_mle(Normal, chns1_1s_theta(chain=i))
	end

	# Plot the 4 chain densities and mle estimates

	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
	for i in 1:4
		μ = round(fits[i].μ, digits=2)
		σ = round(fits[i].σ, digits=2)
		fig[i] = density(chns1_1s_theta(chain=i), lab="Chain $i density",
			xlim=(0.0, 1.0), title="$(N) data points", leg=:topleft)
		plot!(fig[i], x, pdf.(Normal(fits[i].μ, fits[i].σ), x),
			lab="Fitted Normal($μ, $σ)")
	end
	plot(fig..., layout=(2, 2))
  
end

# ╔═╡ fb787125-a3d0-4403-94d7-02f7393a6523
CHNS(chns1_1s)

# ╔═╡ 4dc1d4fd-cd3f-4874-af98-e8ba975a5bf1
mean(chns1_1s; dims=1)

# ╔═╡ 4966c366-1f48-4bd7-b26b-2431ae7c56a8
chns1_1s(param=:theta, chain=2)

# ╔═╡ 2e7c49cf-472f-4738-9656-b368950d2ad0
chns1_1s(iteration=1:5, chain=2, param=:theta)

# ╔═╡ cb5ef4cd-ecd8-4b9d-97d3-273a05badc8a
chns1_1s(1:5, 2, :theta)

# ╔═╡ 5f479426-a4dc-449c-8200-54992c4749ff
chns1_1s[1:5, 2, 1]

# ╔═╡ 06416d64-e74c-4207-ab3c-c63c719e58b2
mean(chns1_1s(param=:theta, chain=2))

# ╔═╡ 5661e96a-f206-11ea-2e9b-8fbcf856371c
md"## End of intro-stan/intro-stan-02s.jl"

# ╔═╡ Cell order:
# ╟─b8fd857a-f206-11ea-1271-fbc8487b17dc
# ╠═4cac375e-f206-11ea-2d9a-ffcfad9dd8d1
# ╠═5629f3f2-f206-11ea-3549-57a35939b10d
# ╟─aa1296ea-f206-11ea-225c-156cb017cef6
# ╠═497e79f2-ef27-40df-ab3d-17941e2bab08
# ╠═007b3eec-f207-11ea-3331-fd0db71ffe96
# ╠═be6e7dc0-3d8c-4187-82af-3d9758da5f68
# ╠═fb787125-a3d0-4403-94d7-02f7393a6523
# ╠═4dc1d4fd-cd3f-4874-af98-e8ba975a5bf1
# ╠═4966c366-1f48-4bd7-b26b-2431ae7c56a8
# ╠═2e7c49cf-472f-4738-9656-b368950d2ad0
# ╠═cb5ef4cd-ecd8-4b9d-97d3-273a05badc8a
# ╠═5f479426-a4dc-449c-8200-54992c4749ff
# ╠═06416d64-e74c-4207-ab3c-c63c719e58b2
# ╟─5661e96a-f206-11ea-2e9b-8fbcf856371c
