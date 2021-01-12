
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-07-10s.jl"

begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass, :brain])
	df.brain_std = df.brain/maximum(df.brain)
end;

begin
	scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", 
		lab="Observations")
	for (ind, species) in pairs(df.species)
		annotate!([(df[ind, :mass] + 1, df[ind, :brain] + 30,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
	plot!()
end

md" ### Snippet 7.3"

stan7_2 = "
data {
 int < lower = 1 > N; 			// Sample size
 int < lower = 1 > K;			// Degree of polynomial
 vector[N] brain; 				// Outcome
 matrix[N, K] mass; 			// Predictor
}

parameters {
 real a;                        // Intercept
 vector[K] bA;                  // K slope(s)
 real < lower = 0 > sigma;    	// Error SD
}

transformed parameters {
    vector[N] mu;
    mu = a + mass * bA;
}

model {
  a ~ normal(0.5, 1);         	//Priors
  bA ~ normal(0, 10);
  sigma ~ lognormal(0, 1);
  brain ~ normal(mu , sigma);   // Likelihood
}
";

fig7_3 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6);

for K in 1:6
	
	# Create_observation_matrix() can be found in StatisticalRethinking/src/srtools.jl
	
	mass = create_observation_matrix(df.mass_s, K)
	N = size(df, 1)
	data = (N = N, K = K, brain = df.brain_s, mass = mass)
	init = (a = 0.0, bA = ones(K), sigma = 2)
	q7_2s, m7_2s, o7_2s = quap("m7.2s", stan7_2; data, init)
	linkvars = [:a, :bA, :sigma]
	fnc=create_observation_matrix

	# R2_is_bad() can be found in StatisticalRethinking/src/srtools.jl

	if !isnothing(q7_2s)
		nt7_2s = read_samples(m7_2s)
		lab="$(size(nt7_2s[Symbol(linkvars[2])], 1))-th degree polynomial"
		title="R^2 = $(r2_is_bad(nt7_2s, df))"
		fig7_3[K] = plotbounds(df, :mass, :brain, nt7_2s, linkvars;
			stepsize=0.05, fnc, lab, title, ylims=(0,1800), leg=:topleft)
		scatter!(fig7_3[K], df.mass, df.brain;
			xlab="body mass [kg]", ylab="brain vol [cc]", lab="Observations")
		for (ind, species) in pairs(df.species)
			annotate!(fig7_3[K], [(df[ind, :mass] + 1, df[ind, :brain] + 90,
				Plots.text(df[ind, :species], 6, :red, :right))])
		end
	end
end;

md" ### Snippet 7.6"

plot(fig7_3[1])

plot(fig7_3[3])

plot(fig7_3[6])

md" ## End of clip-07-07-10s.jl"

