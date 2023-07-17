### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ c600966f-c2bf-4683-9351-d6f5f18f1e30
using Pkg

# ╔═╡ 433031b8-424d-429e-9b5c-5d1c4faeea67
Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ f115095c-2762-44d1-882e-e3ee1f02640b
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using CairoMakie

	# Causal inference support
	using GraphViz
	using CausalInference

	# Stan specific
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 969d4bb6-0a0b-4540-b125-90be7b5779a7
md" ## 7.1 - The problem with parameters."

# ╔═╡ 2dac121d-11d0-4dd6-bf10-2f5121a44576
md"##### Set page layout for notebook."

# ╔═╡ 3dd68075-470a-4e45-adf3-a110aecd9bb3
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 20%);
	}
</style>
"""

# ╔═╡ d919a139-c5d3-4c32-bb9f-48115f75119b
md"### Julia code snippet 7.01"

# ╔═╡ ae857001-30c9-4079-bd79-9afb818dd842
begin
	sppnames = [:afarensis, :africanus, :hapilis,
		:boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	df[!, :brain_s] = df.brain / maximum(df.brain) 
	scale_df_cols!(df, :mass)
	data = (N = size(df, 1), brain = df.brain_s, mass = df.mass_s)
end

# ╔═╡ bc2fe2eb-fb4c-4e4f-9f73-824b716c71ed
md" ### Julia code snippet 7.02"

# ╔═╡ f594c32d-d56a-4e90-8433-b2ae5a853843
df

# ╔═╡ dc95e7b0-96b5-4259-9cb9-1389769c165e
begin
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="body mass [kg]", ylabel="brain vol [cc]")
	scatter!(df.mass, df.brain)
	
	for (ind, species) in enumerate(df.species)
		yadj =8
		if species == :afarensis
			yadj = -38
		end
		annotations!(String(df[ind, :species]); position=(df[ind, :mass] - 0.9, df[ind, :brain] + yadj))
	end
	f
end

# ╔═╡ af4fabee-f2e5-4a6c-9fad-3bfb7d237f01
md" ### Julia code snippet 7.03"

# ╔═╡ 98812b6b-d394-4b90-b46b-986b04b6f56a
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
  sigma ~ normal(0, 1);
  mu = a + bA * mass;
  brain ~ normal(mu , sigma);   // Likelihood
}
";

# ╔═╡ f186df35-4abb-4ba7-acbd-000156a9f1ba
let
	global m7_1s = SampleModel("m7.1s", stan7_1)
	global rc7_1s = stan_sample(m7_1s; data)
	success(rc7_1s) && describe(m7_1s, [:a, :bA, :sigma])
end

# ╔═╡ 58c4a78b-5024-41d0-aff9-4b1245cf64e2
if success(rc7_1s)
	post7_1s_df = read_samples(m7_1s, :dataframe)
	ms7_1s = model_summary(post7_1s_df, [:a, :bA, :sigma])
end

# ╔═╡ 9a196854-d7e3-4a99-8a7a-31b4cb24b011
PRECIS(post7_1s_df)

# ╔═╡ cb7ddc89-c71b-41d7-9940-b48114793b38
log(mean(post7_1s_df.sigma))

# ╔═╡ 41eb1a4e-1bbd-4e92-9c8f-2c8c5c7c4e8a
stan7_1a = "
data {
 int < lower = 1 > N; 			// Sample size
 vector[N] brain; 				// Outcome
 vector[N] mass; 				// Predictor
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real log_sigma; 
}

model {
  vector[N] mu;               	// mu is a vector
  a ~ normal(0.5, 1);         	//Priors
  bA ~ normal(0, 10);
  log_sigma ~ normal(0, 1);
  mu = a + bA * mass;
  brain ~ normal(mu , exp(log_sigma));   // Likelihood
}
";

# ╔═╡ 526277b4-d89f-4f29-bc3e-427802a3fbc6
begin
	m7_1as = SampleModel("m7.1as", stan7_1a)
	rc7_1as = stan_sample(m7_1as; data)
	success(rc7_1as) && describe(m7_1as, [:a, :bA, :log_sigma])
end

# ╔═╡ 5fbaa60b-0164-402f-bea7-69f3e0450dc5
if success(rc7_1as)
	post7_1as_df = read_samples(m7_1as, :dataframe)
	ms7_1as_df = model_summary(post7_1as_df, [:a, :bA, :log_sigma])
end

# ╔═╡ bf77a18b-24ff-4cca-8863-c5ae3300256f
exp(mean(post7_1as_df.log_sigma))

# ╔═╡ 71fffab5-23ac-43d2-a185-d41ccde39a7a
stan7_1b = "
data{
	int < lower = 1 > N; 			// Sample size
    vector[N] brain;
    vector[N] mass;
}
parameters{
    real a;
    real bA;
    real log_sigma;
}
model{
    vector[N] mu;
    log_sigma ~ normal( 0 , 1 );
    bA ~ normal( 0 , 10 );
    a ~ normal( 0.5 , 1 );
    for ( i in 1:N ) {
        mu[i] = a + bA * mass[i];
    }
    brain ~ normal( mu , exp(log_sigma) );
}
";

# ╔═╡ 5ffd89a9-577d-4da7-b074-71f3125e7441
let
	data = (N = size(df, 1), brain = df.brain_s, mass = df.mass_s)
	global m7_1bs = SampleModel("m7.1bs", stan7_1b)
	global rc7_1bs = stan_sample(m7_1bs; data)
	success(rc7_1bs) && describe(m7_1bs, [:a, :bA, :log_sigma])
end

# ╔═╡ d6471315-72f3-400a-ac3b-ab5149e0f685
if success(rc7_1bs)
	post7_1bs_df = read_samples(m7_1bs, :dataframe)
	ms7_1bs = model_summary(post7_1bs_df, [:a, :bA, :log_sigma])
end

# ╔═╡ 6bb25243-e9ec-4678-9174-0a876c8bfc9f
let
	x_s = -1.3:0.1:1.7
	y_s = ms7_1bs[:a, :mean] .+ ms7_1bs[:bA, :mean] .* x_s
	x = (x_s .- mean(df.mass)) ./ std(df.mass)
	y = (y_s .- mean(df.brain)) ./ std(df.brain)
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1])
	scatter!(df.mass_s, df.brain_s)
		
	lines!(x, y)
	f
end

# ╔═╡ 38700e2c-6382-48b9-99bf-14d3ec91b867
md" ### Julia code snippet 7.04"

# ╔═╡ 2bc6cb6f-39bc-42bc-b144-36ee2b6e2072
m1 = lm(@formula(brain_s ~ mass_s), df)

# ╔═╡ 93939e51-7f79-42e2-a557-5feef7bfc3c6
m2 = lm(@formula(brain ~ mass), df)

# ╔═╡ Cell order:
# ╟─969d4bb6-0a0b-4540-b125-90be7b5779a7
# ╟─2dac121d-11d0-4dd6-bf10-2f5121a44576
# ╠═3dd68075-470a-4e45-adf3-a110aecd9bb3
# ╠═c600966f-c2bf-4683-9351-d6f5f18f1e30
# ╠═433031b8-424d-429e-9b5c-5d1c4faeea67
# ╠═f115095c-2762-44d1-882e-e3ee1f02640b
# ╟─d919a139-c5d3-4c32-bb9f-48115f75119b
# ╠═ae857001-30c9-4079-bd79-9afb818dd842
# ╟─bc2fe2eb-fb4c-4e4f-9f73-824b716c71ed
# ╠═f594c32d-d56a-4e90-8433-b2ae5a853843
# ╠═dc95e7b0-96b5-4259-9cb9-1389769c165e
# ╟─af4fabee-f2e5-4a6c-9fad-3bfb7d237f01
# ╠═98812b6b-d394-4b90-b46b-986b04b6f56a
# ╠═f186df35-4abb-4ba7-acbd-000156a9f1ba
# ╠═58c4a78b-5024-41d0-aff9-4b1245cf64e2
# ╠═9a196854-d7e3-4a99-8a7a-31b4cb24b011
# ╠═cb7ddc89-c71b-41d7-9940-b48114793b38
# ╠═41eb1a4e-1bbd-4e92-9c8f-2c8c5c7c4e8a
# ╠═526277b4-d89f-4f29-bc3e-427802a3fbc6
# ╠═5fbaa60b-0164-402f-bea7-69f3e0450dc5
# ╠═bf77a18b-24ff-4cca-8863-c5ae3300256f
# ╠═71fffab5-23ac-43d2-a185-d41ccde39a7a
# ╠═5ffd89a9-577d-4da7-b074-71f3125e7441
# ╠═d6471315-72f3-400a-ac3b-ab5149e0f685
# ╠═6bb25243-e9ec-4678-9174-0a876c8bfc9f
# ╟─38700e2c-6382-48b9-99bf-14d3ec91b867
# ╠═2bc6cb6f-39bc-42bc-b144-36ee2b6e2072
# ╠═93939e51-7f79-42e2-a557-5feef7bfc3c6
