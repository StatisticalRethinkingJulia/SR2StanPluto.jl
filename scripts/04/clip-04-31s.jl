
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-31s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
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
  mu ~ normal(178, 0.1);
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

begin
	m4_2s = SampleModel("heights", m4_2);
	m4_2_data = Dict("N" => length(df.height), "h" => df.height);
	rc4_2s = stan_sample(m4_2s, data=m4_2_data);
	success(rc4_2s) && (part4_2s = read_samples(m4_2s; output_format=:particles))
end

md"## End of clip-04-31s.jl"

