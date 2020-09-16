### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 4cac375e-f206-11ea-2d9a-ffcfad9dd8d1
using Pkg, DrWatson

# ╔═╡ 5629f3f2-f206-11ea-3549-57a35939b10d
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ b8fd857a-f206-11ea-1271-fbc8487b17dc
md"## Intro-stan-02.jl"

# ╔═╡ aa1296ea-f206-11ea-225c-156cb017cef6
md"###### Re-execute relevant parts of intro_stan/intro-stan-01.jl"

# ╔═╡ 007b3eec-f207-11ea-3331-fd0db71ffe96
begin
	m1_1 = "
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
	}"
	sm = SampleModel("m1.1s", m1_1)     # Define Stan language mdeol
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	m1_1_data = Dict("N" => N, "n" => n, "k" => k)
	rc = stan_sample(sm, data=m1_1_data)
end;

# ╔═╡ 5654e97c-f206-11ea-024a-112a500adf2e
if success(rc)

  # Allocate array of 4 Normal fits

  fits = Vector{Normal{Float64}}(undef, 4);

  # Fit a normal distribution to each chain.

  dfsa = read_samples(sm; output_format=:dataframes)

  for i in 1:4
    fits[i] = fit_mle(Normal, dfsa[i][:, :theta])
   end

  # Plot the 4 chain densities and mle estimates

  p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
  x = 0:0.001:1
  for i in 1:4
    μ = round(fits[i].μ, digits=2)
    σ = round(fits[i].σ, digits=2)
    p[i] = density(dfsa[i][:, :theta], lab="Chain $i density",
       xlim=(0.0, 1.0), title="$(N) data points", leg=:topleft)
   plot!(p[i], x, pdf.(Normal(fits[i].μ, fits[i].σ), x), lab="Fitted Normal($μ, $σ)")
  end
  plot(p..., layout=(2, 2))
  
end

# ╔═╡ 5661e96a-f206-11ea-2e9b-8fbcf856371c
md"## End of intro-stan/intro-stan-02.jl"

# ╔═╡ Cell order:
# ╟─b8fd857a-f206-11ea-1271-fbc8487b17dc
# ╠═4cac375e-f206-11ea-2d9a-ffcfad9dd8d1
# ╠═5629f3f2-f206-11ea-3549-57a35939b10d
# ╟─aa1296ea-f206-11ea-225c-156cb017cef6
# ╠═007b3eec-f207-11ea-3331-fd0db71ffe96
# ╠═5654e97c-f206-11ea-024a-112a500adf2e
# ╟─5661e96a-f206-11ea-2e9b-8fbcf856371c
