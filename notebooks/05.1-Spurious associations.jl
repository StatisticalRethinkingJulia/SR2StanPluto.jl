### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	
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
	using StatisticalRethinking: sr_datadir, scale!, PRECIS
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
    	padding-left: max(80px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ d65e98dc-fc58-11ea-25e1-9fab97b6125a
begin
	waffles = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(waffles, [:Marriage, :MedianAgeMarriage, :Divorce])
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
md" ### CausalInference.jl"

# ╔═╡ bae2fbb4-4a8a-47d3-b6c4-487019ab4482
let
	letters = ["A", "M", "D"]
	global f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="A -> M; A -> D; M -> D")

	global g1 = DiGraph(3)
	for (i, j) in [(1, 2), (2, 3), (1, 3)]
		add_edge!(g1, i, j)
	end
	
	arrow_size = [20+i for i in 1:ne(g1)]
	p = graphplot!(g1;
		layout=Stress(),
		edge_color=:grey,
		nlabels=repr.(letters[1:nv(g1)]),
		arrow_size=arrow_size)
	
	p.nlabels_offset[] = [Point2f(0.03, -0.01) for i in 1:nv(g1)]
	autolimits!(ax); hidedecorations!(ax)
	#hidespines!(ax); ax.aspect = DataAspect()

	ax = Axis(f[1, 2]; title="A -> M; A -> D")

	global g2 = DiGraph(3)
	for (i, j) in [(1, 2), (1, 3)]
		add_edge!(g2, i, j)
	end
	
	arrow_size = [20+i for i in 1:ne(g2)]
	p = graphplot!(g2;
		layout=Stress(),
		edge_color=:grey,
		nlabels=repr.(letters[1:nv(g2)]),
		arrow_size=arrow_size)
	p.nlabels_offset[] = [Point2f(0.03, -0.01) for i in 1:nv(g2)]
	autolimits!(ax); hidedecorations!(ax)
	#hidespines!(ax); ax.aspect = DataAspect()
	f

end

# ╔═╡ 5c87da91-ee1f-4d74-827b-efe107f25862
md" ##### Check d-separation between A, M and D"

# ╔═╡ ab5933f6-43d1-4fb0-9860-3a352bbb251e
dsep(g1, 1, 2, [], verbose=true)

# ╔═╡ 89801bde-db33-4d87-826a-9257f639126a
dsep(g1, 1, 2, [3], verbose=true)

# ╔═╡ 1ce3080e-c5c8-472b-a29d-eda3fc0dce99
dsep(g1, 1, 3, [2], verbose=true)

# ╔═╡ 0c0ba8f0-efc5-4f22-b2d5-41ba4125d221
dsep(g1, 2, 3, [1], verbose=true)

# ╔═╡ ad9edb34-64de-4ae7-aba6-6333421ac1bc
md" ##### Check d-separation between M and D"

# ╔═╡ 61dcc961-398f-4f95-bffb-4d51f9ea8fc6
dsep(g2, 2, 3, [])

# ╔═╡ 24aa10d0-c938-4834-8cbd-689ed1ca2cbe
md" ##### Check d-separation between M and D conditioned on A"

# ╔═╡ 2eb20607-232f-4a28-a21d-80e5c348ee1c
dsep(g2, 2, 3, [1])

# ╔═╡ 1a100134-2c6d-46f0-8ae3-2064393da8ab
md" #### Use WaffleHouses data"

# ╔═╡ 65dab224-d3d7-4c46-95b2-f23f4971a1bc
let
	A = waffles.MedianAgeMarriage
	M = waffles.Marriage
	D = waffles.Divorce
	global p = 0.01
	global X = [A M D]
	global df = DataFrame(A=A, M=M, D=D)
end;

# ╔═╡ 1a1a2192-a829-4f3f-be1d-95a6a00fbc9f
cov(X)

# ╔═╡ 2f77ef28-44fd-4ca2-9fbb-c7009131b0e9
@time est_g = pcalg(df, p, gausscitest)

# ╔═╡ 46f7f849-f8f4-4465-821d-35f26c0e41b7
est_g

# ╔═╡ 4debb427-9106-4eb4-9645-fce80b7ce65e
let
	f = Figure()
	ax = Axis(f[1, 1]; title="Estimated fraph from data.")

	letters = ["A", "M", "D"]
	
	colors = [:black for i in 1:nv(est_g)]
	colors[2] = :red
		
	arrow_size = [20+i for i in 1:ne(est_g)]

	p = graphplot!(est_g;
		layout=Stress(),
		node_color=:blue,
		edge_color=:grey,
		nlabels=repr.(letters[1:nv(est_g)]),
		nlabels_colors=colors,
		arrow_size=arrow_size)

	p.nlabels_offset[] = [Point2f(0.01, -0.03), Point2f(-0.04, -0.07), Point2f(0.01, -0.01)]
	autolimits!(ax); hidedecorations!(ax)
	#hidespines!(ax)
	#ax.aspect = DataAspect()
	f
end

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

# ╔═╡ 8718eb55-000e-446c-ae04-4ef550bab18d
md"##### Normal estimates:"

# ╔═╡ b36f2e78-2231-408b-844c-c4e237bae57d
if success(rc5_1s) && success(rc5_2s) && success(rc5_3s) 
	(s1, f1) = plot_model_coef([m5_1s, m5_2s, m5_3s], [:bA, :bM]; 
		title="Comparison of coefficient bA and bM ranges for models m5_1s, m5_2s and m5_3s.")
	f1
end

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─e875dcfc-fc57-11ea-27e5-c56f1f9d5370
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
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
# ╠═bae2fbb4-4a8a-47d3-b6c4-487019ab4482
# ╟─5c87da91-ee1f-4d74-827b-efe107f25862
# ╠═ab5933f6-43d1-4fb0-9860-3a352bbb251e
# ╠═89801bde-db33-4d87-826a-9257f639126a
# ╠═1ce3080e-c5c8-472b-a29d-eda3fc0dce99
# ╠═0c0ba8f0-efc5-4f22-b2d5-41ba4125d221
# ╟─ad9edb34-64de-4ae7-aba6-6333421ac1bc
# ╠═61dcc961-398f-4f95-bffb-4d51f9ea8fc6
# ╟─24aa10d0-c938-4834-8cbd-689ed1ca2cbe
# ╠═2eb20607-232f-4a28-a21d-80e5c348ee1c
# ╟─1a100134-2c6d-46f0-8ae3-2064393da8ab
# ╠═65dab224-d3d7-4c46-95b2-f23f4971a1bc
# ╠═1a1a2192-a829-4f3f-be1d-95a6a00fbc9f
# ╠═2f77ef28-44fd-4ca2-9fbb-c7009131b0e9
# ╠═46f7f849-f8f4-4465-821d-35f26c0e41b7
# ╠═4debb427-9106-4eb4-9645-fce80b7ce65e
# ╠═95849e5c-aa0f-4d6f-b618-51e8959496a8
# ╠═7fb18290-fde1-418b-8908-a8dbcc1a695b
# ╟─8718eb55-000e-446c-ae04-4ef550bab18d
# ╠═b36f2e78-2231-408b-844c-c4e237bae57d
