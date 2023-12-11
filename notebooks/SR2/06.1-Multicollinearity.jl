### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ 76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
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
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 6.1 - Multicollinearity."

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

# ╔═╡ 4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
md"### Julia code snippet 6.01"

# ╔═╡ 9f4b7ba8-802d-4686-bdf3-860381daed91
let
	N = 200

	global df1 = DataFrame(
	  nw = rand(Normal(), N),
	  tw = rand(Normal(), N)
	)
	df1.s = df1.tw + df1.nw
	scale_df_cols!(df1, [:s, :nw, :tw])
end

# ╔═╡ a3be015a-8fc5-4010-a038-87b0dacef222
begin
	prob = 0.1
	q = quantile(df1.s, 1-prob)
	selected_df = filter(row -> row.s > q, df1)
	unselected_df = filter(row -> row.s <= q, df1)

	cor(selected_df.nw, selected_df.tw)
end

# ╔═╡ dea4219b-e413-4109-a41b-758ea1ef0cc4
stan6_0 = "
data {
  int <lower=1> N;
  vector[N] nw;
  vector[N] tw;
}
parameters {
  real a;
  real aS;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + aS * nw;
  a ~ normal(0, 5.0);
  aS ~ normal(0, 1.0);
  sigma ~ exponential(1);
  tw ~ normal(mu, sigma);
}
";

# ╔═╡ 0c2f165e-a03d-4533-907b-c0a456ac6351
begin
	m6_0s = SampleModel("m6.0s", stan6_0)
	m_6_0_data = Dict(
	  :nw => selected_df.nw_s,
	  :tw => selected_df.tw_s,
	  :N => size(selected_df, 1)
	)
	rc6_0s = stan_sample(m6_0s, data=m_6_0_data)
	success(rc6_0s) && describe(m6_0s, [:a, :aS, :sigma])
end

# ╔═╡ c9f5c0d4-7381-413d-ac3b-d53fcd718204
if success(rc6_0s)
	post6_0s_df = read_samples(m6_0s, :dataframe)
	ms6_0s = model_summary(post6_0s_df,  [:a, :aS, :sigma])
end

# ╔═╡ 9663a596-fa19-4b32-8186-acffcd722695
let
	if success(rc6_0s)
		x = -2.0:0.01:3.0
		f = Figure(;size=default_figure_resolution)
		ax = Axis(f[1, 1]; xlabel="newsworthiness", ylabel="trustworthiness",
			title="Science distortion (selection distortion)")
		sel = scatter!(selected_df[:, :nw], selected_df[:, :tw], color=:blue, lab="selected")
		uns = scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, 
			lab="unselected")
		lines!(x, ms6_0s[:a, :mean] .+ ms6_0s[:aS, :mean] .* x)
	
		Legend(f[1, 2], [sel, uns], ["Selected", "Unselected"])
		
		f
	end
end

# ╔═╡ d1e551e0-075f-464b-a1ee-20db753e89c3
if success(rc6_0s)
	x_range = -2.0:0.01:3.0
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="newsworthiness", ylabel="trustworthiness",
		title="Science distortion")

	res = link(post6_0s_df, (r, x) -> r.a + r.aS * x, x_range)
	res = hcat(res...)
	m, l, u = estimparam(res)
	band!(x_range, l, u; color=(:grey, 0.3))

	sel = scatter!(selected_df[:, :nw], selected_df[:, :tw], color=:blue, lab="selected")
	uns = scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, 
		lab="unselected")
	lines!(x_range, ms6_0s[:a, :mean] .+ ms6_0s[:aS, :mean] .* x_range)
	f
end

# ╔═╡ 32defe65-4d99-48b9-be5f-8ef5f6c5ba67
md"### Julia code snippets 6.02"

# ╔═╡ 620f642e-cf8d-4e14-8a8a-c8174e27ad09
let
	N = 100
	global df2 = DataFrame(
		height = rand(Normal(10, 2), N),
		leg_prop = rand(Uniform(0.4, 0.5), N),
	)
	df2.leg_left = df2.leg_prop .* df2.height + rand(Normal(0, 0.02), N)
	df2.leg_right = df2.leg_prop .* df2.height + rand(Normal(0, 0.02), N)
end;

