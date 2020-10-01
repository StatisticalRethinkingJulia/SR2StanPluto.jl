# m5.2s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])

# Define the Stan language model

m5_2 = "
data {
  int N;
  vector[N] divorce_s;
  vector[N] marriage_s;
}
parameters {
  real a;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bM * marriage_s;
  a ~ normal( 0 , 0.2 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  divorce_s ~ normal( mu , sigma );
}
";

# Define the SampleModel
m5_2s = SampleModel("m5.2", m5_2);

# Input data

m5_2_data = Dict(
  "N" => size(df, 1), 
  "divorce_s" => df[:, :Divorce_s],
  "marriage_s" => df[:, :Marriage_s] 
);

# Sample using cmdstan

rc5_2s = stan_sample(m5_2s, data=m5_2_data);

if success(rc5_2s)

  # Describe the draws

  dfa5_2s = read_samples(m5_2s; output_format=:dataframe)

  # Result rethinking

  rethinking = "
          mean   sd  5.5% 94.5%
    a     0.00 0.11 -0.17  0.17
    bM    0.35 0.13  0.15  0.55
    sigma 0.91 0.09  0.77  1.05
  "

  part5_2s = Particles(dfa5_2s)
  part5_2s |> display
  
end

# End m5.2s.jl