# m5.4.RSs.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
scale!(df, [:R, :S])

# Define the Stan language model

m5_4_RS = "
data {
  int N;
  vector[N] R;
  vector[N] S;
}
parameters {
  real a;
  real bRS;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bRS * S;
  a ~ normal( 0 , 0.2 );
  bRS ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  R ~ normal( mu , sigma );
}
";

# Define the SampleModel
m5_4_RS = SampleModel("m5.4", m5_4_RS);

# Input data

m5_4_data = Dict(
  "N" => size(df, 1), 
  "R" => df[:, :R_s],
  "S" => df[:, :S_s] 
);

# Sample using cmdstan

rc = stan_sample(m5_4_RS, data=m5_4_data);

if success(rc)

  # Describe the draws

  dfs_RS = read_samples(m5_4_RS; output_format=:dataframe)

  p_RS = Particles(dfs_RS)
  q_RS = quap(dfs_RS)

  p_RS |> display

end
