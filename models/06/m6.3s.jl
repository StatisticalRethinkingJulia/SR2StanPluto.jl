# 6.3s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])

stan6_3 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
}
parameters{
  real a;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bF * F;
  K ~ normal( mu , sigma );
}
";

# Define the SampleModel and set the output format to :mcmcchains.

begin
  m6_3s = SampleModel("m6.3", stan6_3);
  m6_3_data = Dict("N" => size(df, 1), "F" => df.perc_fat_s, "K" => df.kcal_per_g_s);
  rc6_3s = stan_sample(m6_3s, data=m6_3_data);
end

if success(rc6_3s)
  part6_3s = read_samples(m6_3s; output_format=:particles)
  part6_3s |> display
end

# End of 6.3s.jl
