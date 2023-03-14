### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ 9c410a0d-30dd-4b46-b7cb-8892df94fb14
Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using CairoMakie
	using LaTeXStrings

	# Graphs related
	using CairoMakie
	using GraphViz

	# Causal inference support
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: SR, sr_datadir, scale!, PRECIS
	using StatisticalRethinkingPlots: plotbounds
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

# ╔═╡ 9f39524d-e4b0-4909-97a0-059bf46386f5
md"### Julia code snippet 5.35"

# ╔═╡ b35b41bd-8752-4b13-8745-7c24754f6768
stan5_5_1 = "
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

# ╔═╡ ec590c54-67fc-4d9f-a7bb-f1ec0b126a7f
md"### Julia code snippet 5.36"

# ╔═╡ b1a7b82a-a981-42fc-9583-3899ba96fe21
let
	data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
		"K" => df[!, :kcal_per_g_s]);
	global m5_5_1s = SampleModel("m5.5.1", stan5_5_1);
	global rc5_5_1s = stan_sample(m5_5_1s; data)
	success(rc5_5_1s) && describe(m5_5_1s, [:a, :bN, :sigma])
end

# ╔═╡ 51abae98-54ba-49f8-8da1-1952f31353e8
begin
	post5_5_1s_df = read_samples(m5_5_1s, :dataframe)
	ms5_5_1s = model_summary(post5_5_1s_df, [:a, :bN, :sigma])
end

# ╔═╡ dd708337-e867-48c6-a6b3-0478c8b3e8bf
stan5_5_2 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] LM; // Predictor
}

