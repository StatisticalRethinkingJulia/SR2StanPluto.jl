
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Stan-optimize.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

m4_2 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

m4_2s = OptimizeModel("heights", m4_2);

m4_2_data = Dict("N" => length(df.height), "h" => df.height);

m4_2_init = Dict("mu" => 174.0, "sigma" => 5.0)

rc = stan_optimize(m4_2s; data=m4_2_data, init=m4_2_init);

if success(rc)
  optim_stan, cnames = read_optimize(m4_2s)
  optim_stan
end

md"## End of Stan optimize intro"

