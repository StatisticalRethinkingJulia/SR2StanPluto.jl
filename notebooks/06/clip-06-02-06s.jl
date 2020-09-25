### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 9820cc3a-fe50-11ea-3fb6-991358edb7ff
using Pkg, DrWatson

# ╔═╡ 98210cc2-fe50-11ea-0fec-cfe81a89d0cb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ c5f141c2-fe4f-11ea-03d2-e5eb5d2349f6
md"## Clip-06-02-06s.jl"

# ╔═╡ 982197d4-fe50-11ea-18d9-21f65525f829
N = 100

# ╔═╡ 9831d8b8-fe50-11ea-38fd-c99a2b5fd0bc
md"### Snippet 6.1"

# ╔═╡ 98328740-fe50-11ea-3008-27d3dda98cd2
begin
	df = DataFrame(
		height = rand(Normal(10, 2), N),
		leg_prop = rand(Uniform(0.4, 0.5), N),
	)
	df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
	df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
end

# ╔═╡ 9842396a-fe50-11ea-217d-2bba5fa44fb5
md"### Snippet 6.2"

# ╔═╡ 9842dbb8-fe50-11ea-158e-cbc2873c64bd
m6_1 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
  vector[N] LR;
}
parameters {
  real a;
  real bL;
  real bR;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + bL * LL + bR * LR;
  a ~ normal(10, 100);
  bL ~ normal(2, 10);
  bR ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

# ╔═╡ 9851b4a8-fe50-11ea-083b-17e3c182a55a
begin
	m6_1s = SampleModel("m6.1s", m6_1, method=StanSample.Sample(num_samples=1000))
	m_6_1_data = Dict(
	  :H => df[:, :height],
	  :LL => df[:, :leg_left],
	  :LR => df[:, :leg_right],
	  :N => size(df, 1)
	)
	rc = stan_sample(m6_1s, data=m_6_1_data)
	success(rc) && (p = read_samples(m6_1s, output_format=:particles))
end

# ╔═╡ eb921ad4-fe50-11ea-2450-7dfe19847755
if success(rc)
	(s0, p0) = plotcoef([m6_1s], [:a, :bL, :bR, :sigma], "", "Multicollinearity between bL and bR", quap)
	plot(p0)
end

# ╔═╡ 985265b0-fe50-11ea-0594-05ac311d2e87
if success(rc)
	dfa = read_samples(m6_1s, output_format=:dataframe)

	# Fit a linear regression

	m = lm(@formula(bL ~ bR), dfa)

	# estimated coefficients from the model

	coefs = coef(m)

	p1 = plot(xlabel="bR", ylabel="bL", lab="bL ~ bR")
	plot!(p1, dfa[:, :bR], dfa[:, :bL])
	p2 = density(p.bR.particles + p.bL.particles, xlabel="sum of bL and bR",
		ylabel="Density", lab="bL + bR")
	plot(p1, p2, layout=(1, 2))
end

# ╔═╡ 9862bdb4-fe50-11ea-1402-bbac3257c25d
md"## End of clip-06-02-06s.jl"

# ╔═╡ Cell order:
# ╟─c5f141c2-fe4f-11ea-03d2-e5eb5d2349f6
# ╠═9820cc3a-fe50-11ea-3fb6-991358edb7ff
# ╠═98210cc2-fe50-11ea-0fec-cfe81a89d0cb
# ╠═982197d4-fe50-11ea-18d9-21f65525f829
# ╟─9831d8b8-fe50-11ea-38fd-c99a2b5fd0bc
# ╠═98328740-fe50-11ea-3008-27d3dda98cd2
# ╟─9842396a-fe50-11ea-217d-2bba5fa44fb5
# ╠═9842dbb8-fe50-11ea-158e-cbc2873c64bd
# ╠═9851b4a8-fe50-11ea-083b-17e3c182a55a
# ╠═eb921ad4-fe50-11ea-2450-7dfe19847755
# ╠═985265b0-fe50-11ea-0594-05ac311d2e87
# ╟─9862bdb4-fe50-11ea-1402-bbac3257c25d
