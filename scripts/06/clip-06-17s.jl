
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "06", "m6.7s.jl"))

md"## Clip-06-17s.jl"

begin
	N = 100
	df = DataFrame(
	  :h0 => rand(Normal(10,2 ), N),
	  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df.fungus = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df.h1 = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
end;

m6_8 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
}
parameters{
  real a;
  real bt;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

begin
	m6_8s = SampleModel("m6.8s", m6_8)
	m6_8_data = Dict(:N => nrow(df), :h0 => df.h0, :h1 => df.h1, :treatment => df.treatment)
	rc6_8s = stan_sample(m6_8s; data=m6_8_data)
	if success(rc6_8s)
		dfa6_8s = read_samples(m6_8s; output_format=:dataframe)
		p6_8s = Particles(dfa6_8s)
	end
end

success(rc6_8s) && (Text(precis(dfa6_8s; io=String)))

if success(rc6_8s)
	(s1, p1) = plotcoef([m6_7s, m6_8s], [:a, :bt, :bf])
	p1
end

success(rc6_8s) && s1

md"## End of clip-06-17s.jl"