parameters {
 real a; // Intercept
 real bLM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bLM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bLM * LM;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ cdbc2c0d-6b74-4765-9ce2-58e4b44adc27
md"#### Define the SampleModel, etc."

# ╔═╡ bd37996e-4843-42e0-9c5f-6425ecb0f0cd
let
	data = Dict("N" => size(df, 1), "LM" => df[!, :lmass_s],
		"K" => df[!, :kcal_per_g_s]);
	global m5_5_2s = SampleModel("m5.5.2", stan5_5_2);
	global rc5_5_2s = stan_sample(m5_5_2s; data);
end;

# ╔═╡ 2fe175d3-f3f1-45f3-8640-87a40456189d
begin
	post5_5_2s_df = read_samples(m5_5_2s, :dataframe)
	ms5_5_2s = model_summary(post5_5_2s_df, [:a, :bLM, :sigma])
end

# ╔═╡ 9d7eff6e-50c8-41a9-8d54-f726be68f0f1
md"### Julia code snippet 5.37"

# ╔═╡ eb991545-5c3c-4044-b100-42dad0c98fda
let
	x_range = -2.2:0.01:1.6
	f = Figure(resulution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="neocortex percent (std)", ylabel="kcal per g (std)",
		title="Kcal_per_g vs. neocortex_perc" * "\nshowing predicted and hpd range")
	res = link(post5_5_1s_df, (r, x) -> r.a + r.bN * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	scatter!(df.neocortex_perc_s, df.kcal_per_g_s)
	lines!(x_range, ms5_5_1s[:a, :mean] .+ ms5_5_1s[:bN, :mean] .* x_range)
	ax = Axis(f[1, 2];  xlabel="log body mass (std)", ylabel="kcal per g (std)",
		title= "Kcal_per_g vs. log body mass" * "\nshowing predicted and hpd range")
	res = link(post5_5_2s_df, (r, x) -> r.a + r.bLM * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	scatter!(df.lmass_s, df.kcal_per_g_s)	
	lines!(x_range, ms5_5_2s[:a, :mean] .+ ms5_5_2s[:bLM, :mean] .* x_range)
	f
end

# ╔═╡ 948613ed-57ac-49a7-b758-97edecc20e1e
md"### Julia code snippet 5.38"

# ╔═╡ a1fb1107-1b3b-4848-bf6f-c36aaf483976
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

# ╔═╡ 564973bd-6031-4aa8-8b21-408a3b53aec8
begin
	data = (N = size(df, 1), M = df[!, :lmass_s],
		K = df[!, :kcal_per_g_s], NC = df[!, :neocortex_perc_s]);
	m5_5s = SampleModel("m5.5", stan5_5)
	rc5_5s = stan_sample(m5_5s; data)
end;

# ╔═╡ b2db3a78-f3b1-40b0-bc98-dad2ee78891d
stan5_6 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ b36663a4-58b8-4f53-a681-143843889bae
begin
	m5_6s = SampleModel("m5.6", stan5_6);
	rc5_6s = stan_sample(m5_6s; data)
end;

# ╔═╡ accb23e4-70a9-4ac6-973e-7eac2a68853c
stan5_7 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ c003aa52-8aea-4e17-a7f7-5dd38edcad81
begin
	m5_7s = SampleModel("m5.7", stan5_7)
	rc5_7s = stan_sample(m5_7s; data)
end;

# ╔═╡ 55db7c46-81fa-4eb2-8dbb-37f7ab789e96
md"### Julia code snippet 5.39"

# ╔═╡ 73fc9756-9b86-4983-8a42-a2c34e6e5358
if success(rc5_5s) && success(rc5_6s) && success(rc5_7s)
	(s1, p1) = plot_model_coef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	p1
end

# ╔═╡ b1b11f5e-27c3-4f53-bc86-260c7e26874b
s1

# ╔═╡ 7d6b1a5d-d3a3-49c2-8553-1e0b9fcade85
md"### Julia code snippet 5.40"

# ╔═╡ 7de83549-a914-4091-8e64-86633356dc42
if success(rc5_5s)
	post5_5s_df = read_samples(m5_5s, :dataframe)
	title5 = "Kcal_per_g vs. neocortex_perc" * "\n89% predicted and mean range"
	fig1 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		post5_5s_df, [:a, :bN, :sigma];
		title=title5
	)
end

# ╔═╡ a3622d8e-269d-4483-9a2e-c7b081d1109d
if success(rc5_6s)
	post5_6s_df = read_samples(m5_6s, :dataframe)
	title6 = "Kcal_per_g vs. log mass" * "\n89% predicted and mean range"
	fig2 = plotbounds(
		df, :lmass, :kcal_per_g,
		post5_6s_df, [:a, :bM, :sigma];
		title=title6
	)
end

# ╔═╡ 75d942ba-3998-4699-ade8-d9118665734a
if success(rc5_7s)
	post5_7s_df = read_samples(m5_7s, :dataframe)
	title7 = "Counterfactual,\nholding M=0.0"
	fig3 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		post5_7s_df, [:a, :bN, :sigma];
		title=title7
	)
end

# ╔═╡ 959b9a15-c9d1-47a6-afdb-25a3a50b6736
if success(rc5_7s)
	title8 = "Counterfactual,\nholding N=0.0"
	fig4 = plotbounds(
		df, :lmass, :kcal_per_g,
		post5_7s_df, [:a, :bM, :sigma];
		title=title8,
		xlab="log(mass)"
	)
end

# ╔═╡ 1c2d9624-59d0-46e8-a004-a38f152262e3
#plot(fig1, fig2, fig3, fig4, layout=(2, 2))

# ╔═╡ 1c3c3e1d-552c-4185-9133-16443c5fa736
md"### Julia code snippet 5.41-42"

# ╔═╡ 7e60433c-47a8-4754-a24b-f5f83c6cf6d6
let
	fig1 = plot(xlab="Manipulated M", ylab="Counterfactual K",
	  title="Total counterfactual effect of M on K")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array1 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array1[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array1[:, 1], -hpdi_array1[:, 2]))
end

# ╔═╡ 917c5008-a803-43e4-bb35-6db46e3a425e
let
	fig2 = plot(xlab="Manipulated M", ylab="Counterfactual NC",
	  title="Counterfactual effect of M on NC")
	plot!(a_seq, mean(m_sim, dims=1)[1, :], leg=false)
	hpdi_array2 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array2[i, :] =  hpdi(m_sim[i, :])
	end
	plot!(a_seq, mean(m_sim, dims=1)[1, :]; ribbon=(hpdi_array2[:, 1], -hpdi_array2[:, 2]))
