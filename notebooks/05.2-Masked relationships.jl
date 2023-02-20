### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ 9c410a0d-30dd-4b46-b7cb-8892df94fb14
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using GLMakie
	using LaTeXStrings

	# Graphs related
	using GraphMakie
	using Makie
	using Graphs
	using GraphMakie.NetworkLayout

	# Causal inference support
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: SR, sr_datadir, scale!, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 5.2 - Masked relationships."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(80px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ b26424bf-d206-4fb1-a2ab-222a8ffb80c7
md" ### Julia code snippet 5.28"

# ╔═╡ 06c94367-0b94-4aad-9130-01e0770ec821
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df.lmass = log.(df.mass)
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	scale_df_cols!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 42777e16-30de-4e4e-8d90-0a4c42e2a5b3
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

# ╔═╡ 5f478a40-3e55-4f49-9d90-6de96aeaf92d
md"##### Define the SampleModel, etc."

# ╔═╡ cb3c4aea-7b3b-4c93-b807-b4393d7d0b4c
begin
	m5_5_drafts = SampleModel("m5.5.draft", stan_5_5_draft);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df.neocortex_perc_s,
		"K" => df.kcal_per_g_s);
	rc5_5_drafts = stan_sample(m5_5_drafts, data=m5_5_data)
	success(rc5_5_drafts) && describe(rc5_5_drafts, [:a, :bN, :sigma])
end

# ╔═╡ a23527fb-8e69-48e4-934b-df9d01dbbc0a
if success(rc5_5_drafts)
	post5_5_drafts_df = read_samples(m5_5_drafts, :dataframe)
	model_summary(post5_5_drafts_df, [:a, :bN, :sigma])
end

# ╔═╡ eb13b755-0024-45fc-ab03-3e05c2a2b3b7
let
	if success(rc5_5_drafts)
		f = Figure(resolution=default_figure_resolution)
		ax = Axis(f[1, 1]; title="m5.5.drafts: a ~ Normal(0, 1), bN ~ Normal(0, 1)")
		x = -2:0.01:2
		for j in 1:100
			y = post5_5_drafts_df[j, :a] .+ post5_5_drafts_df[j, :bN]*x
			lines!(x, y, color=:lightgrey)
		end
		f
	end
end

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═9c410a0d-30dd-4b46-b7cb-8892df94fb14
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─b26424bf-d206-4fb1-a2ab-222a8ffb80c7
# ╠═06c94367-0b94-4aad-9130-01e0770ec821
# ╠═42777e16-30de-4e4e-8d90-0a4c42e2a5b3
# ╟─5f478a40-3e55-4f49-9d90-6de96aeaf92d
# ╠═cb3c4aea-7b3b-4c93-b807-b4393d7d0b4c
# ╠═a23527fb-8e69-48e4-934b-df9d01dbbc0a
# ╠═eb13b755-0024-45fc-ab03-3e05c2a2b3b7
