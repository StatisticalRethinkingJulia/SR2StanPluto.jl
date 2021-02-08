### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6140b174-68bf-11eb-2500-67f70009d849
using Pkg, DrWatson

# ╔═╡ 68139624-68bf-11eb-2ade-713114053494
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 4b1f9aec-68bf-11eb-09a4-935d0416a746
md" ## Clip-07-25s.jl"

# ╔═╡ 8d952a1a-68c0-11eb-3d73-8f2305902dba
begin
	N = 100
	df = DataFrame(
		:h0 => rand(Normal(10, 2 ), N),
  		:treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	)
	df[!, :fungus] =
		[rand(Binomial.(1, 0.5 .- 0.4 .* df.treatment[i]), 1)[1] for i in 1:N]
	df[!, :h1] = 
		[df[i, :h0] + rand(Normal(5 - 3 * df.fungus[i]), 1)[1] for i in 1:N]
end;

# ╔═╡ 34079ef0-68c1-11eb-24f5-afa32aad15d5
PRECIS(df)

# ╔═╡ 8177cc20-68bf-11eb-2f03-17eb658f83f3
stan6_6 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
}
parameters{
  real<lower=0> p;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  p ~ lognormal(0, 0.25);
  sigma ~ exponential(1);
  mu = h0 * p;
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 2922931a-68c3-11eb-1a6f-a3c43b5b2285
begin
	m6_6_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1]
	)
	m6_6s = SampleModel("m6.6s", stan6_6)
	rc6_6s = stan_sample(m6_6s; data=m6_6_data)

	if success(rc6_6s)
		post6_6s_df = read_samples(m6_6s; output_format=:dataframe)
		PRECIS(post6_6s_df)
	end
end

# ╔═╡ c3085a1a-68bf-11eb-30f6-19e77995194c
begin
    b6_6s = reshape(post6_6s_df.p, size(post6_6s_df, 1), 1)
    mu6_6s = b6_6s * df.h0'
	lp6_6s = logpdf.(Normal.(mu6_6s, post6_6s_df.sigma),  df.h1')
	waic_m6_6s = waic(lp6_6s)
end

# ╔═╡ a4f64b12-68c5-11eb-3fa4-0fdfb4064bd8
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

# ╔═╡ cf5d33c0-68c5-11eb-2e91-bbd775911e90
begin
	m6_7_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1],
	  :fungus => df[:, :fungus],
	  :treatment => df[:, :treatment]
	)
	m6_7s = SampleModel("m6.7", stan6_7)
	rc6_7s = stan_sample(m6_7s; data=m6_7_data)
	if success(rc6_7s)
  		post6_7s_df = read_samples(m6_7s; output_format=:dataframe);
  		PRECIS(post6_7s_df)
	end
end

# ╔═╡ c2c26490-68c6-11eb-1309-8bdaf4116fd3
begin
	b6_7s = post6_7s_df[:, [:a, :bt, :bf, :sigma]]
	p6_7s = b6_7s.a .+ b6_7s.bt * df.treatment' + b6_7s.bf * df.fungus'
	mu6_7s = p6_7s .* df.h0'
	lp6_7s = logpdf.(Normal.(mu6_7s, post6_7s_df.sigma),  df.h1')
	waic_m6_7s = waic(lp6_7s)
end

# ╔═╡ 1d33c052-68ce-11eb-1939-3b34b9b6d0ce
stan6_8 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
}
parameters{
  real a;
  real bt;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 4f77eba6-68ce-11eb-23be-53c00ef45087
begin
	m6_8_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1],
	  :treatment => df[:, :treatment]
	)

	m6_8s = SampleModel("m6.8s", stan6_8)

	rc6_8s = stan_sample(m6_8s; data=m6_8_data)

	if success(rc6_8s)
	  post6_8s_df = read_samples(m6_8s; output_format=:dataframe);
	  PRECIS(post6_8s_df)
	end
end

# ╔═╡ 62a9da40-68ce-11eb-1d2f-6bcfc0c26dc8
begin
	b6_8s = post6_8s_df[:, [:a, :bt, :sigma]]
	p6_8s = b6_8s.a .+ b6_8s.bt * df.treatment'
	mu6_8s = p6_8s .* df.h0'
	lp6_8s = logpdf.(Normal.(mu6_8s, post6_8s_df.sigma),  df.h1')
	waic_m6_8s = waic(lp6_8s)
end

# ╔═╡ 995d3b9a-68ce-11eb-2863-fd75886fcf0e
[waic_m6_7s, waic_m6_8s, waic_m6_6s]

# ╔═╡ 011f4688-68cf-11eb-213b-d9ef1bd7b07e
begin
	loo6_6s, _, pk6_6s = psisloo(lp6_6s)
	loo6_7s, _, pk6_7s = psisloo(lp6_7s)
	loo6_8s, _, pk6_8s = psisloo(lp6_8s)
	[-2loo6_7s, -2loo6_8s, -2loo6_6s]
end

# ╔═╡ d8937562-68d1-11eb-2cab-3311829fe027
waic_m6_7s_pw = waic(lp6_7s;pointwise=true).WAIC;

# ╔═╡ 3a99f54a-68d2-11eb-177c-a99c3107579f
waic_m6_8s_pw = waic(lp6_8s;pointwise=true).WAIC;

# ╔═╡ 41b5ca16-68d2-11eb-0414-392c52fd023e
diff_m6_7s_m6_8s = waic_m6_7s_pw .- waic_m6_8s_pw

# ╔═╡ 93e99452-68d2-11eb-2077-c578fdb7f120
√(length(waic_m6_7s_pw) * var(diff_m6_7s_m6_8s))

# ╔═╡ d13ca9f2-68e1-11eb-07fa-dd6010508941
pk_plot(pk6_7s)

# ╔═╡ ee0899d8-68e1-11eb-2679-e304ef15e9e4
pk_plot(pk6_6s)

# ╔═╡ Cell order:
# ╟─4b1f9aec-68bf-11eb-09a4-935d0416a746
# ╠═6140b174-68bf-11eb-2500-67f70009d849
# ╠═68139624-68bf-11eb-2ade-713114053494
# ╠═8d952a1a-68c0-11eb-3d73-8f2305902dba
# ╠═34079ef0-68c1-11eb-24f5-afa32aad15d5
# ╠═8177cc20-68bf-11eb-2f03-17eb658f83f3
# ╠═2922931a-68c3-11eb-1a6f-a3c43b5b2285
# ╠═c3085a1a-68bf-11eb-30f6-19e77995194c
# ╠═a4f64b12-68c5-11eb-3fa4-0fdfb4064bd8
# ╠═cf5d33c0-68c5-11eb-2e91-bbd775911e90
# ╠═c2c26490-68c6-11eb-1309-8bdaf4116fd3
# ╠═1d33c052-68ce-11eb-1939-3b34b9b6d0ce
# ╠═4f77eba6-68ce-11eb-23be-53c00ef45087
# ╠═62a9da40-68ce-11eb-1d2f-6bcfc0c26dc8
# ╠═995d3b9a-68ce-11eb-2863-fd75886fcf0e
# ╠═011f4688-68cf-11eb-213b-d9ef1bd7b07e
# ╠═d8937562-68d1-11eb-2cab-3311829fe027
# ╠═3a99f54a-68d2-11eb-177c-a99c3107579f
# ╠═41b5ca16-68d2-11eb-0414-392c52fd023e
# ╠═93e99452-68d2-11eb-2077-c578fdb7f120
# ╠═d13ca9f2-68e1-11eb-07fa-dd6010508941
# ╠═ee0899d8-68e1-11eb-2679-e304ef15e9e4
