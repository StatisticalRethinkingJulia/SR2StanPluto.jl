### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ a20974be-c658-11ec-3a53-a185aa9085cb
using Pkg

# ╔═╡ a280f7d2-6cda-4a71-92e5-8d2c8d0d31ef
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 3626cf55-ee2b-4363-95ee-75f2444a1542
begin
	using CairoMakie
	using StanSample
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 4a6f12f9-3b83-42b5-9fed-0296a5a603c6
md" ### 09.5-Care and feeding of Markov chains"

# ╔═╡ 2409c72b-cbcc-467f-9e81-23d83d2b703a
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

# ╔═╡ d84f1487-7eec-4a09-94d5-811449380cf5
stan9_2 = "
data {
	int n;
	vector[n] y;
}
parameters {
	real alpha;
	real<lower=0> sigma;
}
model {
	real mu;
	alpha ~ normal(0, 1000);
	sigma ~ exponential(0.0001);
	mu = alpha;
	y ~ normal(mu, sigma);
}";

# ╔═╡ eece4795-f36f-4f16-8132-e1fc672ebb8e
begin
	Random.seed!(123)
	data = (n=2, y=[-1, 1])
	m9_2s = SampleModel("m9.2s", stan9_2)
	rc = stan_sample(m9_2s; data)
	if success(rc)
		sdf = read_summary(m9_2s)
		post9_2s_df = read_samples(m9_2s, :dataframe)
	end
end

# ╔═╡ f67cbc42-1132-4626-93b0-82fe381a579e
describe(post9_2s_df[:, [:alpha, :sigma]])

# ╔═╡ 0e490fd5-d7f0-4c29-8d60-226c777b7609
sdf

# ╔═╡ 1853b58c-5fc6-4b9c-9500-efb8ea5cff0f
plot_chains(post9_2s_df, [:alpha])

# ╔═╡ 90ae205a-a73b-4725-b4fd-b490c5cb01b9
trankplot(post9_2s_df, "alpha"; n_eff=sdf[sdf.parameters .== :alpha, :ess][1])

# ╔═╡ db7bede1-41d7-4e62-baf2-6449b3cbd45e
stan9_3 = "
data {
	int n;
	vector[n] y;
}
parameters {
	real alpha;
	real<lower=0> sigma;
}
model {
	real mu;
	alpha ~ normal(0, 1);
	sigma ~ exponential(1);
	mu = alpha;
	y ~ normal(mu, sigma);
}";

# ╔═╡ ba6d8640-b472-4ab3-8700-c80fdd59d82b
begin
	Random.seed!(123)
	m9_3s = SampleModel("m9.3s", stan9_3)
	rc9_3s = stan_sample(m9_3s; data)
	if success(rc9_3s)
		sdf9_3s = read_summary(m9_3s)
		post9_3s_df = read_samples(m9_3s, :dataframe)
	end
end

# ╔═╡ 3a51c780-9cdd-4f81-96fa-85fa81bb37f5
sdf9_3s

# ╔═╡ c78b03ac-81ba-4a10-9f82-e4f6341a8d7a
describe(post9_3s_df[:, [:alpha, :sigma]])

# ╔═╡ 739831b7-27d4-4450-a3ed-8db96870e105
plot_chains(post9_3s_df, [:alpha, :sigma])

# ╔═╡ 2e06ce86-9431-4d94-94f5-eedca0d7b4b5
trankplot(post9_3s_df, "alpha"; n_eff=sdf9_3s[sdf9_3s.parameters .== :alpha, :ess][1])

# ╔═╡ 9eab4cb7-a30a-440c-a86a-7938df599285
stan9_4 = "
data {
	int n;
	vector[n] y;
}
parameters {
	real alpha;
	real beta;
	real<lower=0> sigma;
}
model {
	real mu;
	alpha ~ normal(0, 100);
	beta ~ normal(0, 1000);
	sigma ~ exponential(1);
	mu = alpha + beta;
	y ~ normal(mu, sigma);
}";

# ╔═╡ d75515b0-de24-4874-8edf-df2a86f24536
begin
	data9_4s = (n = 100, y = rand(Normal(0, 1), 100))
	m9_4s = SampleModel("m9.4s", stan9_4)
	rc9_4s = stan_sample(m9_4s; data=data9_4s)
	if success(rc9_4s)
		sdf9_4s = read_summary(m9_4s)
		post9_4s_df = read_samples(m9_4s, :dataframe)
	end
end

# ╔═╡ dfd5f45c-a913-4f43-b8f9-1f03643a97ca
sdf9_4s

# ╔═╡ 0162ead7-e9d7-4ddf-a453-9a9f1285fc31
describe(post9_4s_df[:, [:alpha, :beta, :sigma]])

