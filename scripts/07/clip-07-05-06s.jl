
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-05-06s.jl"

begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass])
	df.brain_std = df.brain/maximum(df.brain)
end;

md" ### Snippet 7.3 (updated to get mu values)"

stan7_1a = "
data {
 int < lower = 1 > N; 			// Sample size
 vector[N] brain; 				// Outcome
 vector[N] mass; 				// Predictor
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real < lower = 0 > sigma;    	// Error SD
}

transformed parameters {
    vector[N] mu;
    mu = a + bA * mass;
}

model {
  a ~ normal(0.5, 1);         	//Priors
  bA ~ normal(0, 10);
  sigma ~ lognormal(0, 1);
  brain ~ normal(mu , sigma);   // Likelihood
}
";

begin
	data = (N = size(df, 1), brain = df.brain_std, mass = df.mass_s)
	init = (a = 0.0, bA = 1, sigma = 2)
	q7_1as, m7_1as, o7_1as = quap("m7.1as", stan7_1a; data, init)
end;

if !isnothing(q7_1as)
	quap7_1as_df = sample(q7_1as)
	quap7_1as = Particles(quap7_1as_df)
end

post7_1as_df = read_samples(m7_1as; output_format=:dataframe);

md" ### Snippet 7.5"

begin
	nt7_1as = read_samples(m7_1as)
	nt7_1as.mu'
end

s = mean(nt7_1as.mu, dims=2)

r = s - df.brain_std

function r2_is_bad(model::NamedTuple, df::DataFrame)
	local var2(x) = mean(x.^2) .- mean(x)^2
	s = mean(model.mu, dims=2)
	r = s - df.brain_std
	1 - var2(r) / var2(df.brain_std)
end

md" ### Snippet 7.6"

r2_is_bad(nt7_1as, df)

md" ## End of clip-07-05-06s.jl"

