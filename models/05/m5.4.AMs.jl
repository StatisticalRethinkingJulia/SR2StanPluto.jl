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

m_5_4_AM = "
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
m5_4_AMs = SampleModel("m5.4.AM", m_5_4_AM);

# Input data

m5_4_data = Dict(
  "N" => size(df, 1), 
  "M" => df[:, :M_s],
  "A" => df[:, :A_s] 
);

# Sample using cmdstan

rc = stan_sample(m5_4_AMs, data=m5_4_data);

if success(rc)

  # Describe the draws

  dfs_AM = read_samples(m5_4_AMs; output_format=:dataframe)

  p_AM = Particles(dfs_AM)
  q_AM = quap(dfs_AM)

  p_AM |> display

end

# End of m5.3.AMs.jl