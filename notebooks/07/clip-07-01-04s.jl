### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg, DrWatson

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize, GLM
	using StatisticalRethinking
end

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-01-04s.jl"

# ╔═╡ d6b75816-5066-11eb-1cc3-4367cdcd36ef
md" ### Snippet 7.1"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	
	# Snippet 7.2
	
	scale!(df, [:brain, :mass])
end

# ╔═╡ 92f3db9e-5053-11eb-0b61-3d8e0bce57ec
begin
	fig7_2 = scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", leg=false)
	for (ind, species) in pairs(df.species)
		annotate!(fig7_2, [(df[ind, :mass] + 0.8, df[ind, :brain] + 25, Plots.text(df[ind, :species],
			6, :red, :right))])
	end
	plot(fig7_2)
end

# ╔═╡ abcc19ec-5076-11eb-1fd1-5bbc8fab188c
md" ### Snippet 7.3"

# ╔═╡ ee275e7a-5067-11eb-325b-7760b758e85e
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

# ╔═╡ 72cdb516-5068-11eb-386c-7d52a078d56f
begin
	data = (N = size(df, 1), brain = df.brain_s, mass = df.mass_s)
	init = (a = 0.0, bA = 1, sigma = 2)
	q7_1s, m7_1s, o7_1s = quap("m7.1s", stan7_1; data, init)
end;

# ╔═╡ 084d9bcc-506b-11eb-3246-75bd606e5c6a
if !isnothing(q7_1s)
	quap7_1s_df = sample(q7_1s)
	quap7_1s = Particles(quap7_1s_df)
end

# ╔═╡ 52d8eab4-506b-11eb-2bbc-0d15d9f0f1ea
begin
	x_s = -1.3:0.1:1.7
	y_s = mean(quap7_1s.a) .+ mean(quap7_1s.bA) .* x_s
	x = rescale(x_s, mean(df.mass), std(df.mass))
	y = rescale(y_s, mean(df.brain), std(df.brain))
	plot(fig7_2)
	plot!(x, y)
end

# ╔═╡ 12afed28-5077-11eb-2215-cf1923c58d03
md" ### Snippet 7.4"

# ╔═╡ 2f96fd40-506e-11eb-35d7-f39e65de85e2
m1 = lm(@formula(brain_s ~ mass_s), df)

# ╔═╡ ff6269cc-5075-11eb-03af-ef18563501d0
m2 = lm(@formula(brain ~ mass), df)

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-01-04s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╟─d6b75816-5066-11eb-1cc3-4367cdcd36ef
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╠═92f3db9e-5053-11eb-0b61-3d8e0bce57ec
# ╠═abcc19ec-5076-11eb-1fd1-5bbc8fab188c
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═72cdb516-5068-11eb-386c-7d52a078d56f
# ╠═084d9bcc-506b-11eb-3246-75bd606e5c6a
# ╠═52d8eab4-506b-11eb-2bbc-0d15d9f0f1ea
# ╟─12afed28-5077-11eb-2215-cf1923c58d03
# ╠═2f96fd40-506e-11eb-35d7-f39e65de85e2
# ╠═ff6269cc-5075-11eb-03af-ef18563501d0
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
