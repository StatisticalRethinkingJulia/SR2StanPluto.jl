### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 056ddfe6-fb70-11ea-3e6a-1143958b1f94
using Pkg, DrWatson

# ╔═╡ 056e12ae-fb70-11ea-2e74-23b6879ea8a5
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 9e05e2ea-fb6f-11ea-34e8-47c0458afa15
md"## Clip-04-31s.jl"

# ╔═╡ 056e751e-fb70-11ea-0d8c-0f392d4231ac
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 0579eaa2-fb70-11ea-1646-095d244514f3
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
  mu ~ normal(178, 0.1);
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ 057a5a8a-fb70-11ea-087f-7f1562f46764
begin
	m4_2s = SampleModel("heights", m4_2);
	m4_2_data = Dict("N" => length(df.height), "h" => df.height);
	rc4_2s = stan_sample(m4_2s, data=m4_2_data);
	success(rc4_2s) && (quap4_2s = read_samples(m4_2s; output_format=:particles))
end

# ╔═╡ 058373e2-fb70-11ea-2fbe-634f17946677
md"## End of clip-04-31s.jl"

# ╔═╡ Cell order:
# ╟─9e05e2ea-fb6f-11ea-34e8-47c0458afa15
# ╠═056ddfe6-fb70-11ea-3e6a-1143958b1f94
# ╠═056e12ae-fb70-11ea-2e74-23b6879ea8a5
# ╠═056e751e-fb70-11ea-0d8c-0f392d4231ac
# ╠═0579eaa2-fb70-11ea-1646-095d244514f3
# ╠═057a5a8a-fb70-11ea-087f-7f1562f46764
# ╟─058373e2-fb70-11ea-2fbe-634f17946677
