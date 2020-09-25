
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-22-23s.jl"

begin
	df = sim_happiness()
	df.mid = df.married .+ 1
	
	# or `df = filter(row -> row[:age] > 17, df)`

	df = df[df.age .> 17, :]
	df.A = (df.age .- 18) / (65 - 18)
	Text(precis(df; io=String))
end

m6_9 = "
data {
  int <lower=1> N;
  vector[N] happiness;
  vector[N] A;
  int <lower=1>  k;
  int mid[N];
}
parameters {
  real <lower=0> sigma;
  vector[k] a;
  real bA;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  bA ~ normal(0, 2);
  for (i in 1:N) {
    mu[i] = a[mid[i]] + bA * A[i];
  }
  happiness ~ normal(mu, sigma);
}
";

begin
	m6_9s = SampleModel("m6.9s", m6_9)
	m6_9_data = Dict(:N => nrow(df), :k => 2, :happiness => df.happiness, :A => df.A, :mid => df.mid)
	rc6_9s = stan_sample(m6_9s, data=m6_9_data)
	success(rc6_9s) && (p6_9s = read_samples(m6_9s, output_format=:particles))
end

if success(rc6_9s)
  dfa6_9s = read_samples(m6_9s, output_format=:dataframe)
  Text(precis(dfa6_9s; io=String))
end

md"## End of clip-06-22-23s.jl"

