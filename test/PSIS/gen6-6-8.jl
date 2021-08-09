using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking
end

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

begin
    m6_6_data = Dict(
      :N => nrow(df),
      :h0 => df[:, :h0],
      :h1 => df[:, :h1]
    )
    m6_6s = SampleModel("m6.6s", stan6_6)
    rc6_6s = stan_sample(m6_6s; data)
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

begin
    m6_7s = SampleModel("m6.7s", stan6_7)
    rc6_7s = stan_sample(m6_7s; data)
end

if success(rc6_7s)
    waic(m6_7s)
end

if success(rc6_7s)
    post6_7s_df = read_samples(m6_7s, :dataframe)
    b6_7s = post6_7s_df[:, [:a, :bt, :bf, :sigma]]
    p6_7s = b6_7s.a .+ b6_7s.bt * df.treatment' + b6_7s.bf * df.fungus'
    mu6_7s = p6_7s .* df.h0'
    log_lik = logpdf.(Normal.(mu6_7s, post6_7s_df.sigma),  df.h1')
    waic(log_lik)
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

begin
    m6_8s = SampleModel("m6.8s", stan6_8)
    rc6_8s = stan_sample(m6_8s; data)
end

# ╔═╡ 425a70dc-6bb3-11eb-1a7e-39f3133b7173
if success(rc6_6s) && success(rc6_7s) && success(rc6_8s)
    df_waic = compare([m6_6s, m6_7s, m6_8s], :waic)
end

# ╔═╡ 904b7004-6d69-11eb-07fe-65b5bb8c4dd2
if success(rc6_6s) && success(rc6_7s) && success(rc6_8s)
    df_psis = compare([m6_6s, m6_7s, m6_8s], :psis)
end

# ╔═╡ ee0899d8-68e1-11eb-2679-e304ef15e9e4
begin
    loo6_7s, loos6_7s, pk6_7s = psisloo(m6_7s)
    pk_plot(pk6_7s)
end
