### A Pluto.jl notebook ###
# v0.11.13

using Markdown
using InteractiveUtils

# ╔═╡ 113eb996-f20b-11ea-297f-95379839995f
using Pkg, DrWatson

# ╔═╡ 113efaf8-f20b-11ea-343f-b39e12c4d457
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

# ╔═╡ c705c7c4-f209-11ea-3651-a72bfc0f1756
md"## Intro-stan-03.jl"

# ╔═╡ 113f96ac-f20b-11ea-36c1-9b9b901c7af9
md"##### Define the Stan language model and input data"

# ╔═╡ 114947f6-f20b-11ea-0ea5-0dfa3ef8191f
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
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	m1_1_data = Dict("N" => N, "n" => n, "k" => k)
end;

# ╔═╡ 620e650e-f20b-11ea-1157-a3b90612c017
md"##### Create an OptimizeModel"

# ╔═╡ 114a04d4-f20b-11ea-0c10-e5c266f4ea8d
sm = OptimizeModel("m1.1s", m1_1);

# ╔═╡ 1153163c-f20b-11ea-3632-5beebd6994b8
rc = stan_optimize(sm, data=m1_1_data);

# ╔═╡ 115537b2-f20b-11ea-030c-478dea20fdbe
md"##### Describe the optimize result"

# ╔═╡ 11602dea-f20b-11ea-1243-fd37bbd57993
if success(rc)
  optim_stan, cnames = read_optimize(sm)
  optim_stan
end

# ╔═╡ 1160f5d8-f20b-11ea-317b-012bdf4d331f
md"## End of intro/intro-stan-03.jl"

# ╔═╡ Cell order:
# ╟─c705c7c4-f209-11ea-3651-a72bfc0f1756
# ╠═113eb996-f20b-11ea-297f-95379839995f
# ╠═113efaf8-f20b-11ea-343f-b39e12c4d457
# ╟─113f96ac-f20b-11ea-36c1-9b9b901c7af9
# ╠═114947f6-f20b-11ea-0ea5-0dfa3ef8191f
# ╟─620e650e-f20b-11ea-1157-a3b90612c017
# ╠═114a04d4-f20b-11ea-0c10-e5c266f4ea8d
# ╠═1153163c-f20b-11ea-3632-5beebd6994b8
# ╟─115537b2-f20b-11ea-030c-478dea20fdbe
# ╠═11602dea-f20b-11ea-1243-fd37bbd57993
# ╟─1160f5d8-f20b-11ea-317b-012bdf4d331f
