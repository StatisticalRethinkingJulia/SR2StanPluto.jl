### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 7c7f0aa2-c8ba-4319-a580-b2bd65a8f069
using Pkg

# ╔═╡ 8f0b317a-d644-4286-a75e-f962b728d1c4
begin
    using Distributions
    using StatsPlots
    using StatsBase
    using LaTeXStrings
    using CSV
    using DataFrames
    using LinearAlgebra
    using Random
    using GLM
    using MonteCarloMeasurements
    using StanQuap
    using StatisticalRethinking
    using StatisticalRethinkingPlots
    using RegressionAndOtherStories

end

# ╔═╡ a4ed40d9-eba5-4e21-be89-63923101d36f
md" ## Clip-07-01-04s.jl"

# ╔═╡ 35e702f7-2160-41b4-ac67-b146086cebc4
md" ### Julia code snippet 7.1"

# ╔═╡ fc516a28-73ab-4dc0-945e-b1c4a6dc29c1
begin
	sppnames = [:afarensis, :africanus, :hapilis,
		:boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	
	# Julia code snippet 7.2
	
	df[!, :brain_s] = df.brain / maximum(df.brain) 
	scale_df_cols!(df, :mass)
end

# ╔═╡ 4fda2d47-1a42-4b71-8776-803763bfd918
df

# ╔═╡ dcfb2c64-c38b-4a50-a627-dde937f1bd2a
begin
	fig7_2 = scatter(df.mass, df.brain, xlab="body mass [kg]",
		ylab="brain vol [cc]", leg=false)
	for (ind, species) in pairs(df.species)
		annotate!(fig7_2, [(df[ind, :mass] + 0.8, df[ind, :brain] + 25,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
	plot(fig7_2)
end

# ╔═╡ df6567bf-8b23-4bd9-9a35-e0a553711480
md" ### Julia code snippet 7.3"

# ╔═╡ 19f0e426-d732-43a4-a5f4-04be6cfd13e9
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

# ╔═╡ 87b5802b-6fa6-4d92-b199-2d526f653b84
begin
	data = (N = size(df, 1), brain = df.brain_s, mass = df.mass_s)
	init = (a = 0.0, bA = 1, sigma = 2)
	q7_1s, m7_1s, o7_1s = stan_quap("m7.1s", stan7_1; data, init)
end;

# ╔═╡ 67a2a121-f750-4d8b-8afd-e12f72d25e55
if !isnothing(q7_1s)
	quap7_1s_df = sample(q7_1s)
	quap7_1s = Particles(quap7_1s_df)
end

# ╔═╡ 5d181571-d5fd-48d7-b987-5ff14e577946
PRECIS(quap7_1s_df)

# ╔═╡ 774fc3e1-25ed-4412-924a-2ec01c5d5293
log(mean(quap7_1s_df.sigma))

# ╔═╡ e930ee5d-9253-4fd2-91ba-bce86ed167cf
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

# ╔═╡ 01db4908-92f3-4408-9f1e-aa88d54b49c2
q7_1as, m7_1as, o7_1as = stan_quap("m7.1as", stan7_1a; data, init);

# ╔═╡ f818c144-9124-4166-ad4c-d6f7ce4aca17
if !isnothing(q7_1as)
	quap7_1as_df = sample(q7_1as)
	post7_1as_df = read_samples(m7_1as, :dataframe)
	quap7_1as = Particles(quap7_1as_df)
end

# ╔═╡ 67124c32-c2b1-4496-9ade-1e19e8ea4226
PRECIS(quap7_1as_df)

# ╔═╡ dd57c27a-f360-4f99-89fe-19d22e6d602d
PRECIS(post7_1as_df)

# ╔═╡ 581e85c4-72e7-449d-a9b8-b8d924af0714
exp(mean(quap7_1as_df.log_sigma))

# ╔═╡ f451e997-2be4-4894-9dc1-e167a56a2515
stan7_1b = "
data{
	int < lower = 1 > N; 			// Sample size
    vector[N] brain;
    vector[N] mass;
}
parameters{
    real a;
    real b;
    real log_sigma;
}
model{
    vector[N] mu;
    log_sigma ~ normal( 0 , 1 );
    b ~ normal( 0 , 10 );
    a ~ normal( 0.5 , 1 );
    for ( i in 1:N ) {
        mu[i] = a + b * mass[i];
    }
    brain ~ normal( mu , exp(log_sigma) );
}
";

# ╔═╡ 70528191-e83a-41ae-9b33-79d2b4b73498
q7_1bs, m7_1bs, o7_1bs = stan_quap("m7.1bs", stan7_1b; data, init);

# ╔═╡ 9602495a-c015-4c9d-b36e-8142e9ecf7ba
if !isnothing(q7_1bs)
	quap7_1bs_df = sample(q7_1bs)
	post7_1bs_df = read_samples(m7_1bs, :dataframe)
	quap7_1bs = Particles(quap7_1bs_df)
end

# ╔═╡ 5cdd6ac6-774d-4602-8bcb-8ce813e46356
PRECIS(quap7_1bs_df)

# ╔═╡ 32c37504-eabd-4042-be42-ee4d8df73443
PRECIS(post7_1bs_df)

# ╔═╡ aa05a451-943c-4ff7-9bdb-c7b3c5f08857
begin
	x_s = -1.3:0.1:1.7
	y_s = mean(quap7_1s.a) .+ mean(quap7_1s.bA) .* x_s
	x = rescale(x_s, mean(df.mass), std(df.mass))
	y = rescale(y_s, mean(df.brain), std(df.brain))
	plot(fig7_2)
	plot!(x, y)
end

# ╔═╡ f54cd0e3-63ef-4afa-8e80-107b57b758c1
md" ### Julia code snippet 7.4"

# ╔═╡ bb76ce6f-5c14-4842-9d45-c46a6c8522a6
m1 = lm(@formula(brain_s ~ mass_s), df)

# ╔═╡ 728e89a6-1d93-440f-9dcc-beefa0faad87
m2 = lm(@formula(brain ~ mass), df)

# ╔═╡ 4597c989-d383-4941-a488-24a5a8f19e36
md" ## End of clip-07-01-04s.jl"

# ╔═╡ Cell order:
# ╟─a4ed40d9-eba5-4e21-be89-63923101d36f
# ╠═7c7f0aa2-c8ba-4319-a580-b2bd65a8f069
# ╠═8f0b317a-d644-4286-a75e-f962b728d1c4
# ╟─35e702f7-2160-41b4-ac67-b146086cebc4
# ╠═fc516a28-73ab-4dc0-945e-b1c4a6dc29c1
# ╠═4fda2d47-1a42-4b71-8776-803763bfd918
# ╠═dcfb2c64-c38b-4a50-a627-dde937f1bd2a
# ╟─df6567bf-8b23-4bd9-9a35-e0a553711480
# ╠═19f0e426-d732-43a4-a5f4-04be6cfd13e9
# ╠═87b5802b-6fa6-4d92-b199-2d526f653b84
# ╠═67a2a121-f750-4d8b-8afd-e12f72d25e55
# ╠═5d181571-d5fd-48d7-b987-5ff14e577946
# ╠═774fc3e1-25ed-4412-924a-2ec01c5d5293
# ╠═e930ee5d-9253-4fd2-91ba-bce86ed167cf
# ╠═01db4908-92f3-4408-9f1e-aa88d54b49c2
# ╠═f818c144-9124-4166-ad4c-d6f7ce4aca17
# ╠═67124c32-c2b1-4496-9ade-1e19e8ea4226
# ╠═dd57c27a-f360-4f99-89fe-19d22e6d602d
# ╠═581e85c4-72e7-449d-a9b8-b8d924af0714
# ╠═f451e997-2be4-4894-9dc1-e167a56a2515
# ╠═70528191-e83a-41ae-9b33-79d2b4b73498
# ╠═9602495a-c015-4c9d-b36e-8142e9ecf7ba
# ╠═5cdd6ac6-774d-4602-8bcb-8ce813e46356
# ╠═32c37504-eabd-4042-be42-ee4d8df73443
# ╠═aa05a451-943c-4ff7-9bdb-c7b3c5f08857
# ╟─f54cd0e3-63ef-4afa-8e80-107b57b758c1
# ╠═bb76ce6f-5c14-4842-9d45-c46a6c8522a6
# ╠═728e89a6-1d93-440f-9dcc-beefa0faad87
# ╟─4597c989-d383-4941-a488-24a5a8f19e36
