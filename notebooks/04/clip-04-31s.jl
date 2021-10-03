### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 056ddfe6-fb70-11ea-3e6a-1143958b1f94
using Pkg, DrWatson

# ╔═╡ 056e12ae-fb70-11ea-2e74-23b6879ea8a5
begin
	using Distributions
	using StanSample, StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using PlutoUI
end

# ╔═╡ 9e05e2ea-fb6f-11ea-34e8-47c0458afa15
md"## Clip-04-31s.jl"

# ╔═╡ 056e751e-fb70-11ea-0d8c-0f392d4231ac
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 0579eaa2-fb70-11ea-1646-095d244514f3
stan4_2 = "
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

# ╔═╡ 845f528a-3ff4-11eb-3208-eb3fbb9022f2
md"## Snippet 4.31"

# ╔═╡ 057a5a8a-fb70-11ea-087f-7f1562f46764
begin
	data = Dict(:N => length(df.height), :h => df.height)
	init = Dict(:mu => 180.0, :sigma => 50.0)
	q4_2s, m4_2s, _ = stan_quap("m4.2s", stan4_2; data, init)
	if !isnothing(m4_2s)
		post4_2s_df = read_samples(m4_2s, :dataframe)
		part4_2s = read_samples(m4_2s, :particles)
	end
end

# ╔═╡ 32553622-3ff5-11eb-1c77-d764df9673ed
if !isnothing(q4_2s)
	quap4_2s_df = sample(q4_2s)
	PRECIS(quap4_2s_df)
end

# ╔═╡ 56dddfda-3ff5-11eb-35a5-ad21c023fbb5
PRECIS(post4_2s_df)

# ╔═╡ 89ffb2af-ad2f-4ab3-867c-d43315d3e7d0
read_samples(m4_2s).data

# ╔═╡ 058373e2-fb70-11ea-2fbe-634f17946677
md"## End of clip-04-31s.jl"

# ╔═╡ Cell order:
# ╟─9e05e2ea-fb6f-11ea-34e8-47c0458afa15
# ╠═056ddfe6-fb70-11ea-3e6a-1143958b1f94
# ╠═056e12ae-fb70-11ea-2e74-23b6879ea8a5
# ╠═056e751e-fb70-11ea-0d8c-0f392d4231ac
# ╠═0579eaa2-fb70-11ea-1646-095d244514f3
# ╟─845f528a-3ff4-11eb-3208-eb3fbb9022f2
# ╠═057a5a8a-fb70-11ea-087f-7f1562f46764
# ╠═32553622-3ff5-11eb-1c77-d764df9673ed
# ╠═56dddfda-3ff5-11eb-35a5-ad21c023fbb5
# ╠═89ffb2af-ad2f-4ab3-867c-d43315d3e7d0
# ╟─058373e2-fb70-11ea-2fbe-634f17946677
