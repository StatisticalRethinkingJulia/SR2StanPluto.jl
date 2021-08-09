# m5.4.AMs.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);

df = DataFrame(
  :A => df[:, :MedianAgeMarriage],
  :M => df[:, :Marriage],
  :D => df[:, :Divorce]
 )

scale!(df, [:M, :A, :D])

# Define the Stan language model

stan5_4_AM = "
data {
  int N;
  vector[N] A;
  vector[N] M;
}
parameters {
  real a;
  real bAM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bAM * M;
  a ~ normal( 0 , 0.2 );
  bAM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  A ~ normal( mu , sigma );
}
";

# Define the SampleModel
#tmpdir=ProjDir*"/tmp"
m5_4_AMs = SampleModel("m5.4.AM", stan5_4_AM);

# Input data

m5_4_data = Dict(
  "N" => size(df, 1), 
  "M" => df[:, :M_s],
  "A" => df[:, :A_s] 
);

# Sample using cmdstan

rc5_4_AMs = stan_sample(m5_4_AMs, data=m5_4_data);

if success(rc5_4_AMs)

  part5_4_AMs = read_samples(m5_4_AMs, :particles)
  part5_4_AMs |> display

end

# End of m5.3.AMs.jl