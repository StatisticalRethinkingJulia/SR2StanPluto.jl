# m6.8s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

N = 100
df = DataFrame(
  :h0 => rand(Normal(10,2 ), N),
  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
);
df[!, :fungus] = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
df[!, :h1] = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]

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
"

m6_8_data = Dict(
  :N => nrow(df),
  :h0 => df[:, :h0],
  :h1 => df[:, :h1],
  :treatment => df[:, :treatment]
)

m6_8s = SampleModel("m6.8s", stan6_8)

rc6_8s = stan_sample(m6_8s; data=m6_8_data)

if success(rc6_8s)
  part6_8s = read_samples(m6_8s; output_format=:particles);
  part6_8s |> display
end

# End of m6.8s.jl
