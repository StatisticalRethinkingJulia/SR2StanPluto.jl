# Model m2.1s

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking
end


# Define the Stan language model

stan2_1 = "
// Inferring a Rate
data {
  int N;
  int<lower=0> k[N];
  int<lower=1> n[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

# Define the SampleModel.

m2_1s = SampleModel("m2.1s", stan2_1);

# Use 16 observations

N = 15
d = Binomial(9, 0.66)
k = rand(d, N)
n = repeat([9], N)

# Input data for cmdstan

m2_1_data = Dict("N" => N, "n" => n, "k" => k);

# Sample using cmdstan
 
rc2_1s = stan_sample(m2_1s, data=m2_1_data);

# Describe the draws

if success(rc2_1s)
  part2_1s = read_samples(m2_1s; output_format=:particles)
  part2_1s |> display
end
