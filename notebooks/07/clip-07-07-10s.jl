### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg, DrWatson

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-07-10s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass, :brain])
	df.brain_std = df.brain/maximum(df.brain)
end;

# ╔═╡ 24328f84-541d-11eb-0ec3-4df5b8a8cb19
begin
	scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", 
		lab="Observations")
	for (ind, species) in pairs(df.species)
		annotate!([(df[ind, :mass] + 1, df[ind, :brain] + 30,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ abcc19ec-5076-11eb-1fd1-5bbc8fab188c
md" ### Snippet 7.3"

# ╔═╡ ee275e7a-5067-11eb-325b-7760b758e85e
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

# ╔═╡ 7d143ed0-551d-11eb-257f-4fa325ccd4f6
fig7_3 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6);

# ╔═╡ 95cbb456-520e-11eb-2e0a-1d173ddc9dec
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

# ╔═╡ 2389915c-51c7-11eb-15c6-4fe1fa67fbfe
md" ### Snippet 7.6"

# ╔═╡ eae3bf44-51c6-11eb-19b7-a79473f2bf36
plot(fig7_3[1])

# ╔═╡ b0a06fe8-542c-11eb-3ae1-498daebaf3f1
plot(fig7_3[3])

# ╔═╡ beb59c2c-542c-11eb-38dc-fde62793031c
plot(fig7_3[6])

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-07-10s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╠═24328f84-541d-11eb-0ec3-4df5b8a8cb19
# ╟─abcc19ec-5076-11eb-1fd1-5bbc8fab188c
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═7d143ed0-551d-11eb-257f-4fa325ccd4f6
# ╠═95cbb456-520e-11eb-2e0a-1d173ddc9dec
# ╟─2389915c-51c7-11eb-15c6-4fe1fa67fbfe
# ╠═eae3bf44-51c6-11eb-19b7-a79473f2bf36
# ╠═b0a06fe8-542c-11eb-3ae1-498daebaf3f1
# ╠═beb59c2c-542c-11eb-38dc-fde62793031c
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
