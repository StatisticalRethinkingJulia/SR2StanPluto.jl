### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-05-06s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass])
	df.brain_std = df.brain/maximum(df.brain)
end;

# ╔═╡ abcc19ec-5076-11eb-1fd1-5bbc8fab188c
md" ### Snippet 7.3 (updated to get mu values)"

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

# ╔═╡ 278f62e2-5079-11eb-003f-cfc6b482ea79
post7_1as_df = read_samples(m7_1as; output_format=:dataframe);

# ╔═╡ 93d1db36-5118-11eb-3183-212c07cdf0eb
md" ### Snippet 7.5"

# ╔═╡ 7d5c3db8-5110-11eb-130e-072858e16d80
begin
	nt7_1as = read_samples(m7_1as)
	nt7_1as.mu'
end

# ╔═╡ cbd70d32-5111-11eb-2182-a90fe78014f3
s = mean(nt7_1as.mu, dims=2)

# ╔═╡ 0286215a-5113-11eb-1a3b-2d2e38773964
r = s - df.brain_std

# ╔═╡ bceef71c-5116-11eb-1ee7-61f648076c8a
function r2_is_bad(model::NamedTuple, df::DataFrame)
	local var2(x) = mean(x.^2) .- mean(x)^2
	s = mean(model.mu, dims=2)
	r = s - df.brain_std
	1 - var2(r) / var2(df.brain_std)
end

# ╔═╡ a4319250-5118-11eb-0b52-0d7c576d061c
md" ### Snippet 7.6"

# ╔═╡ 34e0d218-5117-11eb-2b05-afbbee902f2d
r2_is_bad(nt7_1as, df)

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
# ╠═278f62e2-5079-11eb-003f-cfc6b482ea79
# ╟─93d1db36-5118-11eb-3183-212c07cdf0eb
# ╠═7d5c3db8-5110-11eb-130e-072858e16d80
# ╠═cbd70d32-5111-11eb-2182-a90fe78014f3
# ╠═0286215a-5113-11eb-1a3b-2d2e38773964
# ╠═bceef71c-5116-11eb-1ee7-61f648076c8a
# ╟─a4319250-5118-11eb-0b52-0d7c576d061c
# ╠═34e0d218-5117-11eb-2b05-afbbee902f2d
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
