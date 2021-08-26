### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg, DrWatson

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ 05d45c8f-0500-4142-8dae-b6208127fe6f
#include(joinpath(sr_path(), "require", "stan", "optimize.jl"))

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-11s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei,
		:rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
end;

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

# ╔═╡ bc44cdc8-5422-11eb-0034-93d8626c23f7
fig7_4 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2);

# ╔═╡ 919ade48-5a83-11eb-2fd5-75d756d4f4d6
md"
!!! tip
	In this case `fnc` creates a polynomial mass matrix.

	This could also be a more complicated function.
"

# ╔═╡ b3fc5ef8-2309-465d-873f-05690bcad3cf
methods(quap)

# ╔═╡ a9980819-c0eb-49dc-9b07-aef79409b87c
methods(quap)

# ╔═╡ 95cbb456-520e-11eb-2e0a-1d173ddc9dec
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
		q7_2s, m7_2s, o7_2s = stan_quap("m7.2s", stan7_2; data, init)
		linkvars = [:a, :bA, :sigma]
		fnc=create_observation_matrix
		
		if !isnothing(q7_2s)
			nt7_2s = read_samples(m7_2s, :namedtuple)
			lab="$(size(nt7_2s[Symbol(linkvars[2])], 1))-th degree polynomial"
			title="R^2 = $(r2_is_bad(nt7_2s, df1))"
			fig7_4[findx] = plot!(;lab, title)
			fig7_4[findx] = plotlines(df1, :mass, :brain, nt7_2s,
				linkvars, fig7_4[findx];
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

# ╔═╡ 2389915c-51c7-11eb-15c6-4fe1fa67fbfe
md" ### Snippet 7.11"

# ╔═╡ eae3bf44-51c6-11eb-19b7-a79473f2bf36
plot(fig7_4[1], fig7_4[2])

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-11s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═bc44cdc8-5422-11eb-0034-93d8626c23f7
# ╟─919ade48-5a83-11eb-2fd5-75d756d4f4d6
# ╠═b3fc5ef8-2309-465d-873f-05690bcad3cf
# ╠═05d45c8f-0500-4142-8dae-b6208127fe6f
# ╠═a9980819-c0eb-49dc-9b07-aef79409b87c
# ╠═95cbb456-520e-11eb-2e0a-1d173ddc9dec
# ╟─2389915c-51c7-11eb-15c6-4fe1fa67fbfe
# ╠═eae3bf44-51c6-11eb-19b7-a79473f2bf36
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
