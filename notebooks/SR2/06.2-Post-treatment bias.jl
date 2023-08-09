### A Pluto.jl notebook ###
# v0.19.26

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
	using Graphs
	using GraphViz
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 926ef957-0e39-403f-8eb4-a7f3824e74bc
md" ## 6.2 Post-treatment bias."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 30%);
	}
</style>
"""


# ╔═╡ 39d7aa5c-e2d7-454d-b738-713224adb209
md" ## Julia code snippet 6.13"

# ╔═╡ e83fb187-b43e-427e-b3f4-998be3dfe877
let
	N = 100
	global df = DataFrame(
	  :h0 => rand(Normal(10, 2), N),
	  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df[!, :fungus] = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df[!, :h1] = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
	df
end

# ╔═╡ f9a4d078-c6c7-4fae-bad2-75866d00d204
PRECIS(df)

# ╔═╡ e07e83b4-b338-4481-880a-330e55e2e041
md" ## Julia code snippet 6.14"

# ╔═╡ b1cd8dce-580c-43bf-a8b9-9b16b6685343
let
	sim_p = rand(LogNormal(0, 0.25), 10000)
	PRECIS(DataFrame(sim_p = sim_p))
end

# ╔═╡ 9dd4d597-938a-4dc2-9194-793bc790bf03
data = Dict(
  :N => nrow(df),
  :h0 => df[:, :h0],
  :h1 => df[:, :h1],
  :fungus => df[:, :fungus],
  :treatment => df[:, :treatment]
);

# ╔═╡ 5280379b-4ab2-4faa-9590-c86cb511be5a
md" ## Julia code snippet 6.15"

# ╔═╡ 8b924c58-5c42-4c54-89ad-7068108da47e
stan6_6 = "
data {
	int <lower=1> N;
	vector[N] h0;
	vector[N] h1;
}
parameters{
	real<lower=0> p;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	p ~ lognormal(0, 0.25);
	sigma ~ exponential(1);
	mu = h0 * p;
	h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 77314c2b-4a4f-4093-a9b6-1705a39a1b51
begin
	m6_6s = SampleModel("m6.6s", stan6_6)
	rc6_6s = stan_sample(m6_6s; data)
	success(rc6_6s) && describe(m6_6s, [:p, :sigma])
end

# ╔═╡ e3d37e82-f64c-4cb3-b386-a9c0ad4c6355
md" ## Julia code snippet 6.16"

# ╔═╡ c2405b1e-9821-45d8-bb36-fc6b53b7e86f
stan6_7 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
  vector[N] fungus;
}
parameters{
  real a;
  real bt;
  real bf;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ f7dc2040-d426-48f9-88a3-d5597974baaf
begin
	m6_7s = SampleModel("m6.7s", stan6_7)
	rc6_7s = stan_sample(m6_7s; data)
	success(rc6_7s) && describe(m6_7s, [:a, :bt, :bf, :sigma])
end

# ╔═╡ fa82efa6-54a3-483e-a839-69fdfbe7f060
if success(rc6_7s)
	post6_7s_df = read_samples(m6_7s, :dataframe)
	ms6_7s = model_summary(post6_7s_df, [:a, :bt, :bf, :sigma])
end

# ╔═╡ 8a89c661-d627-41fb-817c-42d0690db224
if success(rc6_7s)
	(s1, p1) = plot_model_coef([m6_7s], [:a, :bt, :bf, :sigma])
	p1
end

# ╔═╡ 62c9227f-7c4c-4a61-8749-6876a768e91e
md" ## Julia code snippet 6.17"

# ╔═╡ 6152acf1-7099-461a-a79f-173e1dd8e0f5
stan6_8 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
}
parameters{
  real a;
  real bt;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 0b720de7-310e-433e-a97f-12835b1b6477
begin
	m6_8s = SampleModel("m6.8s", stan6_8)
	rc6_8s = stan_sample(m6_8s; data)
	success(rc6_8s) && describe(m6_8s, [:a, :bt, :bf, :sigma])
end

# ╔═╡ b8628094-8f6b-4912-be22-0530962c30e8
if success(rc6_8s)
	post6_8s_df = read_samples(m6_8s, :dataframe)
	ms6_8s = model_summary(post6_8s_df, [:a, :bt, :sigma])
end

# ╔═╡ 0ecaf376-4b49-403d-b217-512cc9c30d67
let
	if success(rc6_7s) && success(rc6_8s)
		(s1, p1) = plot_model_coef([m6_7s, m6_8s], [:a, :bt, :bf, :sigma])
		p1
	end
end

# ╔═╡ 02e20922-0b13-44d3-a1c4-a5a6943fa305
md" ## Julia code snippet 6.18"

# ╔═╡ b97369d3-9101-4cc9-8d84-59035ed71b66
begin
	df_plants = copy(df)
	rename_dict = Dict(:treatment => :t, :fungus => :f)
	rename!(df_plants, rename_dict)
end

# ╔═╡ b762aab9-d3cd-4de3-aabb-5d927313e92f


# ╔═╡ 8df4dd7d-f616-42fc-af05-8f461d76c319
let
	g_dot_str = "DiGraph plant {h0 -> h1; f -> h1; t -> f;}"
	global dag_plants_1 = create_fci_dag("dag_plants", df_plants, g_dot_str)
	gvplot(dag_plants_1)
end

# ╔═╡ 3ea504e0-31fe-4474-8741-db4b9e819db7
md" ## Julia code snippet 6.19"

# ╔═╡ dbcfb526-5df1-4b62-b333-295f4c5414ce
dsep(dag_plants_1, :f, :h0)

# ╔═╡ 8ea6025b-dafd-40cb-be7f-90a591b65404
dsep(dag_plants_1, :t, :h0)

# ╔═╡ f8af2b9d-636c-41b3-8be4-b2b2320f9c8e
dsep(dag_plants_1, :t, :h1)

# ╔═╡ 467d5acb-1bca-407d-863e-d7258f002347
dsep(dag_plants_1, :t, :h1, [:f])

# ╔═╡ 1a2a51c7-5f7c-4ec5-8cb7-84eee88d6e39
md" ## Julia code snippet 6.20"

# ╔═╡ b9423001-0970-4b11-8ced-64cbb2e3b0d4
let
	N = 1000
	global df2 = DataFrame(
	  :h0 => rand(Normal(10, 2), N),
	  :t => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	m = rand(Bernoulli(), N)
	df2.m = [x == true ? 1 : 0 for x in m]
	df2.f = [rand(Binomial(1, 0.5 - 0.4 * df2[i, :t] + 0.4 * df2[i, :m]), 1)[1] for i in 1:N]
	df2.h1 = [df2[i, :h0] + rand(Normal(5 - 3 * df2[i, :m]), 1)[1] for i in 1:N]
	df2
end

# ╔═╡ 1fe1fb6c-68dc-481a-a70b-04e1e1df6fd4
let
	g_dot_str = "DiGraph plant_2 {h0 -> h1; t -> f;}"
	dag_plants_2 = create_fci_dag("dag_plants_2", df2, g_dot_str);
	gvplot(dag_plants_2; title_g="Observed model")
end

# ╔═╡ 2ddcd39f-6318-42cc-aad1-99c414536c7c
let
	g_dot_str = "DiGraph plant_2 {h0 -> h1; t -> f;}"
	dag_plants_2 = create_pcalg_gauss_dag("dag_plants_2", df2, g_dot_str);
	gvplot(dag_plants_2; title_g="Observed model")
end

# ╔═╡ Cell order:
# ╟─926ef957-0e39-403f-8eb4-a7f3824e74bc
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─39d7aa5c-e2d7-454d-b738-713224adb209
# ╠═e83fb187-b43e-427e-b3f4-998be3dfe877
# ╠═f9a4d078-c6c7-4fae-bad2-75866d00d204
# ╟─e07e83b4-b338-4481-880a-330e55e2e041
# ╠═b1cd8dce-580c-43bf-a8b9-9b16b6685343
# ╠═9dd4d597-938a-4dc2-9194-793bc790bf03
# ╟─5280379b-4ab2-4faa-9590-c86cb511be5a
# ╠═8b924c58-5c42-4c54-89ad-7068108da47e
# ╠═77314c2b-4a4f-4093-a9b6-1705a39a1b51
# ╟─e3d37e82-f64c-4cb3-b386-a9c0ad4c6355
# ╠═c2405b1e-9821-45d8-bb36-fc6b53b7e86f
# ╠═f7dc2040-d426-48f9-88a3-d5597974baaf
# ╠═fa82efa6-54a3-483e-a839-69fdfbe7f060
# ╠═8a89c661-d627-41fb-817c-42d0690db224
# ╟─62c9227f-7c4c-4a61-8749-6876a768e91e
# ╠═6152acf1-7099-461a-a79f-173e1dd8e0f5
# ╠═0b720de7-310e-433e-a97f-12835b1b6477
# ╠═b8628094-8f6b-4912-be22-0530962c30e8
# ╠═0ecaf376-4b49-403d-b217-512cc9c30d67
# ╟─02e20922-0b13-44d3-a1c4-a5a6943fa305
# ╠═b97369d3-9101-4cc9-8d84-59035ed71b66
# ╠═b762aab9-d3cd-4de3-aabb-5d927313e92f
# ╠═8df4dd7d-f616-42fc-af05-8f461d76c319
# ╟─3ea504e0-31fe-4474-8741-db4b9e819db7
# ╠═dbcfb526-5df1-4b62-b333-295f4c5414ce
# ╠═8ea6025b-dafd-40cb-be7f-90a591b65404
# ╠═f8af2b9d-636c-41b3-8be4-b2b2320f9c8e
# ╠═467d5acb-1bca-407d-863e-d7258f002347
# ╟─1a2a51c7-5f7c-4ec5-8cb7-84eee88d6e39
# ╠═b9423001-0970-4b11-8ced-64cbb2e3b0d4
# ╠═1fe1fb6c-68dc-481a-a70b-04e1e1df6fd4
# ╠═2ddcd39f-6318-42cc-aad1-99c414536c7c
