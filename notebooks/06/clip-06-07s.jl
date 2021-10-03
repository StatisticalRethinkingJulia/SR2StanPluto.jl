### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ b0723702-fe6d-11ea-3809-35a9826b419b
using Pkg, DrWatson

# ╔═╡ b0727334-fe6d-11ea-0e69-f563a75647df
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ e626c09e-fe6c-11ea-1ca0-63c764e7a6fd
md"## Clip-06-07s.jl"

# ╔═╡ b072ebc0-fe6d-11ea-337b-a57fbb329ea5
# Snippet 6.1

begin
	N = 100
	df = DataFrame(
	  height = rand(Normal(10, 2), N),
	  leg_prop = rand(Uniform(0.4, 0.5), N),
	)
	df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
	df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
end;

# ╔═╡ d18a9308-fe6d-11ea-3c08-3f7840232a0a
Text(precis(df; io=String))

# ╔═╡ b0813202-fe6d-11ea-2b1a-a37c2943d8dc
md"### Snippet 6.2"

# ╔═╡ b081d1a8-fe6d-11ea-0e63-cbc35b0bbdfb
m6_2 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
}

parameters {
  real a;
  real bL;
  real <lower=0> sigma;
}

model {
  vector[N] mu;
  mu = a + bL * LL;
  a ~ normal(10, 100);
  bL ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

# ╔═╡ b08c2a02-fe6d-11ea-05b2-5973a5b63804
begin
	m6_2s = SampleModel("m6.2s", m6_2)
	m6_2_data = Dict(:H => df.height, :LL => df.leg_left, :N => size(df, 1))
	rc6_2s = stan_sample(m6_2s, data=m6_2_data)
	success(rc6_2s) && (part6_2s = read_samples(m6_2s, :particles))
end

# ╔═╡ b09dac48-fe6d-11ea-3927-f5a982c7b715
if success(rc6_2s)
	chns6_2s = read_samples(m6_2s, :mcmcchains)
	CHNS(chns6_2s)
end

# ╔═╡ b0a8ce2a-fe6d-11ea-19e5-d7f5a9022680
success(rc6_2s) && plot(chns6_2s; seriestype=:traceplot)

# ╔═╡ bf05bf54-044f-11eb-1570-3b64f374127a
success(rc6_2s) && plot(chns6_2s; seriestype=:density)

# ╔═╡ b0aa516e-fe6d-11ea-33a6-e9a126093f43
md"## End of clip-06-07s.jl"

# ╔═╡ Cell order:
# ╟─e626c09e-fe6c-11ea-1ca0-63c764e7a6fd
# ╠═b0723702-fe6d-11ea-3809-35a9826b419b
# ╠═b0727334-fe6d-11ea-0e69-f563a75647df
# ╠═b072ebc0-fe6d-11ea-337b-a57fbb329ea5
# ╠═d18a9308-fe6d-11ea-3c08-3f7840232a0a
# ╟─b0813202-fe6d-11ea-2b1a-a37c2943d8dc
# ╠═b081d1a8-fe6d-11ea-0e63-cbc35b0bbdfb
# ╠═b08c2a02-fe6d-11ea-05b2-5973a5b63804
# ╠═b09dac48-fe6d-11ea-3927-f5a982c7b715
# ╠═b0a8ce2a-fe6d-11ea-19e5-d7f5a9022680
# ╠═bf05bf54-044f-11eb-1570-3b64f374127a
# ╟─b0aa516e-fe6d-11ea-33a6-e9a126093f43
