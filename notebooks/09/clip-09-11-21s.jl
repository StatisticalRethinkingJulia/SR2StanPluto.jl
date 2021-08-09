### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 0b19c578-762b-11eb-34b6-01e80cef1406
using Pkg, DrWatson

# ╔═╡ 3f814e9e-762b-11eb-1340-91617ca7b58a
begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking 
end

# ╔═╡ af1efcf4-779a-11eb-0d62-e3c63876a09b
md" ## Clip-09-11-21s.jl"

# ╔═╡ cb88768a-779b-11eb-1a4e-99f92ded29ca
begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	df.cid = [df.cont_africa[i] == 1 ? 1 : 2 for i in 1:size(df, 1)]

	data = (N = size(df, 1), K = length(unique(df.cid)), 
		G = df.log_gdp_s, R = df.rugged_s, cid=df.cid)

	PRECIS(df[:, [:rgdppc_2000, :log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ e37331ea-779b-11eb-1b02-1fdb61aae124
stan9_1 = "
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
		mu[i] = a[cid[i]] + b[cid[i]] * (R[i] - 0.215);
}
model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.3);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(G[i] | mu[i], sigma);
}
";

# ╔═╡ 3fafc7fe-762b-11eb-37da-254b6d75f5ca
begin
	m9_1s = SampleModel("m9.1s", stan9_1;
		method=StanSample.Sample(num_samples=500))
	
	rc9_1s = stan_sample(m9_1s; data)

	if success(rc9_1s)
		m9_1s_df = read_samples(m9_1s, :dataframe)
		params = [Symbol("a.1"), Symbol("a.2"), Symbol("b.1"), Symbol("b.2")]
		PRECIS(m9_1s_df[:, append!(params, [:sigma])])
	end
end

# ╔═╡ 15d035d6-779d-11eb-0393-e54390b408dd
begin
	dfs = read_summary(m9_1s)
	dfs[8:12, :]
end

# ╔═╡ b4d020b8-762d-11eb-167a-9fd79d948647
begin
	figs_a = trankplot(m9_1s, :a)
	plot(figs_a..., layout=(1, 2))
end

# ╔═╡ 28a050e8-7857-11eb-18c8-bd4ef6695f24
begin
	figs_b = trankplot(m9_1s, :b)
	plot(figs_b..., layout=(1, 2))
end

# ╔═╡ 369b3044-7935-11eb-3ae7-abe15e53c060
begin
	fig = trankplot(m9_1s, :sigma)
	plot(fig...)
end

# ╔═╡ ca61c622-779a-11eb-1292-3f272953867f
md" ## End of clip-09-11-21s.jl"

# ╔═╡ Cell order:
# ╠═af1efcf4-779a-11eb-0d62-e3c63876a09b
# ╠═0b19c578-762b-11eb-34b6-01e80cef1406
# ╠═3f814e9e-762b-11eb-1340-91617ca7b58a
# ╠═cb88768a-779b-11eb-1a4e-99f92ded29ca
# ╠═e37331ea-779b-11eb-1b02-1fdb61aae124
# ╠═3fafc7fe-762b-11eb-37da-254b6d75f5ca
# ╠═15d035d6-779d-11eb-0393-e54390b408dd
# ╠═b4d020b8-762d-11eb-167a-9fd79d948647
# ╠═28a050e8-7857-11eb-18c8-bd4ef6695f24
# ╠═369b3044-7935-11eb-3ae7-abe15e53c060
# ╟─ca61c622-779a-11eb-1292-3f272953867f
