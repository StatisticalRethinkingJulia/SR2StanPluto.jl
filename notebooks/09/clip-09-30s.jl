### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9820cc3a-fe50-11ea-3fb6-991358edb7ff
using Pkg, DrWatson

# ╔═╡ 98210cc2-fe50-11ea-0fec-cfe81a89d0cb
begin
	#@quickactivate "SR2StanPluto"
	using StanSample, GLM
	using StatisticalRethinking
end

# ╔═╡ c5f141c2-fe4f-11ea-03d2-e5eb5d2349f6
md"## Clip-09-30s.jl"

# ╔═╡ 9831d8b8-fe50-11ea-38fd-c99a2b5fd0bc
md"### Snippet 6.1"

# ╔═╡ 98328740-fe50-11ea-3008-27d3dda98cd2
begin
	N = 100
	df = DataFrame(
		height = rand(Normal(10, 2), N),
		leg_prop = rand(Uniform(0.4, 0.5), N),
	)
	df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
	df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
end;

# ╔═╡ 9842396a-fe50-11ea-217d-2bba5fa44fb5
md"### Snippet 6.2"

# ╔═╡ 9842dbb8-fe50-11ea-158e-cbc2873c64bd
stan6_1 = "
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

# ╔═╡ 239f66a6-840f-11eb-3858-a3ae035d21f7
stan6_2 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
  vector[N] LR;
}
parameters {
  real a;
  real bL;
  real <lower=0> bR;
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
	m6_1s = SampleModel("m6.1s", stan6_1,
		method=StanSample.Sample(num_samples=1000))
	data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1))
	rc6_1s = stan_sample(m6_1s; data)
	if success(rc6_1s)
		post6_1s_df = read_samples(m6_1s, :dataframe)
	end
	m6_2s = SampleModel("m6.2s", stan6_2,
		method=StanSample.Sample(num_samples=1000))
	rc6_2s = stan_sample(m6_2s; data)
	
	if success(rc6_2s)
		post6_2s_df = read_samples(m6_2s, :dataframe)
	end
end;

# ╔═╡ 64b0dad4-8410-11eb-1986-815525832db2
md"
```
rethinking simulation:
> precis(m5.8s)
      mean   sd  5.5% 94.5% n_eff Rhat4
a     0.97 0.29  0.52  1.43  1034     1
bl    0.18 2.52 -3.90  4.18   532     1
br    1.81 2.53 -2.18  5.94   530     1
sigma 0.64 0.05  0.57  0.71  1100     1
> precis(m5.8s2)
       mean   sd  5.5% 94.5% n_eff Rhat4
a      0.95 0.29  0.48  1.42   479  1.02
bl    -1.13 2.06 -4.65  1.75   377  1.00
br     3.13 2.06  0.28  6.64   379  1.00
sigma  0.64 0.04  0.57  0.71   773  1.00
```
"

# ╔═╡ 81b75f90-8410-11eb-3910-396d9d0ebdeb
success(rc6_1s) && PRECIS(post6_1s_df)

# ╔═╡ 4903312c-840f-11eb-0973-a91f30c64a1a
success(rc6_2s) && PRECIS(post6_2s_df)

# ╔═╡ 6aac1dd2-840f-11eb-1e9c-6392658b0a67
if success(rc6_1s) && success(rc6_2s)
	(s2, p2) = plot_model_coef([m6_1s, m6_2s], [:a, :bL, :bR, :sigma];
		title="Multicollinearity between bL and bR, bR > 0")
	p2
end

# ╔═╡ ebb2b764-8418-11eb-06d9-53ff20d9a4bb
trankplot(m6_1s, :bL)[1]

# ╔═╡ 297c0caa-8419-11eb-2842-1d9dcab60688
trankplot(m6_2s, :bL)[1]

# ╔═╡ 9862bdb4-fe50-11ea-1402-bbac3257c25d
md"## End of clip-06-02-06s.jl"

# ╔═╡ Cell order:
# ╟─c5f141c2-fe4f-11ea-03d2-e5eb5d2349f6
# ╠═9820cc3a-fe50-11ea-3fb6-991358edb7ff
# ╠═98210cc2-fe50-11ea-0fec-cfe81a89d0cb
# ╟─9831d8b8-fe50-11ea-38fd-c99a2b5fd0bc
# ╠═98328740-fe50-11ea-3008-27d3dda98cd2
# ╟─9842396a-fe50-11ea-217d-2bba5fa44fb5
# ╠═9842dbb8-fe50-11ea-158e-cbc2873c64bd
# ╠═239f66a6-840f-11eb-3858-a3ae035d21f7
# ╠═9851b4a8-fe50-11ea-083b-17e3c182a55a
# ╟─64b0dad4-8410-11eb-1986-815525832db2
# ╠═81b75f90-8410-11eb-3910-396d9d0ebdeb
# ╠═4903312c-840f-11eb-0973-a91f30c64a1a
# ╠═6aac1dd2-840f-11eb-1e9c-6392658b0a67
# ╠═ebb2b764-8418-11eb-06d9-53ff20d9a4bb
# ╠═297c0caa-8419-11eb-2842-1d9dcab60688
# ╟─9862bdb4-fe50-11ea-1402-bbac3257c25d
