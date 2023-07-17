### A Pluto.jl notebook ###
# v0.19.26

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
	using CairoMakie
	using LaTeXStrings

	# Graphs related
	using GraphViz
	using MetaGraphs

	# Causal inference support
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir
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
    	padding-right: max(200px, 35%);
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

# ╔═╡ bfb8f476-7242-4512-a8fb-66b7c5911883
begin
	data_df = DataFrame(M=df[!, :lmass_s])
	data_df.N = df[!, :neocortex_perc_s]
	data_df.K = df[:, :kcal_per_g_s]
	data_df
end

# ╔═╡ a7b77fb2-d83e-470a-b28b-c7cc8278c3c2
dag5_7_1 = create_fci_dag("dag5_7_1", data_df, "DiGraph dag5_7 {M -> K; M -> N; N -> K;}");

# ╔═╡ a2fac060-6c7d-41e6-bfef-fd4a1fd296e7
gvplot(dag5_7_1; title_g="Assumed generational model")

# ╔═╡ 30ceb7f3-dbf9-4c84-877c-eb96e343e1dc
begin
	dag5_7_2 = create_fci_dag("dag5_7_2", data_df, "DiGraph dag5_7 {M -> K; N -> M; N -> K;}")
	gvplot(dag5_7_2; title_g="Assumed generational model")
end

# ╔═╡ 7d6b1a5d-d3a3-49c2-8553-1e0b9fcade85
md"### Julia code snippet 5.40"

# ╔═╡ a4b88589-5b0d-442c-8658-55f2331ad242
let
	x_range = -3:0.1:3
	title = "Partial model: Kcal_per_g_s vs. neocortex_perc_s" * "\n89% predicted and mean range"
	global post5_5s_df = read_samples(m5_5s, :dataframe)

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title, xlabel="neocortex_perc", ylabel="kcal_per_g")
	scatter!(df.neocortex_perc_s, df.kcal_per_g_s)
	res = link(post5_5s_df, (r, x) -> r.a + r.bN * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	lines!(x_range, m; color=:darkred)
	band!(x_range, l, u; color=(:grey, 0.3))

	x_range = -2:0.1:2
	title = "Partial model: Kcal_per_g_s vs. lmass_s" * "\n89% predicted and mean range"
	global post5_6s_df = read_samples(m5_6s, :dataframe)

	ax = Axis(f[1, 2]; title, xlabel="lmass_s", ylabel="kcal_per_g_s")
	scatter!(df.lmass_s, df.kcal_per_g_s)
	res = link(post5_6s_df, (r, x) -> r.a + r.bM * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	lines!(x_range, m; color=:darkred)
	band!(x_range, l, u; color=(:grey, 0.3))

	x_range = -2:0.1:2
	title = "Full model: Kcal_per_g_s vs. neocortex_perc_s" * "\n89% predicted and mean range"
	global post5_7s_df = read_samples(m5_7s, :dataframe)

	ax = Axis(f[2, 1]; title, xlabel="neocortex_perc_s", ylabel="kcal_per_g_s")
	scatter!(df.neocortex_perc_s, df.kcal_per_g_s)
	res = link(post5_7s_df, (r, x) -> r.a + r.bN * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	lines!(x_range, m; color=:darkred)
	band!(x_range, l, u; color=(:grey, 0.3))

	x_range = -2:0.1:2
	title = "Full model: Kcal_per_g_s vs. lmass_s" * "\n89% predicted and mean range"

	ax = Axis(f[2, 2]; title, xlabel="lmass_s", ylabel="kcal_per_g_s")
	scatter!(df.lmass_s, df.kcal_per_g_s)
	res = link(post5_7s_df, (r, x) -> r.a + r.bM * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	lines!(x_range, m; color=:darkred)
	band!(x_range, l, u; color=(:grey, 0.3))

	f
end

# ╔═╡ 4b3fbf10-cd24-426b-9759-97146d184a0a
begin
	n = 100
	sim_data_df = DataFrame(:M => rand(Normal(), n),)
	sim_data_df.NC = [rand(Normal(sim_data_df[i, :M]), 1)[1] for i in 1:n]
	sim_data_df.K = [rand(Normal(sim_data_df[i, :NC] - sim_data_df[i, :M]), 1)[1] for i in 1:n]
	scale_df_cols!(sim_data_df, [:K, :M, :NC])
end;

# ╔═╡ 58d7af44-13d1-4d45-9755-27bf530d4935
stan5_7_A = "
data {
  int N;
  vector[N] K;
  vector[N] M;
  vector[N] NC;
}
parameters {
  real a;
  real bN;
  real bM;
  real aNC;
  real bMNC;
  real<lower=0> sigma;
  real<lower=0> sigma_NC;
}
model {
  // M -> K <- NC
  vector[N] mu = a + bN * NC + bM * M;
  a ~ normal( 0 , 0.2 );
  bN ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  K ~ normal( mu , sigma );
  // M -> NC
  vector[N] mu_NC = aNC + bMNC * M;
  aNC ~ normal( 0 , 0.2 );
  bMNC ~ normal( 0 , 0.5 );
  sigma_NC ~ exponential( 1 );
  NC ~ normal( mu_NC , sigma_NC );
}
";

# ╔═╡ b411649a-3242-42ec-9ee0-1ea7f140c603
let
	m5_7_A_data = Dict(
	  "N" => size(sim_data_df, 1), 
	  "K" => sim_data_df[:, :K_s],
	  "M" => sim_data_df[:, :M_s],
	  "NC" => sim_data_df[:, :NC_s] 
	);
	global m5_7_As = SampleModel("m5.7_A", stan5_7_A);
	global rc5_7_As = stan_sample(m5_7_As, data=m5_7_A_data);
	success(rc5_7_As) && describe(m5_7_As, [:a, :bN, :bM, :sigma, :aNC, :bMNC, :sigma_NC])
end

# ╔═╡ c9463bd4-2b53-46ca-a3b4-e9d0c3b67bee
md"### Julia code snippet 5.40"

# ╔═╡ 890c3735-429b-4209-abbd-5784d006d652
a_seq = range(-2, stop=2, length=100);

# ╔═╡ 228a0aa9-93b7-4b69-86e2-94664ef80584
md"### Julia code snippet 5.41"

# ╔═╡ 19273241-8c10-445b-8b2d-a534000660ac
md"### Julia code snippet 5.42"

# ╔═╡ c704513f-2d7f-4d9d-ae02-470d582891a4
post5_7_As_df = read_samples(m5_7_As, :dataframe)

# ╔═╡ 1a7d8513-84c8-4b17-ace7-8efd5a6422a5
m_sim, d_sim = simulate(post5_7_As_df, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma]);

# ╔═╡ c2e86fef-56e9-4831-823e-e26ffcaf7e2d
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Manipulated M", ylabel="Counterfactual K",
	  title="Total counterfactual effect of M on K")
	m, l, u = estimparam(d_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))

	ax = Axis(f[1, 2]; xlabel="Manipulated N", ylabel="Counterfactual M",
		title="Counterfactual effect of N on M")
	m, l, u = estimparam(m_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))

	f
