# Model m4.1s.jl

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanQuap
    using StatisticalRethinking
end

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
end;

stan4_1 = "
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
  mu ~ normal(178, 20);
  sigma ~ uniform(0 , 50);

  // Observed heights
  height ~ normal(mu, sigma);
}
";

data = (N = length(df.height), height = df.height)
init = (mu = 180.0, sigma = 10.0)
q4_1s, m4_1s, o4_1s = stan_quap("m4.1s", stan4_1; data, init);

if q4_1s.converged  
  quap4_1s_df = sample(q4_1s)          # DataFrame with samples
  precis(quap4_1s_df)
end

# End of m4.1s.jl