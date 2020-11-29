# Model m4.2s.jl

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
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

m4_2s = SampleModel("m4_2s", stan4_2)
m4_2_data = Dict("N" => length(df.height), "height" => df.height)
rc4_2s = stan_sample(m4_2s, data=m4_2_data)

if success(rc4_2s)
  chns4_2s = read_samples(m4_2s; output_format=:mcmcchains)
  chns4_2s
  q4_2s = quap(m4_2s);                 # Stan QuapModel
  quap4_2s_df = sample(q4_2s)          # DataFrame with samples
end

# End of m4.2s.jl