end

# ╔═╡ 58ea484f-639a-4a5f-9f5d-71f1b72467a4
md"##### NC -> K"

# ╔═╡ b02af973-17c2-4feb-a9ae-f0d713bdd584
begin
	nc_seq = range(-2, stop=2, length=100)
	nc_k_sim = zeros(size(post5_7_As_df, 1), length(nc_seq))
	for j in 1:size(post5_7_As_df, 1)
	  for i in 1:length(nc_seq)
		d = Normal(post5_7_As_df[j, :a] + post5_7_As_df[j, :bN] * nc_seq[i], post5_7_As_df[j, :sigma])
		nc_k_sim[j, i] = rand(d, 1)[1]
	  end
	end
end

# ╔═╡ 903c01fc-6995-4c4d-acbf-527bfa353530
nc_k_sim

# ╔═╡ 26a449f0-73c5-4d17-8b7c-27bd938a7f66
begin
	f = Figure(resolution=default_figure_resolution)

	ax = Axis(f[1, 1]; xlabel="Manipulated M", ylabel="Counterfactual K",
	  title="Total counterfactual effect of M on K")
	m, l, u = estimparam(d_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))

	ax = Axis(f[1, 2]; xlabel="Manipulated N", ylabel="Counterfactual M",
		title="Counterfactual effect of N on M")
	m, l, u = estimparam(m_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))
	
	ax = Axis(f[2, 1:2]; xlabel="Manipulated N", ylabel="Counterfactual K",
	  title="Counterfactual effect of N on K")
	lines!(nc_seq, mean(nc_k_sim, dims=1)[1, :])
	m, l, u = estimparam(nc_k_sim)
	lines!(nc_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))
	
	f
