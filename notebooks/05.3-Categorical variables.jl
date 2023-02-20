### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ 76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

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
md" ## 5.3 - Categorical variables."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ e875dcfc-fc57-11ea-27e5-c56f1f9d5370
md"### Julia code snippet 5.1"

# ╔═╡ b26424bf-d206-4fb1-a2ab-222a8ffb80c7
md"### Julia code snippet 5.2"

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

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╟─e875dcfc-fc57-11ea-27e5-c56f1f9d5370
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─b26424bf-d206-4fb1-a2ab-222a8ffb80c7
# ╠═d65e98dc-fc58-11ea-25e1-9fab97b6125a
# ╠═a7698084-37d1-4677-89ff-183908a33fbe
# ╠═39f32370-ef8f-4918-9412-e4d8b6e8db38
# ╠═cb260a55-1eea-4d4a-930e-547820e2bac6
# ╠═63fbfe5a-5c5e-4dc8-aeca-742f017f105b
# ╠═8cdea9c8-7793-4bac-b77b-04b08898fc71
# ╠═cb454809-0dd7-4e79-adc6-7a2793090964
