
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-02-06-07s.jl"

md"### snippet 2.6"

md"##### The Stan language model."

m2_0 = "
// Inferring a Rate
data {
  int w;
  int l;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ uniform(0, 1);

  // Observed Counts
  w ~ binomial(w + l, theta);
}
";

md"##### Define the SampleMdel."

m2_0s = SampleModel("m2_0s", m2_0);

md"##### Use 9 observations as input data for stan_sample."

begin
	w = 6
	l = 3
	m2_0s_data = Dict(:w => w, :l => l);
end

md"##### Sample using stan_sample(,,,)."

rc = stan_sample(m2_0s, data=m2_0s_data);

md"### snippet 2.7"

if success(rc)
	x = 0.0:0.01:1.0
 	df = read_samples(m2_0s; output_format=:dataframe)
 	quapfit = quap(df)
 	density(df.theta, lab="Stan samples")
 	plot!( x, pdf.(Beta( w+1 , l+1 ) , x ), lab="Conjugate solution")
 	plot!( x, pdf.(Normal(mean(quapfit.theta), std(quapfit.theta)) , x ), lab="Stan quap solution")
end

md"## End of clip-02-06-07s.jl"

