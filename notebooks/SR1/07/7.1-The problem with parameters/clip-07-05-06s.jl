### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	using Distributions
	using StatsPlots
	using StatsBase
	using LaTeXStrings
	using CSV
	using DataFrames
	using LinearAlgebra
	using Random
	using MonteCarloMeasurements
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using RegressionAndOtherStories

end

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-05-06s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale_df_cols!(df, [:mass])
	df.brain_std = df.brain/maximum(df.brain)
end;

# ╔═╡ abcc19ec-5076-11eb-1fd1-5bbc8fab188c
md" ### Julia code snippet 7.3 (updated to get mu values)"

# ╔═╡ ee275e7a-5067-11eb-325b-7760b758e85e
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

# ╔═╡ 72cdb516-5068-11eb-386c-7d52a078d56f
begin
	data = (N = size(df, 1), brain = df.brain_std, mass = df.mass_s)
	init = (a = 0.0, bA = 1, sigma = 2)
	q7_1as, m7_1as, o7_1as = stan_quap("m7.1as", stan7_1a; data, init)
end;

# ╔═╡ 084d9bcc-506b-11eb-3246-75bd606e5c6a
if !isnothing(q7_1as)
	quap7_1as_df = sample(q7_1as)
	quap7_1as = Particles(quap7_1as_df)
end

# ╔═╡ 5fabc9c7-937b-4d83-ab79-a7e58ae13b44
log(0.169)

# ╔═╡ 77c93e33-d7e2-4eb8-819b-e568ac1585af
PRECIS(quap7_1as_df)

# ╔═╡ 278f62e2-5079-11eb-003f-cfc6b482ea79
post7_1as_df = read_samples(m7_1as, :dataframe);

# ╔═╡ 080b72a3-5cee-43ca-b710-4a1d73bcb9ad
PRECIS(post7_1as_df)

# ╔═╡ 93d1db36-5118-11eb-3183-212c07cdf0eb
md" ### Julia code snippet 7.5"

# ╔═╡ 7d5c3db8-5110-11eb-130e-072858e16d80
begin
	nt7_1as = read_samples(m7_1as, :namedtuple)
	nt7_1as.mu'
end

# ╔═╡ cbd70d32-5111-11eb-2182-a90fe78014f3
s = mean(nt7_1as.mu, dims=2)

# ╔═╡ 0286215a-5113-11eb-1a3b-2d2e38773964
r = s - df.brain_std

# ╔═╡ bceef71c-5116-11eb-1ee7-61f648076c8a
function r2_is_bad_1(model::NamedTuple, df::DataFrame)
	local var2(x) = mean(x.^2) .- mean(x)^2
	s = mean(model.mu, dims=2)
	r = s - df.brain_std
	1 - var2(r) / var2(df.brain_std)
end

# ╔═╡ afeecdee-ee8f-443c-9f01-8a7445db15cb
function r2_is_bad_2(model::NamedTuple, df::DataFrame)
	local var2(x) = mean(x.^2) .- mean(x)^2
	s = mean(model.mu, dims=2)
	r = s - df.brain_std
	1 - var(r; corrected=false) / var(df.brain_std; corrected=false)
end

# ╔═╡ a4319250-5118-11eb-0b52-0d7c576d061c
md" ### Julia code snippet 7.6"

# ╔═╡ 34e0d218-5117-11eb-2b05-afbbee902f2d
r2_is_bad_1(nt7_1as, df)

# ╔═╡ e85278ff-8a08-4813-959b-586e35c1ae88
r2_is_bad_2(nt7_1as, df)

# ╔═╡ eec1f9a6-6d80-432e-b9df-2a014d6d0517
mu_mean=mean(nt7_1as.mu)

# ╔═╡ 2a860e88-624a-4cec-942f-9be41fcfabe1
mu_var=var(nt7_1as.mu)

# ╔═╡ 2c703d49-7017-4177-9865-ffc1efc0e71b
mu_var_nc=var(nt7_1as.mu; corrected=false)

# ╔═╡ ed1adae6-62b1-4a62-bcab-700cf41ebf25
mu_var2=StatisticalRethinking.var2(nt7_1as.mu)

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-05-06s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╟─abcc19ec-5076-11eb-1fd1-5bbc8fab188c
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═72cdb516-5068-11eb-386c-7d52a078d56f
# ╠═084d9bcc-506b-11eb-3246-75bd606e5c6a
# ╠═5fabc9c7-937b-4d83-ab79-a7e58ae13b44
# ╠═77c93e33-d7e2-4eb8-819b-e568ac1585af
# ╠═278f62e2-5079-11eb-003f-cfc6b482ea79
# ╠═080b72a3-5cee-43ca-b710-4a1d73bcb9ad
# ╟─93d1db36-5118-11eb-3183-212c07cdf0eb
# ╠═7d5c3db8-5110-11eb-130e-072858e16d80
# ╠═cbd70d32-5111-11eb-2182-a90fe78014f3
# ╠═0286215a-5113-11eb-1a3b-2d2e38773964
# ╠═bceef71c-5116-11eb-1ee7-61f648076c8a
# ╠═afeecdee-ee8f-443c-9f01-8a7445db15cb
# ╟─a4319250-5118-11eb-0b52-0d7c576d061c
# ╠═34e0d218-5117-11eb-2b05-afbbee902f2d
# ╠═e85278ff-8a08-4813-959b-586e35c1ae88
# ╠═eec1f9a6-6d80-432e-b9df-2a014d6d0517
# ╠═2a860e88-624a-4cec-942f-9be41fcfabe1
# ╠═2c703d49-7017-4177-9865-ffc1efc0e71b
# ╠═ed1adae6-62b1-4a62-bcab-700cf41ebf25
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
