# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# Define the Stan language model

stan8_4s = "
data{
  int N;
  vector[N] y;
}
parameters{
  real sigma;
  real alpha;
  real a1;
  real a2;
}
model{
  real mu;
  mu = a1 + a2;
  y ~ normal( mu , sigma );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m8_4s = SampleModel("m8.4s", stan8_4s);

# Input data for cmdstan

m8_4_data = Dict("N" => 100, "y" => rand(Normal(0, 1), 100));

# Sample using cmdstan

rc8_4s = stan_sample(m8_4s, data=m8_4_data);
  
rethinking = "
        mean   sd  5.5% 94.5% n_eff Rhat
alpha 0.06 1.90 -2.22  2.49  1321    1
sigma 2.15 2.32  0.70  5.21   461    1
";

# Describe the draws

if success(rc)
  part8_4s = read_samples(m8_4s, :particles)
  part8_4s |> display
end