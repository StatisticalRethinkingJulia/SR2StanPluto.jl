
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-24s.jl"

begin
	df = sim_happiness()
	df.A = (df.age .- 18) / (65 - 18)
	Text(precis(df; io=String))
end

m6_10 = "
data {
  int <lower=1> N;
  vector[N] happiness;
  vector[N] A;
}
parameters {
  real <lower=0> sigma;
  real a;
  real bA;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  bA ~ normal(0, 2);
  mu = a + bA * A;
  happiness ~ normal(mu, sigma);
}
";

begin
	m6_10s = SampleModel("m6.10s", m6_10)
	m6_10_data = Dict(:N => nrow(df), :happiness => df.happiness, :A => df.A,)
	rc6_10s = stan_sample(m6_10s, data=m6_10_data)
	success(rc6_10s) && (p6_10s = read_samples(m6_10s, output_format=:particles))
end

if success(rc6_10s)
  dfa6_10s = read_samples(m6_10s, output_format=:dataframe)
  Text(precis(dfa6_10s; io=String))
end

begin
	p = plot(xlab="age", ylab="happiness", leg=false, title="unmarried (grey), married (blue)")
	for i in 1:nrow(df)
		if df[i, :married] == 1
			scatter!([df[i, :age]], [df[i, :happiness]], color=:darkblue)
		else
			scatter!([df[i, :age]], [df[i, :happiness]], color=:lightgrey)
		end
	end
	p
end

md"## End of clip-06-24s.jl"

