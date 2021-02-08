
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md" ## Clip-07-25s.jl"

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

PRECIS(df)

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

begin
    b6_6s = reshape(post6_6s_df.p, size(post6_6s_df, 1), 1)
    mu6_6s = b6_6s * df.h0'
	lp6_6s = logpdf.(Normal.(mu6_6s, post6_6s_df.sigma),  df.h1')
	waic_m6_6s = waic(lp6_6s)
end

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

begin
	b6_7s = post6_7s_df[:, [:a, :bt, :bf, :sigma]]
	p6_7s = b6_7s.a .+ b6_7s.bt * df.treatment' + b6_7s.bf * df.fungus'
	mu6_7s = p6_7s .* df.h0'
	lp6_7s = logpdf.(Normal.(mu6_7s, post6_7s_df.sigma),  df.h1')
	waic_m6_7s = waic(lp6_7s)
end

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

begin
	b6_8s = post6_8s_df[:, [:a, :bt, :sigma]]
	p6_8s = b6_8s.a .+ b6_8s.bt * df.treatment'
	mu6_8s = p6_8s .* df.h0'
	lp6_8s = logpdf.(Normal.(mu6_8s, post6_8s_df.sigma),  df.h1')
	waic_m6_8s = waic(lp6_8s)
end

[waic_m6_7s, waic_m6_8s, waic_m6_6s]

begin
	loo6_6s, _, pk6_6s = psisloo(lp6_6s)
	loo6_7s, _, pk6_7s = psisloo(lp6_7s)
	loo6_8s, _, pk6_8s = psisloo(lp6_8s)
	[-2loo6_7s, -2loo6_8s, -2loo6_6s]
end

waic_m6_7s_pw = waic(lp6_7s;pointwise=true).WAIC;

waic_m6_8s_pw = waic(lp6_8s;pointwise=true).WAIC;

diff_m6_7s_m6_8s = waic_m6_7s_pw .- waic_m6_8s_pw

√(length(waic_m6_7s_pw) * var(diff_m6_7s_m6_8s))

pk_plot(pk6_7s)

pk_plot(pk6_6s)

