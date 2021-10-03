### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg, DrWatson

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-13-14s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass, :brain])
	df.brain_std = df.brain/maximum(df.brain)
end;

# ╔═╡ 290d19ae-59cf-11eb-1636-772efccc7cb9
df

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

# ╔═╡ 5710f362-5a99-11eb-1282-ad61ea6dde7e
md"
!!! note

	Below results need to be further studied. By manipulating `sigma` the overall results have a similar trend as in the book, but I'm not sure I trust this approach.
"

# ╔═╡ 9457b384-5a97-11eb-3a64-39599bd271a5
sig = 0.1

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
	vector[K] b;                  // K slope(s)
	real log_sigma;
}

transformed parameters {
    vector[N] mu;
    mu = a + mass * b;
}

model {
	a ~ normal(0.5, 1);        
	b ~ normal(0, 10);
	brain ~ normal(mu , $(sig));
}
generated quantities {
	vector[N] log_lik;
	real sigma;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(brain[i] | mu[i], $(sig));
	sigma = $(sig);
}
";

# ╔═╡ e1bd7ef2-5a98-11eb-19a8-f32fcb3d7fb6
sig6 = 0.001

# ╔═╡ f2898fe6-5a98-11eb-10f0-db1c4fe19bff
stan7_6 = "
data {
	 int < lower = 1 > N; 			// Sample size
	 int < lower = 1 > K;			// Degree of polynomial
	 vector[N] brain; 				// Outcome
	 matrix[N, K] mass; 			// Predictor
}

parameters {
	real a;                        // Intercept
	vector[K] b;                  // K slope(s)
	real log_sigma;
}

transformed parameters {
    vector[N] mu;
    mu = a + mass * b;
}

model {
	a ~ normal(0.5, 1);        
	b ~ normal(0, 10);
	brain ~ normal(mu , $(sig6));
}
generated quantities {
	vector[N] log_lik;
	real sigma;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(brain[i] | mu[i], $(sig6));
	sigma = $(sig6);
}
";

# ╔═╡ f59ecd72-60ab-11eb-2fe2-c3f7159e2080
begin
	loo = Vector{Float64}(undef, 6)
	loos = Vector{Vector{Float64}}(undef, 6)
	pk = Vector{Vector{Float64}}(undef, 6)
	deviance = Vector{Float64}(undef, 6)
end;

# ╔═╡ 95cbb456-520e-11eb-2e0a-1d173ddc9dec
begin
	tmpdir = joinpath(projectdir(), "tmp")
	lppd_res = Matrix{Float64}(undef, 6, 7)

	for K in 1:6
		N = size(df, 1)
		mass = create_observation_matrix(df.mass_s, K)
		data = (N = N, K = K, brain = df.brain_std, mass = mass)
		
		# `sigma` should really be `exp(log_sigma)`!
		
		if K < 6
			m7_2s = SampleModel("m7.2s", stan7_2; tmpdir)
		else
			m7_2s = SampleModel("m7.2s", stan7_6; tmpdir)
		end
		rc7_2s = stan_sample(m7_2s; data=data)

		if success(rc7_2s)
			nt7_2s = read_samples(m7_2s, :namedtuple)
			post7_2s_df = read_samples(m7_2s, :dataframe)
		end

		log_lik = nt7_2s.log_lik'
		lppd_res[K, :] = lppd(log_lik)
		loo[K], loos[K], pk[K] = psisloo(log_lik)
		
		lp = logprob(post7_2s_df, mass, df.brain_std, K)
		deviance[K] = -2sum(lppd(lp))
	end
	deviance
end

# ╔═╡ 58eaed70-6809-11eb-192f-2b1edb51a17e
-deviance/2

# ╔═╡ 1ab3e174-59e0-11eb-3db8-4d91bc007f0a
lppd_res'

# ╔═╡ 6441d73c-666b-11eb-2fa8-a920bcbf2380
sum(lppd_res', dims=1)

# ╔═╡ 946d5e90-5fe5-11eb-1ec8-ed64a60550e3
md"
!!! note

	Take a look at these runs using `psisloo()` from PSIS.jl. This is explained later in chapter 7.
"

# ╔═╡ ef3da47a-60ac-11eb-39b9-f3fe46d314d5
loo

# ╔═╡ 19541136-5fe5-11eb-00a2-db4ef2435713
sum.(loos)

# ╔═╡ 1ed9cb28-5fe5-11eb-0e3e-29e68eb14885
pk_qualify(pk[1])

# ╔═╡ 3ae2831e-5fe5-11eb-24ec-d36a56204b4e
pk_plot(pk[1]; title="PSIS diagnostic plot (K = 1)")

# ╔═╡ 5246f7ba-5f7f-11eb-2a0b-b77c47d6bdcc
begin
	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6)
	for i in 1:6
		fig[i] = pk_plot(pk[i], title="K = $i", leg=false)
	end
	plot(fig..., layout=(3,2))
end

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-13-14s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╠═290d19ae-59cf-11eb-1636-772efccc7cb9
# ╠═24328f84-541d-11eb-0ec3-4df5b8a8cb19
# ╟─5710f362-5a99-11eb-1282-ad61ea6dde7e
# ╠═9457b384-5a97-11eb-3a64-39599bd271a5
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═e1bd7ef2-5a98-11eb-19a8-f32fcb3d7fb6
# ╠═f2898fe6-5a98-11eb-10f0-db1c4fe19bff
# ╠═f59ecd72-60ab-11eb-2fe2-c3f7159e2080
# ╠═95cbb456-520e-11eb-2e0a-1d173ddc9dec
# ╠═58eaed70-6809-11eb-192f-2b1edb51a17e
# ╠═1ab3e174-59e0-11eb-3db8-4d91bc007f0a
# ╠═6441d73c-666b-11eb-2fa8-a920bcbf2380
# ╟─946d5e90-5fe5-11eb-1ec8-ed64a60550e3
# ╠═ef3da47a-60ac-11eb-39b9-f3fe46d314d5
# ╠═19541136-5fe5-11eb-00a2-db4ef2435713
# ╠═1ed9cb28-5fe5-11eb-0e3e-29e68eb14885
# ╠═3ae2831e-5fe5-11eb-24ec-d36a56204b4e
# ╠═5246f7ba-5f7f-11eb-2a0b-b77c47d6bdcc
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
