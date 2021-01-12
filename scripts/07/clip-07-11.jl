
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-11s.jl"

begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
end;

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

fig7_4 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2);

for (findx, K) in enumerate([1, 6])
	fig7_4[findx] = plot(;ylims=(200,1500), leg=false)
	for i in 1:6
		df1 = sample(df, 6, replace=false)
		scale!(df1, [:mass, :brain])
		df1.brain_std = df1.brain/maximum(df1.brain)
		mass = create_observation_matrix(df1.mass_s, K)
		N = size(df1, 1)
		data = (N = N, K = K, brain = df1.brain_s, mass = mass)
		init = (a = 0.0, bA = ones(K), sigma = 2)
		q7_2s, m7_2s, o7_2s = quap("m7.2s", stan7_2; data, init)
		linkvars = [:a, :bA, :sigma]
		fnc=create_observation_matrix
		
		if !isnothing(q7_2s)
			nt7_2s = read_samples(m7_2s)
			lab="$(size(nt7_2s[Symbol(linkvars[2])], 1))-th degree polynomial"
			title="R^2 = $(r2_is_bad(nt7_2s, df1))"
			fig7_4[findx] = plot!(;lab, title)
			fig7_4[findx] = plotlines(df1, :mass, :brain, nt7_2s, linkvars, fig7_4[findx];
				stepsize=0.05, fnc, lab, title, leg=false)
		end
	end
	scatter!(fig7_4[findx], df.mass, df.brain;
		xlab="body mass [kg]", ylab="brain vol [cc]", lab="Observations")
	for (ind, species) in pairs(df.species)
		annotate!(fig7_4[findx], [(df[ind, :mass] + 1, df[ind, :brain] + 90,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
end;

md" ### Snippet 7.11"

plot(fig7_4[1], fig7_4[2])

md" ## End of clip-07-11s.jl"

