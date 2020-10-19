
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

m4_2s = SampleModel("m4.2s", m4_2);

m4_2_data = Dict("N" => length(df.height), "h" => df.height);

rc4_2s = stan_sample(m4_2s, data=m4_2_data);

if success(rc4_2s)
	post4_2s = read_samples(m4_2s; output_format=:dataframe)
	q4_2s = quap(m4_2s)
end;

quap4_2s = sample(q4_2s);

Text(precis(quap4_2s; io=String))

md"### snippet 4.32"

md"##### Compute covariance matrix."

q4_2s.vcov

diag(q4_2s.vcov) .|> sqrt

md"##### Use Particles."

 part_sim = Particles(4000, MvNormal([mean(quap4_2s.mu), mean(quap4_2s.sigma)], q4_2s.vcov))

begin
	fig1 = plot(part_sim[1], lab="mu")
	fig2 = plot(part_sim[2], lab="sigma")
	plot(fig1, fig2, layout=(1, 2))
end

md"### snippet 4.33"

md"##### Compute correlation matrix."

cor(Array(sample(q4_2s)))

md"## End of clip-04-32-34s.jl"

