# m5.4.SRs.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);

# Define the Stan language model

m5_4_SR = "
data {
  int N;
  vector[N] R;
  vector[N] S;
}
parameters {
  real a;
  real bSR;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bSR * R;
  a ~ normal( 0 , 0.2 );
  bSR ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  S ~ normal( mu , sigma );
}
";

# Define the SampleModel
m5_4_SRs = SampleModel("m5.4", m5_4_SR);

# Input data

m5_4_data = Dict(
  "N" => size(df, 1), 
  "R" => df[:, :R_s],
  "S" => df[:, :S_s] 
);

# Sample using cmdstan

rc = stan_sample(m5_4_SRs, data=m5_4_data);

if success(rc)

  # Describe the draws

  dfs_SR = read_samples(m5_4_SRs; output_format=:dataframe)

  p_SR = Particles(dfs_SR)
  q_SR = quap(dfs_SR)

  p_RS |> display

end
