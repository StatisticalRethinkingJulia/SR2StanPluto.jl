# Clip-02-06-07s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# snippet 2.6

m2_0 = "
// Inferring a Rate
data {
  int w;
  int l;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ uniform(0, 1);

  // Observed Counts
  w ~ binomial(w + l, theta);
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m2_0s = SampleModel("m2_0s", m2_0);

# Use 9 observations

# Input data for cmdstan
w = 6
l = 3
m2_0s_data = Dict(:w => w, :l => l);

# Sample using cmdstan
 
rc = stan_sample(m2_0s, data=m2_0s_data);

# snippet 2.7

if success(rc)
  df = read_samples(m2_0s; output_format=:dataframe)
  quapfit = quap(df)
  density(df.theta, lab="Stan samples")
  plot!( x, pdf.(Beta( w+1 , l+1 ) , x ), lab="Conjugate solution")
  plot!( x, pdf.(Normal(mean(quapfit.theta), std(quapfit.theta)) , x ), lab="Stan quap solution")
end

# End of clip-02-06-07s.jl