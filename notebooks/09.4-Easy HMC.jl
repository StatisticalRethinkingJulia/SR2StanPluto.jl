### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 09de4126-8123-4d29-9010-8f07ebae735a
using Pkg
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ a9d9fd82-5466-42e8-bb5a-204a2e706462
begin
	using CSV
	using Random
	using StatsBase
	using DataFrames
	using StatsPlots
	#using StatsFuns
	using LaTeXStrings
	using Parameters
	using CategoricalArrays
	using NamedTupleTools
	using ParetoSmoothedImportanceSampling
	using CairoMakie
	using StanSample
	using StatisticalRethinking: sr_datadir, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 61cca41a-cbae-11ec-2d57-a927f7018fca
md" ## Chapter 9.4: Easy HMC: Stan"

# ╔═╡ 88173221-7c74-479d-b838-34c9cb610c35
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(10px, 5%);
    	padding-right: max(10px, 37%);
	}
</style>
"""

# ╔═╡ 36f365f3-2c43-4ca4-9972-1238e55966c6
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 8d545ec8-0389-4c81-8a0d-653d35667b92
begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	df.cid = [df.cont_africa[i] == 1 ? 1 : 2 for i in 1:size(df, 1)]
	r̄ = mean(df.rugged_s)
	PRECIS(df[:, [:rgdppc_2000, :log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ 3c59c453-f71b-49ae-8f83-6ede555badb8
data = (N = size(df, 1), K = length(unique(df.cid)), 
		G = df.log_gdp_s, R = df.rugged_s, cid=df.cid);

# ╔═╡ cb19d2f8-85ac-4c86-a9ab-ea46a1084b93
stan8_3 = "
data {
	int N;
	int K;
	vector[N] G;
	vector[N] R;
	int cid[N];
}

parameters {
	vector[K] a;
	vector[K] b;
	real<lower=0> sigma;
}

transformed parameters {
	vector[N] mu;
	for (i in 1:N)
		mu[i] = a[cid[i]] + b[cid[i]] * (R[i] - $(r̄));
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.3);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
";

# ╔═╡ 2d3a0411-e16f-4b7a-9b7d-0cc398f8de59
begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data)
	if success(rc8_3s)
		post8_3s_df = read_samples(m8_3s, :dataframe)
	end
end;

# ╔═╡ 7e5a0f6c-ce4e-47a8-96e9-8bb546a2b6ab
md"### Code 8.14"

# ╔═╡ 706cb8f7-dfe9-4e58-98aa-fc8b313844e1
sdf = read_summary(m8_3s)[8:12, :]

# ╔═╡ 3caefd4e-0b4a-45da-8e64-81381073f0c6
plot_chains(post8_3s_df, [Symbol("a.1"), Symbol("a.2")])

# ╔═╡ 3020a796-dd21-43db-87dd-921529f67d1d
trankplot(post8_3s_df, "a.1"; n_eff=sdf[sdf.parameters .== Symbol("a[1]"), :ess][1])

# ╔═╡ e110f6ff-e7c9-40ef-9caa-149ba2651b70
plot_chains(post8_3s_df, [Symbol("b.1"), Symbol("b.2")])

# ╔═╡ 8024b4e5-722c-47fd-8649-34a9615305db
plot_chains(post8_3s_df, [:sigma])

# ╔═╡ Cell order:
# ╠═61cca41a-cbae-11ec-2d57-a927f7018fca
# ╠═88173221-7c74-479d-b838-34c9cb610c35
# ╠═09de4126-8123-4d29-9010-8f07ebae735a
# ╠═36f365f3-2c43-4ca4-9972-1238e55966c6
# ╠═a9d9fd82-5466-42e8-bb5a-204a2e706462
# ╠═8d545ec8-0389-4c81-8a0d-653d35667b92
# ╠═3c59c453-f71b-49ae-8f83-6ede555badb8
# ╠═cb19d2f8-85ac-4c86-a9ab-ea46a1084b93
# ╠═2d3a0411-e16f-4b7a-9b7d-0cc398f8de59
# ╟─7e5a0f6c-ce4e-47a8-96e9-8bb546a2b6ab
# ╠═706cb8f7-dfe9-4e58-98aa-fc8b313844e1
# ╠═3caefd4e-0b4a-45da-8e64-81381073f0c6
# ╠═3020a796-dd21-43db-87dd-921529f67d1d
# ╠═e110f6ff-e7c9-40ef-9caa-149ba2651b70
# ╠═8024b4e5-722c-47fd-8649-34a9615305db
