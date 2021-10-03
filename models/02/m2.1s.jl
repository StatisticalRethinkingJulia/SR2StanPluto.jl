# Model m2.1s

using Pkg, DrWatson

begin
    using Distributions
    using StanQuap
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

# Use 16 observations
# Input data for cmdstan

N = 15
d = Binomial(9, 0.66)
k = rand(d, N)
n = repeat([9], N)
data = (N = N, n = n, k = k);
init = (theta = 0.5,);

# Sample using cmdstan
 
q2_1s, m2_1s, o2_1s = stan_quap("m2.1", stan2_1; data, init);

# Describe the draws

if !isnothing(m2_1s)
  part2_1s = read_samples(m2_1s, :particles)
end

if q2_1s.converged
  quap2_1s_df = sample(q2_1s)
  precis(quap2_1s_df)
end