# ╔═╡ d7230c9d-208e-442c-8668-df7a009baa61
md"### Julia code snippet 6.03"

# ╔═╡ ce5081a1-9306-4250-b03d-0be07e0b45b5
stan6_1 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
  vector[N] LR;
}
parameters {
  real a;
  real bL;
  real bR;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + bL * LL + bR * LR;
  a ~ normal(10, 100);
  bL ~ normal(2, 10);
  bR ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

# ╔═╡ 41932d73-b9a3-4932-827c-2693d8a8f1f2
begin
	m6_1s = SampleModel("m6.1s", stan6_1)
	m_6_1_data = Dict(
	  :H => df2[:, :height],
	  :LL => df2[:, :leg_left],
	  :LR => df2[:, :leg_right],
	  :N => size(df2, 1)
	)
	rc6_1s = stan_sample(m6_1s, data=m_6_1_data)
	success(rc6_1s) && describe(m6_1s, [:a, :bL, :bR, :sigma])
end

# ╔═╡ 20afccf4-f9e1-4682-b81d-bbb28bedb239
md" ### Julia code snippet 6.04"

# ╔═╡ 2ae79c69-95a0-4863-ac08-e7b858b6ecb7
if success(rc6_1s)
	(s0, p0) = plot_model_coef([m6_1s], [:a, :bL, :bR, :sigma];
		title="Multicollinearity between bL and bR")
	p0
end

# ╔═╡ 878a3dbc-1fbd-45ab-946b-4d728f074cae
s0

# ╔═╡ 69941224-7440-4673-98db-19a75b63dab7
if success(rc6_1s)
	post6_1s_df = read_samples(m6_1s, :dataframe)
	ms6_1s = model_summary(post6_1s_df, [:a, :bL, :bR, :sigma])
end

# ╔═╡ a4bc4bc8-d981-4e4b-a428-77bda3d48dd5
md" ### Julia code snippets 6.05 and 6.06"

# ╔═╡ def404fb-e927-4d1b-b7a4-207315dd1913
let
	if success(rc6_1s)
	
		# Fit a linear regression
		m = lm(@formula(bL ~ bR), post6_1s_df)
	
		# Get coefficients from the model
		coefs = coef(m)

		f = Figure(;size=default_figure_resolution)
		
		ax = Axis(f[1, 1]; xlabel="bR", ylabel="bL", title="bL ~ bR")
		lines!(post6_1s_df[:, :bR], post6_1s_df[:, :bL])

		ax = Axis(f[1, 2]; xlabel="sum of bL and bR", ylabel="Density", title="Density bL + bR")
		density!(post6_1s_df.bR + post6_1s_df.bL)
			
		f
	end
end

# ╔═╡ f20df555-79a9-4b27-b634-5d0f6daea0f9
md" ### Julia code snippet 6.07"

# ╔═╡ 3aa5e3e2-f16a-4144-95d0-3b41e5adea35
stan6_2 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
}
parameters {
  real a;
  real bL;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + bL * LL;
  a ~ normal(10, 100);
  bL ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

# ╔═╡ 7b4b5dac-4192-493f-9373-3339ceb50b76
begin
	m6_2s = SampleModel("m6.2s", stan6_2)
	m_6_2_data = Dict(
	  :H => df2[:, :height],
	  :LL => df2[:, :leg_left],
	  :N => size(df2, 1)
	)
	rc6_2s = stan_sample(m6_2s, data=m_6_2_data)
	success(rc6_2s) && describe(m6_2s, [:a, :bL, :sigma])
end

# ╔═╡ b2d0baff-68bd-4a73-bf55-7e5d3dd8e497
md" ## Multicollinear milk."

# ╔═╡ 9ec9a4bf-3070-435e-9399-b0ee75758bf4
md" ### Julia code snippet 6.08"

# ╔═╡ 96bc6f4e-4730-49e1-ad0a-a37a7bbd5774
begin
	df4 = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df4.lmass = log.(df4.mass)
	df4 = filter(row -> !(row[:neocortex_perc] == "NA"), df4)
	df4.neocortex_perc = parse.(Float64, df4.neocortex_perc)
	scale_df_cols!(df4, [:kcal_per_g, :neocortex_perc, :lmass, :perc_fat, :perc_lactose])
	df5 = DataFrame()
	df5.K = df4.kcal_per_g_s
	df5.F = df4.perc_fat_s
	df5.L = df4.perc_lactose_s
	describe(df5)
end

# ╔═╡ f81204eb-0f80-42a9-93c7-e4bf4f5e0f03
md" ### Julia code snippet 6.09"

# ╔═╡ 59b1d119-35cd-4bc5-8ebc-e432b2804949
stan6_3 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] F; // Predictor
}
parameters {
 real a; // Intercept
 real bF; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bF ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bF * F;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ b91c9745-8510-4a81-8b17-cd06d15a2114
stan6_4 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] L; // Predictor
}
parameters {
 real a; // Intercept
 real bL; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bL ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bL * L;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 1d6c5de6-b5ef-442d-b724-24eca9cf5d84
begin
	m6_3s = SampleModel("m6.3s", stan6_3)
	m6_3_data = Dict(:N => size(df5, 1), :K => df5.K, :L => df5.L, :F => df5.F)
	rc6_3s = stan_sample(m6_3s, data=m6_3_data)
	success(rc6_2s) && describe(m6_3s, [:a, :bF, :sigma])
end

# ╔═╡ b7c81f74-c86a-4209-bbc1-e2e415fbdef3
begin
	m6_4s = SampleModel("m6.4s", stan6_4)
	m6_4_data = Dict(:N => size(df5, 1), :K => df5.K, :L => df5.L, :F => df5.F)
	rc6_4s = stan_sample(m6_4s, data=m6_4_data)
	success(rc6_4s) && describe(m6_4s, [:a, :bL, :sigma])
end

# ╔═╡ 2c33a5e2-fa00-4f0d-9da9-c43b22e38949
md" ### Julia code snippet 6.10"

# ╔═╡ d48cd6f8-c16e-455e-9ca2-66d5171efbec
stan6_5 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] L; // Predictor
 vector[N] F; // Predictor
}
parameters {
 real a; // Intercept
 real bL; // Slope (regression coefficients)
 real bF; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         //Priors
  bL ~ normal(0, 0.5);
  bF ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bL * L + bF * F;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 55f6e10a-66e0-409d-9052-a3e706e5ab33
begin
	m6_5s = SampleModel("m6.5s", stan6_5)
	m6_5_data = Dict(:N => size(df5, 1), :K => df5.K, :L => df5.L, :F => df5.F)
	rc6_5s = stan_sample(m6_5s, data=m6_5_data)
	success(rc6_5s) && describe(m6_5s, [:a, :bL, :bF, :sigma])
end

# ╔═╡ 4ede6b7c-b3c1-4c8f-9fa5-fe003f68199e
let
	if success(rc6_5s)
		(s0, p0) = plot_model_coef([m6_5s], [:a, :bL, :bF, :sigma];
			title="Multicollinearity between bL and bF")
		p0
	end
end

# ╔═╡ d0927331-80c4-42fd-9afe-893ffe2fd0ed
md" ### Julia code snippet 6.11"

# ╔═╡ 4c6c6163-0e2a-4ba0-9712-2480a5092fbb
pairplot(df5)

# ╔═╡ 941b7ad2-ee03-4089-b05b-df415eda890c
md" ## Julia code snippet 6.13"

# ╔═╡ 9b74bd87-10bb-4b63-b3ad-29a5734a68c3
let
	global df6 = DataFrame()
	df6.K = df4.kcal_per_g
	df6.F = df4.perc_fat
end

# ╔═╡ 23b567e0-f2a9-410f-8c9c-bf3f191e9172
function sim_coll(df::DataFrame, r::Float64=0.9)
	df_tmp = copy(df)
	v = sqrt( (1-r^2) * var(df_tmp.F))
	df_tmp.X = [rand(Normal(r * df_tmp.F[i], v), 1)[1] for i in 1:nrow(df_tmp)]
	m = lm(@formula(K ~ F + X), df_tmp)
	sqrt(diag(vcov(m))[2])
end

# ╔═╡ bef40760-df4c-4612-b672-9d6d07d6158b
function rep_sim_coll(df::DataFrame, r::Float64=0.9, n::Int=100)
	sv = [sim_coll(df, r) for i in 1:n]
	mean(sv)
end

# ╔═╡ 771c6cd6-5eae-4b53-a43b-b1921d52f3ac
sim_coll(df6)

# ╔═╡ fad88bb8-602a-49c6-94a5-c18571f79bba
rep_sim_coll(df6, 0.9, 5)

# ╔═╡ 563c3e43-3efe-47a9-bf72-0aadcea56b71
r_range = 0:0.01:0.99

# ╔═╡ a344c898-26a6-4e4c-8027-0f87a440e18a
stddev = [rep_sim_coll(df6, r) for r in r_range]

# ╔═╡ 14da1e75-bcbe-41f4-af28-b9cec3ffedd9
let
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1])
	scatter!(r_range, stddev)
	f
