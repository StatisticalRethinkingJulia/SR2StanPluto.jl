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
md" ## Clip-07-25-31s.jl"

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
	data = (N = nrow(df), h0 = df.h0, h1 = df.h1,
		fungus = df.fungus, treatment = df.treatment)
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
transformed parameters {
  vector[N] mu;
  for ( i in 1:N ) {
    mu[i] = h0[i] * p;
  }
}

model {
  p ~ lognormal(0, 0.25);
  sigma ~ exponential(1);
  h1 ~ normal(mu, sigma);
}
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(h1[i] | mu[i], sigma);
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
	rc6_6s = stan_sample(m6_6s; data)

	if success(rc6_6s)
		post6_6s_df = read_samples(m6_6s; output_format=:dataframe)
		PRECIS(post6_6s_df[:, [:p, :sigma]])
	end
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
transformed parameters {
  vector[N] mu;
  vector[N] p;
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
}
model {
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  h1 ~ normal(mu, sigma);
}
generated quantities {
	vector[N] log_lik;
	for ( i in 1:N )
		log_lik[i] = normal_lpdf( h1[i] | mu[i], sigma);
}
";

# ╔═╡ cf5d33c0-68c5-11eb-2e91-bbd775911e90
begin
	m6_7s = SampleModel("m6.7s", stan6_7)
	rc6_7s = stan_sample(m6_7s; data)
	if success(rc6_7s)
 		post6_7s_df = read_samples(m6_7s; output_format=:dataframe);
 		PRECIS(post6_7s_df[:, [:a, :bt, :bf, :sigma]])
	end
end

# ╔═╡ 25d6cf84-6d78-11eb-3762-6fd55275778a
if success(rc6_7s)
	waic(m6_7s)
end

# ╔═╡ 98f0030e-6d77-11eb-0e7c-f1c2fb8a8e5e
if success(rc6_7s)
	b6_7s = post6_7s_df[:, [:a, :bt, :bf, :sigma]]
	p6_7s = b6_7s.a .+ b6_7s.bt * df.treatment' + b6_7s.bf * df.fungus'
	mu6_7s = p6_7s .* df.h0'
	log_lik = logpdf.(Normal.(mu6_7s, post6_7s_df.sigma),  df.h1')
	waic(log_lik)
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
transformed parameters {
  vector[N] mu;
  vector[N] p;
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i];
    mu[i] = h0[i] * p[i];
  }
}
model {
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  sigma ~ exponential(1);
  h1 ~ normal(mu, sigma);
}
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(h1[i] | mu[i], sigma);
}
";

# ╔═╡ 4f77eba6-68ce-11eb-23be-53c00ef45087
begin
	m6_8s = SampleModel("m6.8s", stan6_8)
	rc6_8s = stan_sample(m6_8s; data)
	if success(rc6_8s)
	 	post6_8s_df = read_samples(m6_8s; output_format=:dataframe);
	 	PRECIS(post6_8s_df[:, [:a, :bt, :sigma]])
	end
end

# ╔═╡ 425a70dc-6bb3-11eb-1a7e-39f3133b7173
if success(rc6_6s) && success(rc6_7s) && success(rc6_8s)
	df_waic = compare([m6_6s, m6_7s, m6_8s], :waic)
end

# ╔═╡ 7b280f48-705f-11eb-160f-d129eaa461f4
plot_models([m6_6s, m6_7s, m6_8s], :waic)

# ╔═╡ 904b7004-6d69-11eb-07fe-65b5bb8c4dd2
if success(rc6_6s) && success(rc6_7s) && success(rc6_8s)
	df_psis = compare([m6_6s, m6_7s, m6_8s], :psis)
end

# ╔═╡ ee0899d8-68e1-11eb-2679-e304ef15e9e4
begin
	loo6_7s, loos6_7s, pk6_7s = psisloo(m6_7s)
	pk_plot(pk6_7s)
end

# ╔═╡ 2ccd2fae-6ed6-11eb-3b8f-2b2e84dc238c
md" ## End of clip-07-25-31s.jl"

# ╔═╡ Cell order:
# ╟─4b1f9aec-68bf-11eb-09a4-935d0416a746
# ╠═6140b174-68bf-11eb-2500-67f70009d849
# ╠═68139624-68bf-11eb-2ade-713114053494
# ╠═8d952a1a-68c0-11eb-3d73-8f2305902dba
# ╠═34079ef0-68c1-11eb-24f5-afa32aad15d5
# ╠═8177cc20-68bf-11eb-2f03-17eb658f83f3
# ╠═2922931a-68c3-11eb-1a6f-a3c43b5b2285
# ╠═a4f64b12-68c5-11eb-3fa4-0fdfb4064bd8
# ╠═cf5d33c0-68c5-11eb-2e91-bbd775911e90
# ╠═25d6cf84-6d78-11eb-3762-6fd55275778a
# ╠═98f0030e-6d77-11eb-0e7c-f1c2fb8a8e5e
# ╠═1d33c052-68ce-11eb-1939-3b34b9b6d0ce
# ╠═4f77eba6-68ce-11eb-23be-53c00ef45087
# ╠═425a70dc-6bb3-11eb-1a7e-39f3133b7173
# ╠═7b280f48-705f-11eb-160f-d129eaa461f4
# ╠═904b7004-6d69-11eb-07fe-65b5bb8c4dd2
# ╠═ee0899d8-68e1-11eb-2679-e304ef15e9e4
# ╟─2ccd2fae-6ed6-11eb-3b8f-2b2e84dc238c
