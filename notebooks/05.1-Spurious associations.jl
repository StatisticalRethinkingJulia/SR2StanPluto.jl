### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using CairoMakie
	using LaTeXStrings

	# Causal inference support
	using CausalInference

	# DAG graphics support
	using GraphViz

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 5.1 - Spurious associations."

# ╔═╡ e875dcfc-fc57-11ea-27e5-c56f1f9d5370
md"### Julia code snippet 5.1"

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 36%);
	}
</style>
"""

# ╔═╡ 2e717b02-0290-49e3-9f67-70f73d760b10
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65e98dc-fc58-11ea-25e1-9fab97b6125a
begin
	waffles = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale_df_cols!(waffles, [:Marriage, :MedianAgeMarriage, :Divorce])
	waffles.Whpm = waffles.WaffleHouses./waffles.Population
	waffles[:, [:Loc, :Population, :Marriage, :MedianAgeMarriage, :Divorce, :Divorce_s]]
end

# ╔═╡ a7698084-37d1-4677-89ff-183908a33fbe
describe(waffles)

# ╔═╡ 39f32370-ef8f-4918-9412-e4d8b6e8db38
stan5_0 = "
	data {
		int < lower = 1 > N; // Sample size
		vector[N] W; // Predictor WaffleHouse per million
		vector[N] D; // Outcome Divirce rate
	}

	parameters {
		real a; // Intercept
		real bW; // Slope (regression coefficients)
		real < lower = 0 > sigma; 
	}

	model {
		vector[N] mu;               // mu is a vector
		mu = a + bW * W;
		a ~ normal(0, 5);         // Priors
		bW ~ normal(0, 5);
		sigma ~ exponential(1);
		D ~ normal(mu, sigma);
	}
";

# ╔═╡ cb260a55-1eea-4d4a-930e-547820e2bac6
let
	global m5_0s = SampleModel("m5.0s", stan5_0)
	data = Dict("N" => size(waffles, 1), "D" => waffles.Divorce, "W" => waffles.Whpm)
	global rc5_0s = stan_sample(m5_0s; data)
	success(rc5_0s) && describe(m5_0s, [:a, :bW, :sigma])
end

# ╔═╡ 63fbfe5a-5c5e-4dc8-aeca-742f017f105b
if success(rc5_0s)
	post5_0s_df = read_samples(m5_0s, :dataframe)
	ms5_0s = model_summary(post5_0s_df, [:a, :bW, :sigma])
end


# ╔═╡ 8cdea9c8-7793-4bac-b77b-04b08898fc71
post5_0s_df

# ╔═╡ b26424bf-d206-4fb1-a2ab-222a8ffb80c7
md"### Julia code snippet 5.2"

# ╔═╡ cb454809-0dd7-4e79-adc6-7a2793090964
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="WaffleHouses per million", ylabel="Divorce rate", title="Figure 5.1")
	x_range = 0:0.1:50
	lines!(x_range, ms5_0s[:a, :mean] .+ ms5_0s[:bW, :mean] .* x_range)
	res = link(post5_0s_df, (r, x) -> r.a + r.bW * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	scatter!(waffles.Whpm, waffles.Divorce)
	for state in ["AR", "AL", "GA", "SC", "ME", "NJ"]
		for row in eachrow(waffles[waffles.Loc .== state, : ])
			xpos = row.WaffleHouses/row.Population
			annotations!(row.Loc; position=(row.Whpm + 0.4, row.Divorce))
		end
	end
	f
end

# ╔═╡ 238a10f2-3b78-44f5-a727-5839320ce443
waffles[waffles.Loc .== ["GA"], :]

# ╔═╡ d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
stan5_1_1 = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] A; // Predictor
	}

	parameters {
	 real a; // Intercept
	 real bA; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  mu = a + bA * A;
	  a ~ normal(0, 0.2);         // Priors
	  bA ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	}
";

# ╔═╡ f4602d4a-fc59-11ea-0d9d-9f58c73c119f
md"### Julia code snippet 5.3-4"

# ╔═╡ d670aefa-fc58-11ea-1c56-4bfb66e1cab2
md"## Define the SampleModel, etc."

# ╔═╡ d67e0602-fc58-11ea-3a27-31d03e1c2318
let
	global m5_1_1s = SampleModel("m5.1.1s", stan5_1_1)
	data = Dict("N" => size(waffles, 1), "A" => waffles.MedianAgeMarriage_s)
	global rc5_1_1s = stan_sample(m5_1_1s; data)
	success(rc5_1_1s) && describe(m5_1_1s, [:a, :bA, :sigma])
end

# ╔═╡ a4a9351a-01c6-11eb-28d0-71f8fb243719
if success(rc5_1_1s)
	priors5_1_1s_df = read_samples(m5_1_1s, :dataframe)
	ms5_1_1s = model_summary(priors5_1_1s_df, [:a, :bA, :sigma])
end

# ╔═╡ 12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
md"### Julia code snippet 5.5"

# ╔═╡ 45b2b002-01c6-11eb-3f86-3f9586afcc8b
md"##### Plot priors of the intercept (`:a`) and the slope (`:bA`)."

# ╔═╡ 7f433052-5f29-491d-960d-480bcb836571
let
	xi = -3.0:0.1:3.0

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Medium age marriage (scaled)", ylabel="Divorce rate (scaled)",
		title="Showing 50 regression lines")

	for i in 1:50
		local yi = mean(priors5_1_1s_df[i, :a]) .+ priors5_1_1s_df[i, :bA] .* xi
		lines!(xi, yi, color=:lightgrey)
	end
	scatter!(waffles[:, :MedianAgeMarriage_s], waffles[!, :Divorce_s], color=:darkblue)

	f
end

# ╔═╡ 6fc7763b-3d96-44cb-ab90-303e3ba828e8
stan5_1 = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] D; // Outcome
	 vector[N] A; // Predictor
	}

	parameters {
	 real a; // Intercept
	 real bA; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  a ~ normal(0, 0.2);         // Priors
	  bA ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	  mu = a + bA * A;
	  D ~ normal(mu , sigma);   // Likelihood
	}
";

# ╔═╡ 81d7ce22-15af-4c3e-a361-49b191f8d63d
let
	global m5_1s = SampleModel("m5.1s", stan5_1)
	data = Dict("N" => size(waffles, 1), "D" => waffles.Divorce_s, "A" => waffles.MedianAgeMarriage_s)
	global rc5_1s = stan_sample(m5_1s; data)
	success(rc5_1s) && describe(m5_1s, [:a, :bA, :sigma])
end

# ╔═╡ 59a4d93b-90e3-4bc3-8e75-4a7b04b85b67
if success(rc5_1s)
	post5_1s_df = read_samples(m5_1s, :dataframe)
	ms5_1s = model_summary(post5_1s_df, [:a, :bA, :sigma])
end

# ╔═╡ 5567d466-e4da-4e9a-b4b2-b77b2700e51b
let
	xi = -3.0:0.1:3.0

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Medium age marriage (scaled)", ylabel="Divorce rate (scaled)",
		title="Showing 50 regression lines")

	for i in 1:50
		local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
		lines!(xi, yi, color=:lightgrey)
	end
	scatter!(waffles[:, :MedianAgeMarriage_s], waffles[!, :Divorce_s], color=:darkblue)

	f
end

# ╔═╡ d69533ba-fc58-11ea-3378-e512a1d55d27
md"### Julia code snippet 5.6"

# ╔═╡ ee264ad3-947d-4cd7-975e-e0fea7d6b1d4
stan5_2 = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] D; // Outcome (Divorce rate standardized)
	 vector[N] M; // Predictor (Marriage rate standardized)
	}

	parameters {
	 real a; // Intercept
	 real bM; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  a ~ normal(0, 0.2);         // Priors
	  bM ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	  mu = a + bM * M;
	  D ~ normal(mu , sigma);   // Likelihood
	}
";

# ╔═╡ cecfbf01-7997-49cc-bb67-75eb611f2cf9
let
	global m5_2s = SampleModel("m5.2s", stan5_2)
	data = Dict("N" => size(waffles, 1), "D" => waffles.Divorce_s, "M" => waffles.Marriage_s)
	global rc5_2s = stan_sample(m5_2s; data)
	success(rc5_2s) && describe(m5_2s, [:a, :bM, :sigma])
end

# ╔═╡ 7eb5f4bb-345a-42da-b2d6-e5407af2a663
if success(rc5_2s)
	post5_2s_df = read_samples(m5_2s, :dataframe)
	ms5_2s = model_summary(post5_2s_df, [:a, :bM, :sigma])
end

# ╔═╡ 62254c66-5a5a-44de-a635-a5044262aeeb
let
	xi = -2.0:0.1:3.0

	f = Figure(resolution=default_figure_resolution)

	# Rescale axis
	scale_factor_x = [mu * std(waffles.Marriage) + mean(waffles.Marriage) for mu in -2:2:2]
	xtick_labels = string.(round.(scale_factor_x, digits=2))
	scale_factor_y = [mu * std(waffles.Divorce) + mean(waffles.Divorce) for mu in -2:1:2]
	ytick_labels = string.(round.(scale_factor_y, digits=2))

	ax = Axis(f[1, 1]; xlabel="Marriage rate (scaled)", ylabel="Divorce rate (scaled)",
		title="Showing 50 regression lines",
		xticks=(-2:2:2, xtick_labels), 
		yticks=(-2:1:2, ytick_labels))
	
	for i in 1:50
		local yi = post5_2s_df[i, :a] .+ post5_2s_df[i, :bM] .* xi
		lines!(xi, yi, color=:lightgrey)
	end
	lines!(xi, ms5_2s[:a, :mean] .+ ms5_2s[:bM, :mean] .* xi; color=:darkred)
	scatter!(waffles[:, :Marriage_s], waffles[!, :Divorce_s], color=:darkblue)

	xi = -2.5:0.1:3.0

	# Rescale axis
	scale_factor_x = [mu * std(waffles.MedianAgeMarriage) + mean(waffles.MedianAgeMarriage) for mu in -2:2:2]
	xtick_labels = string.(round.(scale_factor_x, digits=2))
	scale_factor_y = [mu * std(waffles.Divorce) + mean(waffles.Divorce) for mu in -2:1:2]
	ytick_labels = string.(round.(scale_factor_y, digits=2))
	
	ax = Axis(f[1, 2]; xlabel="Medium age marriage (scaled)", ylabel="Divorce rate (scaled)",
		title="Showing 50 regression lines",
		xticks=(-2:2:2, xtick_labels), 
		yticks=(-2:1:2, ytick_labels))


	for i in 1:50
		local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
		lines!(xi, yi, color=:lightgrey)
	end
	lines!(xi, ms5_1s[:a, :mean] .+ ms5_1s[:bA, :mean] .* xi; color=:darkred)
	scatter!(waffles[:, :MedianAgeMarriage_s], waffles[!, :Divorce_s], color=:darkblue)

	f
end

# ╔═╡ d6c14359-d723-4dd9-b9a5-fc7b68157be3
md"### Julia code snippet 5.7"

# ╔═╡ 694ca34c-ebf8-4e5e-bd11-8821a9116e33
md" ### Using CausalInference.jl and Graphiz.jl"

# ╔═╡ 65dab224-d3d7-4c46-95b2-f23f4971a1bc
let
	A = waffles.MedianAgeMarriage_s
	M = waffles.Marriage_s
	D = waffles.Divorce_s
	global p = 0.01
	global X = [A M D]
	global dfAMD = DataFrame(A=A, M=M, D=D)
end;

# ╔═╡ f7c5c5c7-85d4-4e09-b025-31109e451577
begin
	dag_1_edges = "DiGraph DAG_1 {A -> M; M -> D; A -> D;}"
	dag_1 = create_dag("DAG_1", dfAMD; g_dot_str=dag_1_edges)
	gvplot(dag_1)
end

# ╔═╡ bfdab5a8-37a6-4af2-9645-99f8e0d8edd5
dag_1.g.fadjlist

# ╔═╡ aa2238cd-3d62-467e-a19b-84ab6f1561ea
dag_1.est_g.fadjlist

# ╔═╡ 5c87da91-ee1f-4d74-827b-efe107f25862
md" ##### Check d-separation between A, M and D"

# ╔═╡ ab5933f6-43d1-4fb0-9860-3a352bbb251e
dsep(dag_1, :A, :M; verbose=true)

# ╔═╡ 6c44b0cb-14ed-4c12-b173-f96212f10683
dsep(dag_1, :A, :M, [:D])

# ╔═╡ 1ce3080e-c5c8-472b-a29d-eda3fc0dce99
dsep(dag_1, :A, :D, [:M])

# ╔═╡ 0c0ba8f0-efc5-4f22-b2d5-41ba4125d221
dsep(dag_1, :M, :D, [:A]; verbose=true)

# ╔═╡ 66104ae9-eae1-4f42-b38f-6b562e1c152f
begin
	dag_2_edges = "DiGraph DAG_2 {A -> M; A -> D;}"
	dag_2 = create_dag("DAG_2", dfAMD; g_dot_str=dag_2_edges)
	gvplot(dag_2)
end

# ╔═╡ ad9edb34-64de-4ae7-aba6-6333421ac1bc
md" ##### Check d-separation between M and D in DAG_2."

# ╔═╡ 61dcc961-398f-4f95-bffb-4d51f9ea8fc6
dsep(dag_2, :D, :M, Symbol[], verbose=true)

# ╔═╡ 11e64b3b-1bb4-48dc-b0de-6a66f8e59ae5
dsep(dag_2, :A, :M, [:D]; verbose=true)

# ╔═╡ 24aa10d0-c938-4834-8cbd-689ed1ca2cbe
md" ###### Check d-separation between M and D conditioned on A"

# ╔═╡ 2eb20607-232f-4a28-a21d-80e5c348ee1c
dsep(dag_2, :M, :D, [:A]; verbose=true)

# ╔═╡ 1a100134-2c6d-46f0-8ae3-2064393da8ab
md" #### Use WaffleHouses data"

# ╔═╡ e17691c6-655e-4275-ad64-9f9f95cd0d00
dag_1.covm

# ╔═╡ 2f77ef28-44fd-4ca2-9fbb-c7009131b0e9
@time est_g = pcalg(dfAMD, 0.01, gausscitest)

# ╔═╡ 46f7f849-f8f4-4465-821d-35f26c0e41b7
est_g

# ╔═╡ 29bb4c65-f91b-44e2-9ad9-10b087083285
est_g.fadjlist

# ╔═╡ a2a742d8-a46c-43e0-9cd3-1ce5a49a0ad9
est_g_edges = [(:A, :M), (:A, :D), (:M, :A), (:D, :A)];

# ╔═╡ 753f5b10-17ea-4e32-9f52-ff174321bcd6
md" ### Julia code snippet 5.10"

# ╔═╡ 95849e5c-aa0f-4d6f-b618-51e8959496a8
stan5_3 = "
data {
  int N;
  vector[N] D;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + + bA * A + bM * M;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ 7fb18290-fde1-418b-8908-a8dbcc1a695b
let
	global m5_3s = SampleModel("m5.3s", stan5_3)
	data = (N=size(waffles, 1), M=waffles.Marriage_s, A=waffles.MedianAgeMarriage_s, D=waffles.Divorce_s)
	global rc5_3s = stan_sample(m5_3s; data)
	success(rc5_3s) && describe(m5_3s, [:a, :bM, :bA, :sigma])
end

# ╔═╡ f8cfbdd8-eb5e-421f-8996-afac58117146
if success(rc5_3s)
	post5_3s_df = read_samples(m5_3s, :dataframe)
	ms5_3s = model_summary(post5_3s_df, [:a, :bA, :bM, :sigma])
end

# ╔═╡ fe796c94-83ba-4b08-a873-099283dfbb15
md"### Julia code snippet 5.11"

# ╔═╡ a8d4342d-eb5a-4627-9c0b-19bb1c56bcc5
md"
!!! note
Once we know median age at marriage (A) for a State, there is limited or no additional predictive power in also knowing the rate of marriage (M) in that State. See above result for `dsep(dag_2, :M, :D, [:A]; verbose=true)`.
"

# ╔═╡ b36f2e78-2231-408b-844c-c4e237bae57d
if success(rc5_1s) && success(rc5_2s) && success(rc5_3s) 
	(s1, f1) = plot_model_coef([m5_1s, m5_2s, m5_3s], [:bA, :bM, :sigma]; 
		title="Comparison of coefficient bA and bM locations and ranges for models m5_1s, m5_2s and m5_3s.")
	f1
end

# ╔═╡ 6a2607b5-83a9-4331-a2c6-c16c62872669
md"### Julia code snippet 5.12"

# ╔═╡ 0d74cfd6-429d-423c-b098-689e2a66c47c
let
	N = 50
	age = rand(Normal(), N)
	global sim5_12 = DataFrame(
		age = age,
		mar = [rand(Normal(-a, 1), 1)[1] for a in age],
		div = [rand(Normal(a, 1), 1)[1] for a in age]
	)
end

# ╔═╡ 59540d03-e0fe-46fd-864a-8c0c5014773f
let
	mar = [rand(Normal(s, 1), 1)[1] for s in sim5_12.age .+ sim5_12.mar]
end

# ╔═╡ c473ea08-a5b9-46b3-9acf-ae903879baca
md" ### Julia code snippet 5.13"

# ╔═╡ 8df14f30-96fd-4540-bb84-acf398a63706
stan5_4 = "
data {
  int N;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bAM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bAM * A;
  a ~ normal( 0 , 0.2 );
  bAM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  M ~ normal( mu , sigma );
}
";

# ╔═╡ 992d5d6e-f79a-479f-b88e-fcc068eb8dfb
let
	global m5_4s = SampleModel("m5.4s", stan5_4)
	data = (N=size(waffles, 1), M=waffles.Marriage_s, A=waffles.MedianAgeMarriage_s)
	global rc5_4s = stan_sample(m5_4s; data)
	success(rc5_4s) && describe(m5_4s, [:a, :bAM, :sigma])
end

# ╔═╡ e131d3bd-c6fa-4be8-abc1-67efc71d33ec
if success(rc5_4s)
	post5_4s_df = read_samples(m5_4s, :dataframe)
	ms5_4s = model_summary(post5_4s_df, [:a, :bAM, :sigma])
end

# ╔═╡ b85abe6e-8849-40ad-8e87-5a7c5d5dc78a
stan5_5 = "
data {
  int N;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bMA;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bMA * M;
  a ~ normal( 0 , 0.2 );
  bMA ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  A ~ normal( mu , sigma );
}
";

# ╔═╡ 2ca01ad9-862c-4b79-a876-6ea20a86a6af
let
	global m5_5s = SampleModel("m5.5s", stan5_5)
	data = (N=size(waffles, 1), M=waffles.Marriage_s, A=waffles.MedianAgeMarriage_s)
	global rc5_5s = stan_sample(m5_5s; data)
	success(rc5_5s) && describe(m5_5s, [:a, :bMA, :sigma])
end

# ╔═╡ 4bef1e16-fe09-40af-a2a4-312e8c4f0dd6
if success(rc5_5s)
	post5_5s_df = read_samples(m5_5s, :dataframe)
	ms5_5s = model_summary(post5_5s_df, [:a, :bMA, :sigma])
end

# ╔═╡ dff714c3-dad1-4e75-8731-dcdc30e7e01b
md" ### Julia code snipper 5.14"

# ╔═╡ 5dba7793-47a6-4eaf-9ee8-b865ef3583cc
let
	global res_df = DataFrame( L = waffles.Loc, D = waffles.Divorce_s,
		M = waffles.Marriage_s, A = waffles.MedianAgeMarriage_s)
	
	mean_a1, mean_bAM, _ = ms5_4s[:, :mean]
	res_df.preds1 = mean_a1 .+ mean_bAM .* res_df.A
	res_df.AM_res = res_df.M .- res_df.preds1
	
	mean_a2, mean_bMA, _ = ms5_5s[:, :mean]
	res_df.preds2 = mean_a2 .+ mean_bMA .* res_df.M
	res_df.MA_res = res_df.A .- res_df.preds2
	res_df
end

# ╔═╡ 2f7de9dc-1e67-41b3-80a1-4c3307c190ad
stan5_5a = "
data {
  int N;
  vector[N] M_res;
  vector[N] D;
}
parameters {
  real a;
  real b;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + b * M_res;
  a ~ normal( 0 , 0.2 );
  b ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ b5dae0aa-63fd-4904-9e9f-7c33274ece3b
let
	global m5_5as = SampleModel("m5.5as", stan5_5a)
	data = (N=size(res_df, 1), M_res=res_df.AM_res, D=res_df.D)
	global rc5_5as = stan_sample(m5_5as; data)
	success(rc5_5as) && describe(m5_5as, [:a, :b, :sigma])
end

# ╔═╡ daa93aeb-2419-4bf9-80e9-d96d10eaed34
if success(rc5_5as)
	post5_5as_df = read_samples(m5_5as, :dataframe)
	ms5_5as = model_summary(post5_5as_df, [:a, :b, :sigma])
end

# ╔═╡ 4f93cc6b-567b-4e9d-85bb-4cf7b11fbf0d
stan5_5b = "
data {
  int N;
  vector[N] MA_res;
  vector[N] D;
}
parameters {
  real a;
  real b;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + b * MA_res;
  a ~ normal( 0 , 0.2 );
  b ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ c8c72e7e-aa05-40be-a0f0-f0f8928a7197
let
	global m5_5bs = SampleModel("m5.5bs", stan5_5b)
	data = (N=size(res_df, 1), MA_res=res_df.MA_res, D=res_df.D)
	global rc5_5bs = stan_sample(m5_5bs; data)
	success(rc5_5bs) && describe(m5_5bs, [:a, :b, :sigma])
end

# ╔═╡ 33c7351d-a175-4f8b-8ab5-c6b4535a538a
if success(rc5_5bs)
	post5_5bs_df = read_samples(m5_5bs, :dataframe)
	ms5_5bs = model_summary(post5_5bs_df, [:a, :b, :sigma])
end

# ╔═╡ 611061ef-10f7-43cb-8af9-3227abf43c45
let
	x = -2.4:0.1:3
	mean_a1, mean_bAM, mean_sigma = ms5_4s[:, :mean]
	
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Age at marriage (std)", ylabel="Marriage rate (std)",
		title="Regression of M on A")
	
	preds = mean_a1 .+ mean_bAM .* x
	lines!(x, preds)
	
	for i in 1:size(res_df, 1)
		lines!([res_df.A[i], res_df.A[i]], 
			[mean_a1 .+ mean_bAM .* res_df.A[i], res_df.M[i]]; color=:lightgrey)
	end
	scatter!(res_df.A, res_df.M; marker=:circle)
	for state in ["ID", "ND", "ME", "HI", "WY", "DC"]
		for row in eachrow(res_df[res_df.L .== state, : ])
			annotations!(row.L; position=(row.A + 0.05, row.M - 0.5))
		end
	end

	ax = Axis(f[2, 1]; xlabel="Age at marriage residuals", ylabel="Divorce rate (std)",
		title="Regression of D on A residuals")
	scatter!(res_df.AM_res, res_df.D)
	for state in ["ID", "ND", "ME", "HI", "WY", "DC"]
		for row in eachrow(res_df[res_df.L .== state, : ])
			annotations!(row.L; position=(row.AM_res + 0.05, row.D - 0.1))
		end
	end
	x_range = -2:0.1:2
	lines!(x_range, ms5_5as[:a, :mean] .+ ms5_5as[:b, :mean] .* x_range)
	res = link(post5_5as_df, (r, x) -> r.a + r.b * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))

		
	mean_a2, mean_bMA, mean_sigma = ms5_5s[:, :mean]
	ax = Axis(f[1, 2]; xlabel="Marriage rate (std)", ylabel="Age at marriage (std)",
		title="Regression of A on M")
	
	preds = mean_a2 .+ mean_bMA .* x
	lines!(x, preds)
	
	for i in 1:size(res_df, 1)
		lines!([res_df.M[i], res_df.M[i]], 
			[mean_a2 .+ mean_bMA .* res_df.M[i], res_df.A[i]]; color=:lightgrey)
	end
	scatter!(res_df.M, res_df.A; marker=:circle)
	for state in ["ID", "ND", "ME", "HI", "WY", "DC"]
		for row in eachrow(res_df[res_df.L .== state, : ])
			annotations!(row.L; position=(row.M + 0.05, row.A - 0.5))
		end
	end
	ax = Axis(f[2, 2]; xlabel="Marriage rate residuals", ylabel="Divorce rate (std)",
		title="Regression of D on M residuals")
	scatter!(res_df.MA_res, res_df.D)
	for state in ["ID", "ND", "ME", "HI", "WY", "DC"]
		for row in eachrow(res_df[res_df.L .== state, : ])
			annotations!(row.L; position=(row.MA_res + 0.05, row.D - 0.5))
		end
	end
	x_range = -2:0.1:3
	lines!(x_range, ms5_5bs[:a, :mean] .+ ms5_5bs[:b, :mean] .* x_range)
	res = link(post5_5bs_df, (r, x) -> r.a + r.b * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))
	
	f
end
	

# ╔═╡ 7cc2addc-77d4-4405-9867-3380f3c36d79
md" ### Julia code snippet 5.15"

# ╔═╡ 0a68e7e4-bf56-454c-9489-f704d56d374c
begin
	div_df = DataFrame( L = waffles.Loc, D = waffles.Divorce_s,
		M = waffles.Marriage_s, A = waffles.MedianAgeMarriage_s)
	res = link(post5_3s_df, (r, x) -> r.a + r.bA * div_df.A[x] + r.bM * div_df.M[x], 1:50)
	res = hcat(res...)
	m, l, u = estimparam(res)
	div_df.m = m
	div_df.l = l
	div_df.u = u
	div_df
end

# ╔═╡ e9530376-06ac-4e85-8cd1-b8f9f9f6ec1b
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Observed values of D", ylabel="Predicted values of D",
		title="Prediction of D by state")
	scatter!(div_df.D, div_df.m)
	for state in ["ID", "ND", "ME", "HI", "UT", "WY", "DC"]
		for row in eachrow(div_df[div_df.L .== state, : ])
			annotations!(row.L; position=(row.D + 0.03, row.m - 0.1))
		end
	end
	for row in eachrow(div_df)
		lines!([row.D, row.D], [row.l, row.u]; color=:grey)
	end
	
	x = -2:0.1:2.1
	lm_model = lm(@formula(m ~ D), div_df)
	regr = lines!(x, coef(lm_model)[1] .+ coef(lm_model)[2] .* x)
	pred = lines!(x, x; color=:darkred, linestyle=:dash)
	
	Legend(f[1, 2],
	    [regr, pred],
	    ["Predicted ~ observed values", "Prediction == observed values"])

	f
end

# ╔═╡ da451143-cb64-4bc0-b8f9-8ff4614c521d
md" ### Julia code snippet 5.19"

# ╔═╡ d6e3deba-5c57-4b8b-bfa4-c81fccd2aa9c
stan5_3_A = "
data {
  int N;
  vector[N] D;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bA;
  real bM;
  real aM;
  real bAM;
  real<lower=0> sigma;
  real<lower=0> sigma_M;
}
model {
  // A -> D <- M
  vector[N] mu = a + bA * A + bM * M;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
  // A -> M
  vector[N] mu_M = aM + bAM * A;
  aM ~ normal( 0 , 0.2 );
  bAM ~ normal( 0 , 0.5 );
  sigma_M ~ exponential( 1 );
  M ~ normal( mu_M , sigma_M );
}
";

# ╔═╡ 68ea52fe-c06a-49bc-bede-b68bf4af2e86
begin
	data = (N = size(dfAMD, 1), D = waffles.Divorce_s, M = waffles.Marriage_s,
		A = waffles.MedianAgeMarriage_s)
	global m5_3_As = SampleModel("m5.3_A", stan5_3_A)
	global rc5_3_As = stan_sample(m5_3_As; data)
	success(rc5_3_As) && describe(m5_3_As, [:a, :bA, :bM, :sigma, :aM, :bAM, :sigma_M])
end

# ╔═╡ 0005da9e-5b05-4bf4-9597-d94dcdb38956
if success(rc5_3_As)
	post5_3_As_df = read_samples(m5_3_As, :dataframe)
	ms5_3_As = model_summary(post5_3_As_df, [:a, :bA, :bM, :sigma, :aM, :bAM, :sigma_M])
end

# ╔═╡ e4aea49a-6f03-47fd-a260-dbb2c9f02aee
function simulate2(df, coefs, var_seq, coefs_ext)
  m_sim = simulate2(df, coefs, var_seq)
  d_sim = zeros(size(df, 1), length(var_seq));
  for j in 1:size(df, 1)
    for i in 1:length(var_seq)
      d = Normal(df[j, coefs[1]] + df[j, coefs[2]] * var_seq[i] +
        df[j, coefs_ext[1]] * m_sim[j, i], df[j, coefs_ext[2]])
      d_sim[j, i] = rand(d)
    end
  end
  (m_sim, d_sim)
end

# ╔═╡ 2f499cb2-cdec-4814-a379-a5d7ce1bf115
function simulate2(df, coefs, var_seq)
  m_sim = zeros(size(df, 1), length(var_seq));
  for j in 1:size(df, 1)
    for i in 1:length(var_seq)
      d = Normal(df[j, coefs[1]] + df[j, coefs[2]] * var_seq[i], df[j, coefs[3]])
      m_sim[j, i] = rand(d)
    end
  end
  m_sim
end


# ╔═╡ c98dbd9b-9b38-446a-8da9-a7d69ea29956
md"### Julia code snippet 5.22"

# ╔═╡ 2a353988-ea2c-4d82-8ec7-2c7f0c843f19
a_seq = range(-2, stop=2, length=100);

# ╔═╡ 33242df0-b647-4974-9cac-b5692ce8100e
md"### Julia code snippet 5.23"

# ╔═╡ 42f32805-f566-4531-9cd8-b35dc2a3c876
m_sim, d_sim = simulate(post5_3_As_df, [:aM, :bAM, :sigma_M], a_seq, [:bM, :sigma]);

# ╔═╡ 4a75c36f-3a7f-4d74-9253-6717789d82d6
md" ### Julia code snippet 5.24"

# ╔═╡ 8c14e485-7a51-4f47-b787-ed6675d80d53
let
	f = Figure(resulution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Manipulated A", ylabel="Counterfactual D",
		title="Total counterfactual effect of A on D")
	m, l, u = estimparam(d_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))

	ax = Axis(f[1, 2]; xlabel="Manipulated A", ylabel="Counterfactual M",
		title="Counterfactual effect of A on M")
	m, l, u = estimparam(m_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))
	
	f
end

# ╔═╡ 69c6e338-4450-458b-91a6-eeb08f91cb54
md"##### M -> D"

# ╔═╡ 44ef03ae-e9fa-4de6-a669-b7b5b46b0346
let
	m_seq = range(-2, stop=2, length=100)

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Manipulated A", ylabel="Counterfactual D",
		title="Total counterfactual effect of A on D")
	m, l, u = estimparam(d_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))
	
	md_sim = zeros(size(post5_3_As_df, 1), length(m_seq))
	for j in 1:size(post5_3_As_df, 1)
		for i in 1:length(m_seq)
			d = Normal(post5_3_As_df[j, :a] + post5_3_As_df[j, :bM] * m_seq[i],
				post5_3_As_df[j, :sigma])
			md_sim[j, i] = rand(d, 1)[1]
		end
	end
	ax = Axis(f[1, 2]; xlabel="Manipulated M", ylabel="Counterfactual D",
		title="Counterfactual effect of M on D")
	m, l, u = estimparam(md_sim)
	lines!(a_seq, m)
	band!(a_seq, l, u; color=(:grey, 0.3))

	f
end

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─e875dcfc-fc57-11ea-27e5-c56f1f9d5370
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═2e717b02-0290-49e3-9f67-70f73d760b10
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╠═d65e98dc-fc58-11ea-25e1-9fab97b6125a
# ╠═a7698084-37d1-4677-89ff-183908a33fbe
# ╠═39f32370-ef8f-4918-9412-e4d8b6e8db38
# ╠═cb260a55-1eea-4d4a-930e-547820e2bac6
# ╠═63fbfe5a-5c5e-4dc8-aeca-742f017f105b
# ╠═8cdea9c8-7793-4bac-b77b-04b08898fc71
# ╟─b26424bf-d206-4fb1-a2ab-222a8ffb80c7
# ╠═cb454809-0dd7-4e79-adc6-7a2793090964
# ╠═238a10f2-3b78-44f5-a727-5839320ce443
# ╠═d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
# ╟─f4602d4a-fc59-11ea-0d9d-9f58c73c119f
# ╟─d670aefa-fc58-11ea-1c56-4bfb66e1cab2
# ╠═d67e0602-fc58-11ea-3a27-31d03e1c2318
# ╠═a4a9351a-01c6-11eb-28d0-71f8fb243719
# ╟─12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
# ╟─45b2b002-01c6-11eb-3f86-3f9586afcc8b
# ╠═7f433052-5f29-491d-960d-480bcb836571
# ╠═6fc7763b-3d96-44cb-ab90-303e3ba828e8
# ╠═81d7ce22-15af-4c3e-a361-49b191f8d63d
# ╠═59a4d93b-90e3-4bc3-8e75-4a7b04b85b67
# ╠═5567d466-e4da-4e9a-b4b2-b77b2700e51b
# ╟─d69533ba-fc58-11ea-3378-e512a1d55d27
# ╠═ee264ad3-947d-4cd7-975e-e0fea7d6b1d4
# ╠═cecfbf01-7997-49cc-bb67-75eb611f2cf9
# ╠═7eb5f4bb-345a-42da-b2d6-e5407af2a663
# ╠═62254c66-5a5a-44de-a635-a5044262aeeb
# ╟─d6c14359-d723-4dd9-b9a5-fc7b68157be3
# ╟─694ca34c-ebf8-4e5e-bd11-8821a9116e33
# ╠═65dab224-d3d7-4c46-95b2-f23f4971a1bc
# ╠═f7c5c5c7-85d4-4e09-b025-31109e451577
# ╠═bfdab5a8-37a6-4af2-9645-99f8e0d8edd5
# ╠═aa2238cd-3d62-467e-a19b-84ab6f1561ea
# ╟─5c87da91-ee1f-4d74-827b-efe107f25862
# ╠═ab5933f6-43d1-4fb0-9860-3a352bbb251e
# ╠═6c44b0cb-14ed-4c12-b173-f96212f10683
# ╠═1ce3080e-c5c8-472b-a29d-eda3fc0dce99
# ╠═0c0ba8f0-efc5-4f22-b2d5-41ba4125d221
# ╠═66104ae9-eae1-4f42-b38f-6b562e1c152f
# ╟─ad9edb34-64de-4ae7-aba6-6333421ac1bc
# ╠═61dcc961-398f-4f95-bffb-4d51f9ea8fc6
# ╠═11e64b3b-1bb4-48dc-b0de-6a66f8e59ae5
# ╟─24aa10d0-c938-4834-8cbd-689ed1ca2cbe
# ╠═2eb20607-232f-4a28-a21d-80e5c348ee1c
# ╟─1a100134-2c6d-46f0-8ae3-2064393da8ab
# ╠═e17691c6-655e-4275-ad64-9f9f95cd0d00
# ╠═2f77ef28-44fd-4ca2-9fbb-c7009131b0e9
# ╠═46f7f849-f8f4-4465-821d-35f26c0e41b7
# ╠═29bb4c65-f91b-44e2-9ad9-10b087083285
# ╠═a2a742d8-a46c-43e0-9cd3-1ce5a49a0ad9
# ╟─753f5b10-17ea-4e32-9f52-ff174321bcd6
# ╠═95849e5c-aa0f-4d6f-b618-51e8959496a8
# ╠═7fb18290-fde1-418b-8908-a8dbcc1a695b
# ╠═f8cfbdd8-eb5e-421f-8996-afac58117146
# ╟─fe796c94-83ba-4b08-a873-099283dfbb15
# ╟─a8d4342d-eb5a-4627-9c0b-19bb1c56bcc5
# ╠═b36f2e78-2231-408b-844c-c4e237bae57d
# ╟─6a2607b5-83a9-4331-a2c6-c16c62872669
# ╠═0d74cfd6-429d-423c-b098-689e2a66c47c
# ╠═59540d03-e0fe-46fd-864a-8c0c5014773f
# ╟─c473ea08-a5b9-46b3-9acf-ae903879baca
# ╠═8df14f30-96fd-4540-bb84-acf398a63706
# ╠═992d5d6e-f79a-479f-b88e-fcc068eb8dfb
# ╠═e131d3bd-c6fa-4be8-abc1-67efc71d33ec
# ╠═b85abe6e-8849-40ad-8e87-5a7c5d5dc78a
# ╠═2ca01ad9-862c-4b79-a876-6ea20a86a6af
# ╠═4bef1e16-fe09-40af-a2a4-312e8c4f0dd6
# ╟─dff714c3-dad1-4e75-8731-dcdc30e7e01b
# ╠═5dba7793-47a6-4eaf-9ee8-b865ef3583cc
# ╠═2f7de9dc-1e67-41b3-80a1-4c3307c190ad
# ╠═b5dae0aa-63fd-4904-9e9f-7c33274ece3b
# ╠═daa93aeb-2419-4bf9-80e9-d96d10eaed34
# ╠═4f93cc6b-567b-4e9d-85bb-4cf7b11fbf0d
# ╠═c8c72e7e-aa05-40be-a0f0-f0f8928a7197
# ╠═33c7351d-a175-4f8b-8ab5-c6b4535a538a
# ╠═611061ef-10f7-43cb-8af9-3227abf43c45
# ╟─7cc2addc-77d4-4405-9867-3380f3c36d79
# ╠═0a68e7e4-bf56-454c-9489-f704d56d374c
# ╠═e9530376-06ac-4e85-8cd1-b8f9f9f6ec1b
# ╟─da451143-cb64-4bc0-b8f9-8ff4614c521d
# ╠═d6e3deba-5c57-4b8b-bfa4-c81fccd2aa9c
# ╠═68ea52fe-c06a-49bc-bede-b68bf4af2e86
# ╠═0005da9e-5b05-4bf4-9597-d94dcdb38956
# ╠═e4aea49a-6f03-47fd-a260-dbb2c9f02aee
# ╠═2f499cb2-cdec-4814-a379-a5d7ce1bf115
# ╟─c98dbd9b-9b38-446a-8da9-a7d69ea29956
# ╠═2a353988-ea2c-4d82-8ec7-2c7f0c843f19
# ╟─33242df0-b647-4974-9cac-b5692ce8100e
# ╠═42f32805-f566-4531-9cd8-b35dc2a3c876
# ╟─4a75c36f-3a7f-4d74-9253-6717789d82d6
# ╠═8c14e485-7a51-4f47-b787-ed6675d80d53
# ╠═69c6e338-4450-458b-91a6-eeb08f91cb54
# ╠═44ef03ae-e9fa-4de6-a669-b7b5b46b0346