end

# ╔═╡ 1c3c3e1d-552c-4185-9133-16443c5fa736
md"### Julia code snippet 5.41-42"

# ╔═╡ 2b674d50-8df8-47a3-ad2f-cbd15d557322
Nobs = 10000;

# ╔═╡ d9d3924a-cb8a-4d2d-849d-c72ad9f0e597
let
	# M -> K <- N
	# M -> N
	M = rand(Normal(), Nobs)
	N = [rand(Normal(x), 1)[1] for x in M]
	K = [rand(Normal(x), 1)[1] for x in N .- M]
	global dfMN = DataFrame(:N => N, :M => M, :K => K)
end

# ╔═╡ d3508cf5-6e07-4849-946a-075330c19f61
let
	# M -> K <- N
	# N -> M
	N = rand(Normal(), Nobs)
	M = [rand(Normal(x), 1)[1] for x in N]
	K = [rand(Normal(x), 1)[1] for x in N .- M]
	global dfNM = DataFrame(:N => N, :M => M, :K => K)
end

# ╔═╡ 65625ed9-ee0d-4bde-98a4-edf22e2e70b0
let
	# M -> K <- N
	# N <- U -> M
	U = rand(Normal(), Nobs)
	N = [rand(Normal(x), 1)[1] for x in U]
	M = [rand(Normal(x), 1)[1] for x in U]
	K = [rand(Normal(x), 1)[1] for x in N .- M]
	global
	dfMUN = DataFrame(:N => N, :M => M, :K => K)
end

# ╔═╡ 72f6615c-048b-41ae-b328-58e613a05c68
begin
	d1_str = "DiGraph d1 {M->K; M->N; N->K;}"
	d1 = create_fci_dag("d1", dfMN, d1_str)
end;

# ╔═╡ 54407529-4f09-4050-ad48-ba1861e80153
g_MN = pcalg(dfMN, 0.25, gausscitest)

# ╔═╡ e874496d-12f7-440c-b396-6e1f78b16935
g_oracle_MN = fcialg(3, dseporacle, d1.g)

# ╔═╡ 13896111-228a-401e-bdfa-5ff7f9de9dd0
g_gauss_MN = fcialg(dfMN, 0.05, gausscitest)