# ╔═╡ cc947268-ef10-46f6-8bdf-6d2b42a70e10
plot_chains(post9_4s_df, [:alpha, :beta, :sigma])

# ╔═╡ 2dda23d9-d1b5-428e-b2e6-30692624d537
trankplot(post9_4s_df, "alpha"; n_eff=sdf9_4s[sdf9_4s.parameters .== :alpha, :ess][1])

# ╔═╡ 3206f276-877c-4f87-961b-3e7f22f351c9
trankplot(post9_4s_df, "beta"; n_eff=sdf9_4s[sdf9_4s.parameters .== :alpha, :ess][1])

# ╔═╡ 46ab44f5-26ae-4b2c-865e-0f0860e52a17
stan9_5 = "
data {
	int n;
	vector[n] y;
}
parameters {
	real alpha;
	real beta;
	real<lower=0> sigma;
}
model {
	real mu;
	alpha ~ normal(0, 10);
	beta ~ normal(0, 10);
	sigma ~ exponential(1);
	mu = alpha + beta;
	y ~ normal(mu, sigma);
}";

# ╔═╡ b9abe548-82fd-4e6e-aede-a91d19ce04d3
begin
	# Re-use data from m9_4s
	m9_5s = SampleModel("m9.5s", stan9_5)
	rc9_5s = stan_sample(m9_5s; data=data9_4s)
	if success(rc9_5s)
		sdf9_5s = read_summary(m9_5s)
		post9_5s_df = read_samples(m9_5s, :dataframe)
	end
end

# ╔═╡ 14b8e07c-a427-4ed5-93a2-22ea6b9a6d47
sdf9_5s

# ╔═╡ 4bfb188a-486c-42b8-9d47-d9eebdcb1e3d
describe(post9_5s_df[:, [:alpha, :beta, :sigma]])

# ╔═╡ 213010f0-aaa7-423a-bcff-4dfe6bbc34cd
plot_chains(post9_5s_df, [:alpha, :beta, :sigma])

# ╔═╡ e4b85093-d7ca-4323-959a-0a4e12769a65
trankplot(post9_5s_df, "alpha"; n_eff=sdf9_5s[sdf9_5s.parameters .== :alpha, :ess][1])

# ╔═╡ Cell order:
# ╟─4a6f12f9-3b83-42b5-9fed-0296a5a603c6
# ╠═2409c72b-cbcc-467f-9e81-23d83d2b703a
# ╠═a20974be-c658-11ec-3a53-a185aa9085cb
# ╠═a280f7d2-6cda-4a71-92e5-8d2c8d0d31ef
# ╠═3626cf55-ee2b-4363-95ee-75f2444a1542
# ╠═d84f1487-7eec-4a09-94d5-811449380cf5
# ╠═eece4795-f36f-4f16-8132-e1fc672ebb8e
# ╠═f67cbc42-1132-4626-93b0-82fe381a579e
# ╠═0e490fd5-d7f0-4c29-8d60-226c777b7609
# ╠═1853b58c-5fc6-4b9c-9500-efb8ea5cff0f
# ╠═90ae205a-a73b-4725-b4fd-b490c5cb01b9
# ╠═db7bede1-41d7-4e62-baf2-6449b3cbd45e
# ╠═ba6d8640-b472-4ab3-8700-c80fdd59d82b
# ╠═3a51c780-9cdd-4f81-96fa-85fa81bb37f5
# ╠═c78b03ac-81ba-4a10-9f82-e4f6341a8d7a
# ╠═739831b7-27d4-4450-a3ed-8db96870e105
# ╠═2e06ce86-9431-4d94-94f5-eedca0d7b4b5
# ╠═9eab4cb7-a30a-440c-a86a-7938df599285
# ╠═d75515b0-de24-4874-8edf-df2a86f24536
# ╠═dfd5f45c-a913-4f43-b8f9-1f03643a97ca
# ╠═0162ead7-e9d7-4ddf-a453-9a9f1285fc31
# ╠═cc947268-ef10-46f6-8bdf-6d2b42a70e10
# ╠═2dda23d9-d1b5-428e-b2e6-30692624d537
# ╠═3206f276-877c-4f87-961b-3e7f22f351c9
# ╠═46ab44f5-26ae-4b2c-865e-0f0860e52a17
# ╠═b9abe548-82fd-4e6e-aede-a91d19ce04d3
# ╠═14b8e07c-a427-4ed5-93a2-22ea6b9a6d47
# ╠═4bfb188a-486c-42b8-9d47-d9eebdcb1e3d
# ╠═213010f0-aaa7-423a-bcff-4dfe6bbc34cd
# ╠═e4b85093-d7ca-4323-959a-0a4e12769a65
