### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using LaTeXStrings
	
	# Graphics related
	using GLMakie

	# Causal inference support
	using Graphs
	using GraphViz
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 5.3 - Categorical variables."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 38%);
	}
</style>
"""

# ╔═╡ 76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
md"### Julia code snippets 5.28 - 5.31"

# ╔═╡ 7eeb791c-2260-4887-b34c-94e7a1cfe43b
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df.lmass = log.(df.mass)
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	scale_df_cols!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ d73f36f6-39ba-4790-96b2-95d76dd50702
stan_5_5_draft = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}
parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 1);           //Priors
  bN ~ normal(0, 1);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 11558976-07ec-4b87-a53d-eeea4418a315
md"##### Define the SampleModel, etc."

# ╔═╡ b0b239e9-00c8-4a99-9f49-bb3a51ad6d5c
begin
	m5_5_drafts = SampleModel("m5.5.draft", stan_5_5_draft);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df.neocortex_perc_s,
		"K" => df.kcal_per_g_s);
	rc5_5_drafts = stan_sample(m5_5_drafts, data=m5_5_data)
	success(rc5_5_drafts) && describe(m5_5_drafts, [:a, :bN, :sigma])
end

# ╔═╡ deec5d40-1bb3-40dc-bf2a-3bb3be1513f0
if success(rc5_5_drafts)
  post5_5_drafts_df = read_samples(m5_5_drafts, :dataframe)
end

# ╔═╡ ccccedbd-bdf5-4987-9ce1-b168050cbefe
md"### Julia code snippets 5.31-5.34"

# ╔═╡ 77281e0a-e6af-4b51-a781-062871d69d86
if success(rc5_5_drafts)
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="m5.5.drafts: a ~ Normal(0, 1), bN ~ Normal(0, 1)")
	x = -2:0.01:2
	for j in 1:100
		y = post5_5_drafts_df[j, :a] .+ post5_5_drafts_df[j, :bN]*x
		lines!(x, y, color=:lightgrey, leg=false)
	end
	f
end

# ╔═╡ 138763e8-58fa-450e-b444-910fa955808f
md"### Julia code snippet 5.35"

# ╔═╡ 98e3e682-3a32-4c52-819c-8032ed93397c
stan5_5 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}

parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 335b965a-5ded-42b7-84fa-9dcb60e0520a
md"### Julia code snippet 5.36"

# ╔═╡ ab914ecc-f932-479a-85ec-1dac65a75327
let
	m5_5_data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
		"K" => df[!, :kcal_per_g_s]);
	global m5_5s = SampleModel("m5.5", stan5_5);
	global rc5_5s = stan_sample(m5_5s, data=m5_5_data)
	success(rc5_5s) && describe(m5_5s, [:a, :bN, :sigma])
end

# ╔═╡ 33d639d4-ad94-4dd8-b681-14d8305009b8
md"### Julia code snippet 5.37"

# ╔═╡ 7bd2bc6b-b337-4c44-a837-ac6109665e6a
if success(rc5_5s)
  post5_5s_df = read_samples(m5_5s, :dataframe)
  title = "Kcal_per_g vs. neocortex_perc" * "\nshowing predicted and hpd range"
  plotbounds(
    df, :neocortex_perc, :kcal_per_g,
    post5_5s_df, [:a, :bN, :sigma];
    title=title
  )
end

# ╔═╡ bb2f1aba-9153-433d-9026-63c2e5713758
md"### Julia code snippet 5.38"

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
# ╠═7eeb791c-2260-4887-b34c-94e7a1cfe43b
# ╠═d73f36f6-39ba-4790-96b2-95d76dd50702
# ╟─11558976-07ec-4b87-a53d-eeea4418a315
# ╠═b0b239e9-00c8-4a99-9f49-bb3a51ad6d5c
# ╠═deec5d40-1bb3-40dc-bf2a-3bb3be1513f0
# ╟─ccccedbd-bdf5-4987-9ce1-b168050cbefe
# ╠═77281e0a-e6af-4b51-a781-062871d69d86
# ╟─138763e8-58fa-450e-b444-910fa955808f
# ╠═98e3e682-3a32-4c52-819c-8032ed93397c
# ╟─335b965a-5ded-42b7-84fa-9dcb60e0520a
# ╠═ab914ecc-f932-479a-85ec-1dac65a75327
# ╟─33d639d4-ad94-4dd8-b681-14d8305009b8
# ╠═7bd2bc6b-b337-4c44-a837-ac6109665e6a
# ╠═bb2f1aba-9153-433d-9026-63c2e5713758
