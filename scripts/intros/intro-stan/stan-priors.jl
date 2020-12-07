
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
  using StanOptimize
	using StatisticalRethinking
end

md"## stan-priors.jl"

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

begin
	m4_2s = SampleModel("p4_2s", m4_2)
	prior4_2_data = Dict("N" => 0, "h" => [])
	rc4_2s = stan_sample(m4_2s; data=prior4_2_data)
end

if success(rc4_2s)
  priors4_2s = read_samples(m4_2s; output_format=:dataframe)
  PRECIS(priors4_2s)
end

md"## End of stan-priors.jl"