# ╔═╡ bfd8febf-a78c-483a-b16d-d45195310737
let
    fci_oracle_dot_str = to_gv(g_oracle_MN, d1.vars)
    fci_gauss_dot_str = to_gv(g_gauss_MN, d1.vars)
    g1 = GraphViz.Graph(d1.g_dot_str)
    g2 = GraphViz.Graph(d1.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

# ╔═╡ 4d077bcf-8905-4025-aa06-a76700a89ce8
begin
	d2_str = "DiGraph d2 {M->K; N->M; N->K;}"
	d2 = create_fci_dag("d2", dfNM, d2_str)
end;

# ╔═╡ f5d3877a-0217-43f7-a8b7-b4df9964d1f1
g_NM = pcalg(dfNM, 0.25, gausscitest)

# ╔═╡ 7fcf851f-3d08-4c92-8fe6-d0d68d6cc147
g_oracle_NM = fcialg(3, dseporacle, d2.g)

# ╔═╡ 20545a01-6cfd-4024-a1ed-a69daee4873f
g_gauss_NM = fcialg(dfNM, 0.05, gausscitest)

# ╔═╡ f3fffefe-53b1-4f22-9926-30a6631ee254
let
    fci_oracle_dot_str = to_gv(g_oracle_NM, d2.vars)
    fci_gauss_dot_str = to_gv(g_gauss_NM, d2.vars)
    g1 = GraphViz.Graph(d2.g_dot_str)
    g2 = GraphViz.Graph(d2.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

# ╔═╡ aaffc288-b366-4c21-91cb-908c4e955c4b
begin
	d3_str = "DiGraph d1 {M->K; M->N; N->K;}"
	d3 = create_fci_dag("d3", dfMUN, d1_str)
end;

# ╔═╡ 148db2db-82d9-4180-85c3-7960b1eee242
g_MUN = pcalg(dfMUN, 0.25, gausscitest)

# ╔═╡ 6108e29b-34bb-48c6-b9c6-1de3fe079c33
g_oracle_MUN = fcialg(3, dseporacle, d3.g)

# ╔═╡ 28199a44-b79b-4193-b7f3-9af59d8ab000
g_gauss_MUN = fcialg(dfMUN, 0.05, gausscitest)

# ╔═╡ 1db15a70-f679-4933-a4ef-a1aa1f9a8046
let
    fci_oracle_dot_str = to_gv(g_oracle_MUN, d1.vars)
    fci_gauss_dot_str = to_gv(g_gauss_MUN, d1.vars)
    g1 = GraphViz.Graph(d3.g_dot_str)
    g2 = GraphViz.Graph(d3.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="DAG with M <- U -> N")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

# ╔═╡ 0c0e5c67-f33c-4151-a262-c8dcd6198fc7
let
    g1 = GraphViz.Graph(d1.est_g_dot_str)
    g2 = GraphViz.Graph(d2.est_g_dot_str)
    g3 = GraphViz.Graph(d3.est_g_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="PC estimated DAG d1")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG d2")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 3]; aspect=DataAspect(), title="PC estimated DAG d3")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
   f
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
# ╠═bfb8f476-7242-4512-a8fb-66b7c5911883
# ╠═a7b77fb2-d83e-470a-b28b-c7cc8278c3c2
# ╠═a2fac060-6c7d-41e6-bfef-fd4a1fd296e7
# ╠═30ceb7f3-dbf9-4c84-877c-eb96e343e1dc
# ╟─7d6b1a5d-d3a3-49c2-8553-1e0b9fcade85
# ╠═a4b88589-5b0d-442c-8658-55f2331ad242
# ╠═4b3fbf10-cd24-426b-9759-97146d184a0a
# ╠═58d7af44-13d1-4d45-9755-27bf530d4935
# ╠═b411649a-3242-42ec-9ee0-1ea7f140c603
# ╟─c9463bd4-2b53-46ca-a3b4-e9d0c3b67bee
# ╠═890c3735-429b-4209-abbd-5784d006d652
# ╟─228a0aa9-93b7-4b69-86e2-94664ef80584
# ╠═1a7d8513-84c8-4b17-ace7-8efd5a6422a5
# ╟─19273241-8c10-445b-8b2d-a534000660ac
# ╠═c704513f-2d7f-4d9d-ae02-470d582891a4
# ╠═c2e86fef-56e9-4831-823e-e26ffcaf7e2d
# ╟─58ea484f-639a-4a5f-9f5d-71f1b72467a4
# ╠═b02af973-17c2-4feb-a9ae-f0d713bdd584
# ╠═903c01fc-6995-4c4d-acbf-527bfa353530
# ╠═26a449f0-73c5-4d17-8b7c-27bd938a7f66
# ╟─1c3c3e1d-552c-4185-9133-16443c5fa736
# ╠═2b674d50-8df8-47a3-ad2f-cbd15d557322
# ╠═d9d3924a-cb8a-4d2d-849d-c72ad9f0e597
# ╠═d3508cf5-6e07-4849-946a-075330c19f61
# ╠═65625ed9-ee0d-4bde-98a4-edf22e2e70b0
# ╠═72f6615c-048b-41ae-b328-58e613a05c68
# ╠═54407529-4f09-4050-ad48-ba1861e80153
# ╠═e874496d-12f7-440c-b396-6e1f78b16935
# ╠═13896111-228a-401e-bdfa-5ff7f9de9dd0
# ╠═bfd8febf-a78c-483a-b16d-d45195310737
# ╠═4d077bcf-8905-4025-aa06-a76700a89ce8
# ╠═f5d3877a-0217-43f7-a8b7-b4df9964d1f1
# ╠═7fcf851f-3d08-4c92-8fe6-d0d68d6cc147
# ╠═20545a01-6cfd-4024-a1ed-a69daee4873f
# ╠═f3fffefe-53b1-4f22-9926-30a6631ee254
# ╠═aaffc288-b366-4c21-91cb-908c4e955c4b
# ╠═148db2db-82d9-4180-85c3-7960b1eee242
# ╠═6108e29b-34bb-48c6-b9c6-1de3fe079c33
# ╠═28199a44-b79b-4193-b7f3-9af59d8ab000
# ╠═1db15a70-f679-4933-a4ef-a1aa1f9a8046
# ╠═0c0e5c67-f33c-4151-a262-c8dcd6198fc7
