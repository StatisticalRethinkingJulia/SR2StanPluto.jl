### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
using Pkg, DrWatson

# ╔═╡ b878f13a-0e8b-11eb-3a3d-3df3931f026e
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 766ea8e6-0e8b-11eb-15fa-477197ab5a31
md"## Stan-optimize.jl"

# ╔═╡ b88588d8-0e8b-11eb-096f-f152abbd3d1e
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
m4_2 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ b89c414e-0e8b-11eb-2056-bd70c5d493ee
m4_2s = OptimizeModel("heights", m4_2);

# ╔═╡ b8a156aa-0e8b-11eb-2928-2def67a888b7
m4_2_data = Dict("N" => length(df.height), "h" => df.height);

# ╔═╡ b8a9c81c-0e8b-11eb-022f-6b43d4acc203
m4_2_init = Dict("mu" => 174.0, "sigma" => 5.0)

# ╔═╡ b8b0700e-0e8b-11eb-10ab-57f33a0d1e7f
rc = stan_optimize(m4_2s; data=m4_2_data, init=m4_2_init);

# ╔═╡ b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
if success(rc)
  optim_stan, cnames = read_optimize(m4_2s)
  optim_stan
end

# ╔═╡ b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
md"## End of Stan optimize intro"

# ╔═╡ Cell order:
# ╟─766ea8e6-0e8b-11eb-15fa-477197ab5a31
# ╠═b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
# ╠═b878f13a-0e8b-11eb-3a3d-3df3931f026e
# ╠═b88588d8-0e8b-11eb-096f-f152abbd3d1e
# ╠═b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
# ╠═b89c414e-0e8b-11eb-2056-bd70c5d493ee
# ╠═b8a156aa-0e8b-11eb-2928-2def67a888b7
# ╠═b8a9c81c-0e8b-11eb-022f-6b43d4acc203
# ╠═b8b0700e-0e8b-11eb-10ab-57f33a0d1e7f
# ╠═b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
# ╟─b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