end

# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
# ╠═9f4b7ba8-802d-4686-bdf3-860381daed91
# ╠═a3be015a-8fc5-4010-a038-87b0dacef222
# ╠═dea4219b-e413-4109-a41b-758ea1ef0cc4
# ╠═0c2f165e-a03d-4533-907b-c0a456ac6351
# ╠═c9f5c0d4-7381-413d-ac3b-d53fcd718204
# ╠═9663a596-fa19-4b32-8186-acffcd722695
# ╠═d1e551e0-075f-464b-a1ee-20db753e89c3
# ╟─32defe65-4d99-48b9-be5f-8ef5f6c5ba67
# ╠═620f642e-cf8d-4e14-8a8a-c8174e27ad09
# ╟─d7230c9d-208e-442c-8668-df7a009baa61
# ╠═ce5081a1-9306-4250-b03d-0be07e0b45b5
# ╠═41932d73-b9a3-4932-827c-2693d8a8f1f2
# ╟─20afccf4-f9e1-4682-b81d-bbb28bedb239
# ╠═2ae79c69-95a0-4863-ac08-e7b858b6ecb7
# ╠═878a3dbc-1fbd-45ab-946b-4d728f074cae
# ╠═69941224-7440-4673-98db-19a75b63dab7
# ╟─a4bc4bc8-d981-4e4b-a428-77bda3d48dd5
# ╠═def404fb-e927-4d1b-b7a4-207315dd1913
# ╟─f20df555-79a9-4b27-b634-5d0f6daea0f9
# ╠═3aa5e3e2-f16a-4144-95d0-3b41e5adea35
# ╠═7b4b5dac-4192-493f-9373-3339ceb50b76
# ╠═4ede6b7c-b3c1-4c8f-9fa5-fe003f68199e
# ╟─b2d0baff-68bd-4a73-bf55-7e5d3dd8e497
# ╟─9ec9a4bf-3070-435e-9399-b0ee75758bf4
# ╠═96bc6f4e-4730-49e1-ad0a-a37a7bbd5774
# ╟─f81204eb-0f80-42a9-93c7-e4bf4f5e0f03
# ╠═59b1d119-35cd-4bc5-8ebc-e432b2804949
# ╠═b91c9745-8510-4a81-8b17-cd06d15a2114
# ╠═1d6c5de6-b5ef-442d-b724-24eca9cf5d84
# ╠═b7c81f74-c86a-4209-bbc1-e2e415fbdef3
# ╟─2c33a5e2-fa00-4f0d-9da9-c43b22e38949
# ╠═d48cd6f8-c16e-455e-9ca2-66d5171efbec
# ╠═55f6e10a-66e0-409d-9052-a3e706e5ab33
# ╟─d0927331-80c4-42fd-9afe-893ffe2fd0ed
# ╠═4c6c6163-0e2a-4ba0-9712-2480a5092fbb
# ╟─941b7ad2-ee03-4089-b05b-df415eda890c
# ╠═9b74bd87-10bb-4b63-b3ad-29a5734a68c3
# ╠═23b567e0-f2a9-410f-8c9c-bf3f191e9172
# ╠═bef40760-df4c-4612-b672-9d6d07d6158b
# ╠═771c6cd6-5eae-4b53-a43b-b1921d52f3ac
# ╠═fad88bb8-602a-49c6-94a5-c18571f79bba
# ╠═563c3e43-3efe-47a9-bf72-0aadcea56b71
# ╠═a344c898-26a6-4e4c-8027-0f87a440e18a
# ╠═14da1e75-bcbe-41f4-af28-b9cec3ffedd9
