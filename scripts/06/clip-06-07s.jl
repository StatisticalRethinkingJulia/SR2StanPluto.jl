
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-07s.jl"


begin
	N = 100
	df = DataFrame(
	  height = rand(Normal(10, 2), N),
	  leg_prop = rand(Uniform(0.4, 0.5), N),
	)
	df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
	df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
end;

Text(precis(df; io=String))

md"### Snippet 6.2"

m6_2 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
}

parameters {
  real a;
  real bL;
  real <lower=0> sigma;
}

model {
  vector[N] mu;
  mu = a + bL * LL;
  a ~ normal(10, 100);
  bL ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

begin
	m6_2s = SampleModel("m6.2s", m6_2)
	m6_2_data = Dict(:H => df.height, :LL => df.leg_left, :N => size(df, 1))
	rc6_2s = stan_sample(m6_2s, data=m6_2_data)
	success(rc6_2s) && (part6_2s = read_samples(m6_2s, output_format=:particles))
end

success(rc6_2s) && (chns6_2s = read_samples(m6_2s, output_format=:mcmcchains))

success(rc6_2s) && plot(chns6_2s; seriestype=:traceplot)

success(rc6_2s) && plot(chns6_2s; seriestype=:density)

md"## End of clip-06-07s.jl"

