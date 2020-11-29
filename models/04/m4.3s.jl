# Model m4.3as.jl

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
    #df.weight_c = df.weight .- mean_weight
end;

stan4_3 = "
data {
  int<lower=1> N;
  vector[N] weight;
  vector[N] height;
}
parameters {
  real a;
  real<lower=0> b;
  real<lower=0, upper=50> sigma;
}
model {
  // Define mu as a vector.
  vector[N] mu;

  // Priors for mu and sigma
  sigma ~ uniform(0 , 50);
  a ~ normal($(mean_weight), 20);
  b ~ lognormal(0, 1);

  // Observed heights
  for (i in 1:N) {
    mu[i] = a + b * (weight[i] - $(mean_weight));
  }
  height ~ normal(mu, sigma);
}
";

m4_3s = SampleModel("m4.3s", stan4_3)
m4_3_data = Dict(:N => nrow(df),
  :weight => df.weight, :height => df.height)
rc4_3s = stan_sample(m4_3s, data=m4_3_data)

if success(rc4_3s)
  q4_3s = quap(m4_3s);                 # Stan QuapModel
  quap4_3s_df = sample(q4_3s)          # DataFrame with quap samples
  precis(m4_3s)
  precis(quap4_3s_df)
end

# End of m4.3as.jl