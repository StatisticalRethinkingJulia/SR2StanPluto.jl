### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ d2a71096-feb7-11ea-0738-c170ec8f0f5a
using Pkg, DrWatson

# ╔═╡ d2a74dae-feb7-11ea-1c23-e7050ee80803
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 34c9c198-feb7-11ea-3b09-e5fa493d9fae
md"## Clip-06-06-09s.jl"

# ╔═╡ d2a7e3ea-feb7-11ea-1722-456d20e56b38
begin
	N = 100
	df = DataFrame(
	  :h0 => rand(Normal(10,2 ), N),
	  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df[!, :fungus] = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df[!, :h1] = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
end

# ╔═╡ d2b6d230-feb7-11ea-13de-4fc9a25244fa
stan6_7 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
  vector[N] fungus;
}
parameters{
  real a;
  real bt;
  real bf;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ d2b75bc2-feb7-11ea-1a1c-19917ffb69d4
begin
	m6_7s = SampleModel("m6.7s", stan6_7)
	m6_7_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1],
	  :fungus => df[:, :fungus],
	  :treatment => df[:, :treatment]
	)
	rc6_7s = stan_sample(m6_7s; data=m6_7_data)
	success(rc6_7s) && (post6_7s_df = read_samples(m6_7s, :dataframe))
end;

# ╔═╡ d2c2b71c-feb7-11ea-124d-6114c352b17b
success(rc6_7s) && (part6_7s = Particles(post6_7s_df))

# ╔═╡ d2c34824-feb7-11ea-3c22-f91f4df2b0f5
success(rc6_7s) && (Text(precis(post6_7s_df; io=String)))

# ╔═╡ d2cebcf4-feb7-11ea-2d6a-798f2e408ddf
if success(rc6_7s)
	(s1, p1) = plot_model_coef([m6_7s], [:a, :bt, :bf])
	p1
end

# ╔═╡ 36092dde-00ec-11eb-2149-ad44ba127c89
s1

# ╔═╡ d2cf9264-feb7-11ea-08c7-b1bf1379fa13
md"## End of clip-06-06-09s.jl"

# ╔═╡ Cell order:
# ╠═34c9c198-feb7-11ea-3b09-e5fa493d9fae
# ╠═d2a71096-feb7-11ea-0738-c170ec8f0f5a
# ╠═d2a74dae-feb7-11ea-1c23-e7050ee80803
# ╠═d2a7e3ea-feb7-11ea-1722-456d20e56b38
# ╠═d2b6d230-feb7-11ea-13de-4fc9a25244fa
# ╠═d2b75bc2-feb7-11ea-1a1c-19917ffb69d4
# ╠═d2c2b71c-feb7-11ea-124d-6114c352b17b
# ╠═d2c34824-feb7-11ea-3c22-f91f4df2b0f5
# ╠═d2cebcf4-feb7-11ea-2d6a-798f2e408ddf
# ╠═36092dde-00ec-11eb-2149-ad44ba127c89
# ╟─d2cf9264-feb7-11ea-08c7-b1bf1379fa13
