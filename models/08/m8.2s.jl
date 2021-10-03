# Load Julia packages (libraries)

using Pkg, DrWatson

#@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# Define the Stan language model

stan8_2s = "
data{
    int N;
    vector[N] y;
}
parameters{
    real mu;
    real<lower=0> sigma;
}
model{
    y ~ normal( mu , sigma );
}
";

# Define the Stanmodel.

m8_2s = SampleModel("m8.2s", stan8_2s);

# Input data for cmdstan

m8_2_data = Dict("N" => 2, "y" => [-1, 1]);
m8_2_init = Dict("mu" => 0.0, "sigma" => 1.0);

# Sample using cmdstan

rc8_2s = stan_sample(m8_2s; data=m8_2_data, init=m8_2_init);

# Describe the draws
if success(rc8_2s)
  part8_2s = read_samples(m8_2s, :particles)
  part8_2s |> display
end

# End of m8_2s
