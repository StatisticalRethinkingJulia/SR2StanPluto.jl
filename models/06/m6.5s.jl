# m6.5s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])

m6_5 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
  vector[N] L;
}
parameters{
  real a;
  real bL;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bL ~ normal( 0 , 0.5 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bL * L + bF * F;
  K ~ normal( mu , sigma );
}
";

# Define the SampleModel and set the output format to :mcmcchains.

m6_5s = SampleModel("m6.5s", m6_5);

# Input data for cmdstan

m6_5_data = Dict("N" => size(df, 1), "L" => df[:, :perc_lactose_s],
    "F" => df[:, :perc_fat_s], "K" => df[!, :kcal_per_g_s]);

# Sample using StanSample

rc6_5s = stan_sample(m6_5s, data=m6_5_data);

if success(rc6_5s)
  dfa6_5s = read_samples(m6_5s; output_format=:dataframe)
  part6_5s = Particles(dfa6_5s)
end

# End of m6.5s.jl
