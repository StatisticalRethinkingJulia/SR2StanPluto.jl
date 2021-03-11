# m5_1s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample, StanOptimize
using StatisticalRethinking

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])

stan5_1 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] D; // Outcome
 vector[N] A; // Predictor
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         //Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A;
  D ~ normal(mu , sigma);     // Likelihood
}
";

data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s)
init = (a=1.0, bA=1.0, sigma=10.0)
q5_1s, m5_1s, o5_1s = quap("m5_1s", stan5_1; data, init);

if !isnothing(m5_1s)
  part5_1s = read_samples(m5_1s; output_format=:particles)
end

if !isnothing(q5_1s)
  quap5_1s_df = sample(q5_1s)
  precis(quap5_1s_df)
end
