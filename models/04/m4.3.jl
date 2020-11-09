# Model m4.3s.jl

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking
end

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
    mean_weight = mean(df.weight)
    df.weight_c = df.weight .- mean_weight
end;

stan4_3 = "
data {
  int<lower=1> N;
  vector[N] weight_c;
  vector[N] height;
}
parameters {
  real a;
  real log_b;
  real<lower=0> sigma;
}
model {
  // Priors for mu and sigma
  a ~ normal($(mean_weight), 20);
  log_b ~ lognormal(0, 1);
  //sigma ~ uniform(0 , 50);

  // Observed heights
  for (n in 1:N)
    height[n] ~ normal(a + exp(log_b) * weight_c[n], sigma);
}
";

m4_3s = SampleModel("m4_3s", stan4_3)
m4_3_data = Dict(:N => nrow(df),
  :weight_c => df.weight_c, :height => df.height)
rc4_3s = stan_sample(m4_3s, data=m4_3_data)

if success(rc4_3s)
  chns4_3s = read_samples(m4_3s; output_format=:mcmcchains)
  chns4_3s
  q4_3s = quap(m4_3s);                 # Stan QuapModel
  quap4_3s = Particles(q4_3s)          # Samples from a QuapModel
  quap4_3s_df = sample(q4_3s)          # DataFrame with quap samples
  precis(m4_3s)
  precis(quap4_3s_df)
end

# End of m4.3s.jl