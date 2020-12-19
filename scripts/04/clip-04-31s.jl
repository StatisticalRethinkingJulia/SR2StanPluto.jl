
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-31s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
end;

stan4_2 = "
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

md"## Snippet 4.31"

begin
	data = Dict(:N => length(df.height), :h => df.height)
	init = Dict(:mu => 180.0, :sigma => 50.0)
	q4_2s, m4_2s, _ = quap("m4.2s", stan4_2; data, init)
	if !isnothing(m4_2s)
		post4_2s_df = read_samples(m4_2s; output_format=:dataframe)
		part4_2s = read_samples(m4_2s; output_format=:particles)
	end
end

if !isnothing(q4_2s)
	quap4_2s_df = sample(q4_2s)
	PRECIS(quap4_2s_df)
end

PRECIS(post4_2s_df)

md"## End of clip-04-31s.jl"

