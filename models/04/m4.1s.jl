# Model m4.1s.jl

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StanOptimize
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

m4_1s = SampleModel("m4_1s", stan4_1)
data = Dict("N" => length(df.height), "height" => df.height)
rc4_1s = stan_sample(m4_1s; data)

if success(rc4_1s)
  chns4_1s = read_samples(m4_1s; output_format=:mcmcchains)
  chns4_1s |> display
  
  q4_1s = quap(m4_1s);                 # Stan QuapModel
  quap4_1s_df = sample(q4_1s)          # DataFrame with samples
  precis(quap4_1s_df)

  init = Dict(
    :mu => mode(quap4_1s_df.mu),
    :sigma => mode(quap4_1s_df.sigma))
  m4_1_opt_s = OptimizeModel("m4_1s_opt", stan4_1)
  rc4_1_opt_s = stan_optimize(m4_1_opt_s; data, init)
  if success(rc4_1_opt_s)
    optim, _ = read_optimize(m4_1_opt_s)
    optim |> display
  end
  q4_1s = quap(m4_1s, m4_1_opt_s);     # StanOptimize QuapModel
  quap4_1s_df = sample(q4_1s)          # DataFrame with samples
  precis(quap4_1s_df)
end

# End of m4.1s.jl