
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-32-33s.jl"

md"### Snippet 4.26"

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

md"### Snippet 4.31"

m4_2s = SampleModel("heights", m4_2);

heightsdata = Dict("N" => length(df.height), "h" => df.height);

rc = stan_sample(m4_2s, data=heightsdata);

if success(rc)
	dfa = read_samples(m4_2s; output_format=:dataframe)
	q = quap(dfa)
end

Particles(dfa)

md"### snippet 4.32"

md"##### Compute covariance matrix."

cov(Array(dfa))

md"### snippet 4.33"

md"##### Compute correlation matrix."

cor(Array(dfa))

md"## End of clip-04-32-34s.jl"

