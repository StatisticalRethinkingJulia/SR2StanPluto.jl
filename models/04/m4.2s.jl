# Model m4.2s.jl

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample, StanOptimize
    using StatisticalRethinking
end

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
end;

stan4_2 = "
data {
  int N;
  real<lower=0> height[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 0.1);
  sigma ~ uniform(0 , 50);

  // Observed heights
  height ~ normal(mu, sigma);
}
";

data = (N = length(df.height), height = df.height)
init = (mu = 180.0, sigma = 10.0)
q4_2s, m4_2s, o4_2s = quap("m4.2s", stan4_2; data, init);

if !isnothing(m4_2s)
  part4_2s = read_samples(m4_2s; output_format=:particles)
end

if q4_2s.converged  
  quap4_2s_df = sample(q4_2s)          # DataFrame with samples
  Particles(quap4_2s_df)
end

if !isnothing(o4_2s)
  read_optimize(o4_2s)
end

# End of m4.2s.jl