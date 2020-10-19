
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-07-15s.jl"

md"### snippet 4.7"

d = CSV.read(sr_datadir("Howell1.csv"), DataFrame);

md"### snippet 4.8"

md"##### Show a summary of the  DataFrame."

Particles(d)

md"##### Compare with describe():"

describe(d, :all)

md"### snippet 4.9"

Text(precis(d; io=String))

md"### snippet 4.10"

d.height

md"### snippet 4.11"

md"##### Adults only."

begin
	df = filter(row -> row[:age] >= 18, d);
	Particles(df)
end

Text(precis(df; io=String))

md"##### Our model:"

m4_1_rethinking_1 = "
  height ~ Normal(μ, σ) # likelihood
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
";

md"##### Plot the prior densities."

figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4);

md"### snippet 4.12"

md"##### μ prior."

d1 = Normal(178, 20)

figs[1] = plot(100:250, [pdf(d1, μ) for μ in 100:250],
	xlab="mu",
	ylab="density",
	lab="Prior on mu");

md"### snippet 4.13"

md"##### Show σ  prior."

begin
	d2 = Uniform(0, 50)
	figs[2] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
		xlab="sigma",
		ylab="density",
		lab="Prior on sigma")
end;

md"### snippet 4.14."

begin
	sample_mu_20 = rand(d1, 10000)
	sample_sigma = rand(d2, 10000)

	d3 = Normal(178, 100)
	sample_mu_100 = rand(d3, 10000)

	prior_height_20 = [rand(Normal(sample_mu_20[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	figs[3] = density(prior_height_20,
		xlab="height",
		ylab="density",
		lab="Prior predictive height")
end;

begin
	prior_height_100 = [rand(Normal(sample_mu_100[i], sample_sigma[i]), 1)[1] for i in 1:10000]
	figs[4] = density(prior_height_100,
		xlab="height",
		ylab="density",
		lab="Prior predictive mu")
end;

plot(figs..., layout=(2,2))

md"##### Store in a DataFrame."

df2 = DataFrame(
	mu_20 = sample_mu_20,
	mu_100 = sample_mu_100,
	sigma=sample_sigma,
	prior_height_20=prior_height_20,
	prior_height_100=prior_height_100);

precis(df2)

md"##### On to Stan."

md"##### Recall our model:"

m4_1_rethinking = "
  # Priors
  μ ~ Normal(178,20)
  σ ~ Uniform(0, 50)

  # Likelihood of data
  height ~ Normal(μ, σ)
";

m4_1 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0> sigma_prior;
  real<lower=0,upper=250> mu;
  real<lower=0,upper=250> mu_prior;

}
model {
  // Priors for mu
  mu ~ normal(178, 20);
  mu_prior ~ normal(178, 20);

  // Priors for sigma
  sigma ~ uniform( 0 , 50 );
  sigma_prior ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

md"##### Create a StanSample SampleModel:"

m4_1s = SampleModel("heights", m4_1);

md"##### Package the data:"

m4_1_data = Dict("N" => length(df[:, :height]), "h" => df[:, :height]);

md"##### Run Stan's cmdstan:"

rc4_1s = stan_sample(m4_1s, data=m4_1_data);

md"##### Check if sampling went ok:"

md"##### Read in the samples and show a chain summary."

success(rc4_1s) && (chn4_1s = read_samples(m4_1s; output_format=:mcmcchains))

md"##### Plot the sampling trace."

plot(chn4_1s, seriestype = :traceplot)

md"##### Plot the density of posterior draws."

plot(chn4_1s, seriestype = :density)

md"## End of clip-04-07-15s.jl"

