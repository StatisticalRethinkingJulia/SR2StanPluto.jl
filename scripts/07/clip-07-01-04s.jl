
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-01-04s.jl"

md" ### Snippet 7.1"

begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	
	# Snippet 7.2
	
	scale!(df, [:brain, :mass])
end

begin
	fig7_2 = scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", leg=false)
	for (ind, species) in pairs(df.species)
		annotate!(fig7_2, [(df[ind, :mass] + 0.8, df[ind, :brain] + 25, Plots.text(df[ind, :species],
			6, :red, :right))])
	end
	plot(fig7_2)
end

md" ### Snippet 7.3"

stan7_1 = "
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

model {
  vector[N] mu;               	// mu is a vector
  a ~ normal(0.5, 1);         	//Priors
  bA ~ normal(0, 10);
  sigma ~ lognormal(0, 1);
  mu = a + bA * mass;
  brain ~ normal(mu , sigma);   // Likelihood
}
";

begin
	data = (N = size(df, 1), brain = df.brain_s, mass = df.mass_s)
	init = (a = 0.0, bA = 1, sigma = 2)
	q7_1s, m7_1s, o7_1s = quap("m7.1s", stan7_1; data, init)
end;

if !isnothing(q7_1s)
	quap7_1s_df = sample(q7_1s)
	quap7_1s = Particles(quap7_1s_df)
end

begin
	x_s = -1.3:0.1:1.7
	y_s = mean(quap7_1s.a) .+ mean(quap7_1s.bA) .* x_s
	x = rescale(x_s, mean(df.mass), std(df.mass))
	y = rescale(y_s, mean(df.brain), std(df.brain))
	plot(fig7_2)
	plot!(x, y)
end

md" ### Snippet 7.4"

m1 = lm(@formula(brain_s ~ mass_s), df)

m2 = lm(@formula(brain ~ mass), df)

md" ## End of clip-07-01-04s.jl"

