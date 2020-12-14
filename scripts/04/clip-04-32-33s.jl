
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-32-33s.jl"

md"### Snippet 4.26"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
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
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

md"### Snippet 4.31"

begin
	m4_2_data = Dict(:N => length(df.height), :h => df.height)
	m4_2_init = Dict(:mu => 180.0, :sigma => 10.0)
	q4_2s, m4_2s, om = quap("m4.2s", stan4_2; data=m4_2_data, init=m4_2_init)
end;

if !isnothing(m4_2s)
	post4_2s_df = read_samples(m4_2s; output_format=:dataframe)
	PRECIS(post4_2s_df)
end

if !isnothing(q4_2s)
	quap4_2s_df = sample(q4_2s)
	PRECIS(quap4_2s_df)
end

md"### snippet 4.32"

md"##### Computed covariance matrix by quap()."

q4_2s.vcov

diag(q4_2s.vcov) .|> sqrt

md"##### Use Particles."

 part_sim = Particles(4000, MvNormal([mean(quap4_2s_df.mu), mean(quap4_2s_df.sigma)], q4_2s.vcov))

begin
	fig1 = plot(part_sim[1], lab="mu")
	fig2 = plot(part_sim[2], lab="sigma")
	plot(fig1, fig2, layout=(1, 2))
end

md"### snippet 4.33"

md"##### Compute correlation matrix."

cor(Array(sample(q4_2s)))

md"## End of clip-04-32-34s.jl"