end

# ╔═╡ d01dbd28-0943-4ac8-a397-68a0afdc2f46
md"##### NC -> K"

# ╔═╡ 7133b0e9-cb3f-470a-adf4-b7b66a66dc85
let
	nc_seq = range(-2, stop=2, length=100)
	nc_k_sim = zeros(size(post5_7_As_df, 1), length(nc_seq))
	for j in 1:size(post5_7_As_df, 1)
	  for i in 1:length(nc_seq)
		d = Normal(post5_7_As_df[j, :a] + post5_7_As_df[j, :bN] * nc_seq[i], post5_7_As_df[j, :sigma])
		nc_k_sim[j, i] = rand(d, 1)[1]
	  end
	end
	fig3 = plot(xlab="Manipulated NC", ylab="Counterfactual K",
	  title="Counterfactual effect of NC on K")
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :], leg=false)
	hpdi_array3 = zeros(length(nc_seq), 2)
	for i in 1:length(nc_seq)
	  hpdi_array3[i, :] =  hpdi(nc_k_sim[i, :])
	end
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :]; ribbon=(hpdi_array3[:, 1], -hpdi_array3[:, 2]))
end

# ╔═╡ d9d3924a-cb8a-4d2d-849d-c72ad9f0e597
#plot(fig1, fig2, fig3, layout=(3, 1))

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
# ╟─9f39524d-e4b0-4909-97a0-059bf46386f5
# ╠═b35b41bd-8752-4b13-8745-7c24754f6768
# ╟─ec590c54-67fc-4d9f-a7bb-f1ec0b126a7f
# ╠═b1a7b82a-a981-42fc-9583-3899ba96fe21
# ╠═51abae98-54ba-49f8-8da1-1952f31353e8
# ╠═dd708337-e867-48c6-a6b3-0478c8b3e8bf
# ╟─cdbc2c0d-6b74-4765-9ce2-58e4b44adc27
# ╠═bd37996e-4843-42e0-9c5f-6425ecb0f0cd
# ╠═2fe175d3-f3f1-45f3-8640-87a40456189d
# ╟─9d7eff6e-50c8-41a9-8d54-f726be68f0f1
# ╠═eb991545-5c3c-4044-b100-42dad0c98fda
# ╠═948613ed-57ac-49a7-b758-97edecc20e1e
# ╠═a1fb1107-1b3b-4848-bf6f-c36aaf483976
# ╠═564973bd-6031-4aa8-8b21-408a3b53aec8
# ╠═b2db3a78-f3b1-40b0-bc98-dad2ee78891d
# ╠═b36663a4-58b8-4f53-a681-143843889bae
# ╠═accb23e4-70a9-4ac6-973e-7eac2a68853c
# ╠═c003aa52-8aea-4e17-a7f7-5dd38edcad81
# ╟─55db7c46-81fa-4eb2-8dbb-37f7ab789e96
# ╠═73fc9756-9b86-4983-8a42-a2c34e6e5358
# ╠═b1b11f5e-27c3-4f53-bc86-260c7e26874b
# ╟─7d6b1a5d-d3a3-49c2-8553-1e0b9fcade85
# ╠═7de83549-a914-4091-8e64-86633356dc42
# ╠═a3622d8e-269d-4483-9a2e-c7b081d1109d
# ╠═75d942ba-3998-4699-ade8-d9118665734a
# ╠═959b9a15-c9d1-47a6-afdb-25a3a50b6736
# ╠═1c2d9624-59d0-46e8-a004-a38f152262e3
# ╟─1c3c3e1d-552c-4185-9133-16443c5fa736
# ╠═7e60433c-47a8-4754-a24b-f5f83c6cf6d6
# ╠═917c5008-a803-43e4-bb35-6db46e3a425e
# ╠═d01dbd28-0943-4ac8-a397-68a0afdc2f46
# ╠═7133b0e9-cb3f-470a-adf4-b7b66a66dc85
# ╠═d9d3924a-cb8a-4d2d-849d-c72ad9f0e597
