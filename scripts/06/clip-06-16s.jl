
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-16s.jl"

begin
	N = 100
	df = DataFrame(
		:h0 => rand(Normal(10,2 ), N),
		:treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df.fungus = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df.h1 = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
end

m6_7 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
  vector[N] fungus;
}
parameters{
  real a;
  real bt;
  real bf;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

begin
	m6_7s = SampleModel("m6.7s", m6_7)
	m6_7_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1],
	  :fungus => df[:, :fungus],
	  :treatment => df[:, :treatment]
	)
	rc6_7s = stan_sample(m6_7s; data=m6_7_data)
	success(rc6_7s) && (dfa6_7s = read_samples(m6_7s; output_format=:dataframe))
end;

success(rc6_7s) && (p = Particles(dfa6_7s))

success(rc6_7s) && (Text(precis(dfa6_7s; io=String)))

if success(rc6_7s)
	(s6_7s, p6_7s) = plotcoef([m6_7s], [:a, :bt, :bf], "", "")
	p6_7s
end

success(rc6_7s) && s6_7s

md"## End of clip-06-16s.jl"

