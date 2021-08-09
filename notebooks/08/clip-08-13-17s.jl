### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 63ba08cc-59a8-11eb-0a0f-27efac60d779
using Pkg, DrWatson

# ╔═╡ 6db218c6-59a8-11eb-2a8b-7107354cf590
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 51fc19b8-59a8-11eb-2214-15aca59b807b
md" ## Clip-08-13-17s.jl"

# ╔═╡ 8aaa4bcc-59a8-11eb-2003-f1213b116565
begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	df.cid = [df.cont_africa[i] == 1 ? 1 : 2 for i in 1:size(df, 1)]
	PRECIS(df[:, [:rgdppc_2000, :log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ e890c59c-6a68-11eb-0d33-4d52a21d0ccf
stan8_1 = "
data {
	int N;
	vector[N] G;
	vector[N] R;
}

parameters {
	real a;
	real b;
	real<lower=0> sigma;
}

transformed parameters {
	vector[N] mu;
	mu = a + b * (R - 0.125);
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

# ╔═╡ 8e815d5c-6a66-11eb-21dc-99734c31f4e1
begin
	data = (N = size(df, 1), K = length(unique(df.cid)), 
		G = df.log_gdp_s, R = df.rugged_s, cid=df.cid)
	m8_1s = SampleModel("m8.1s", stan8_1)
	rc8_1s = stan_sample(m8_1s; data)
	if success(rc8_1s)
		post8_1s_df = read_samples(m8_1s, :dataframe)
		PRECIS(post8_1s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 7e9e3674-6aea-11eb-3206-c1f775fe2d78
stan8_2 = "
data {
	int N;
	int K;
	vector[N] G;
	vector[N] R;
	int cid[N];
}

parameters {
	vector[K] a;
	real b;
	real<lower=0> sigma;
}

transformed parameters {
	vector[N] mu;
	for (i in 1:N)
		mu[i] = a[cid[i]] + b * (R[i] - 0.215);
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

# ╔═╡ 12db71d0-6aeb-11eb-341c-e3243ba74862
begin
	m8_2s = SampleModel("m8.2s", stan8_2)
	rc8_2s = stan_sample(m8_2s; data)
	if success(rc8_2s)
		post8_2s_df = read_samples(m8_2s, :dataframe)
		PRECIS(post8_2s_df[:, [Symbol("a.1"), Symbol("a.2"), :b, :sigma]])
	end
end

# ╔═╡ 81c10f50-6af6-11eb-291b-a9dabe8a297c
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

# ╔═╡ a83bde26-6af6-11eb-29ab-83fc8ed39292
begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data)
	if success(rc8_3s)
		post8_3s_df = read_samples(m8_3s, :dataframe)
		PRECIS(post8_3s_df[:, [Symbol("a.1"), Symbol("a.2"), 
					Symbol("b.1"), Symbol("b.2"), :sigma]])
	end
end

# ╔═╡ ba035d2a-6b2b-11eb-382d-313cc52aeb1a
compare([m8_1s, m8_2s, m8_3s], :waic)

# ╔═╡ a27a15de-7069-11eb-277c-2f2d7b4dfa8b
plot_models([m8_1s, m8_2s, m8_3s], :waic)

# ╔═╡ c1a6492a-6b2b-11eb-0f91-796cd055a303
compare([m8_1s, m8_2s, m8_3s], :psis)

# ╔═╡ 0721effc-6af7-11eb-1149-5f8050095c92
loo8_3s, loos8_3s, pk8_3s = psisloo(m8_3s)

# ╔═╡ 246d50ae-6af7-11eb-188e-5dd9a1382b32
pk_plot(pk8_3s)

# ╔═╡ 9331b922-6b14-11eb-0fa2-b7ac480b546c
begin
	nt8_3s = read_samples(m8_3s)
	xs = -0.1:0.01:1.1
	df_africa = df[df.cid .== 1, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_africa = nt8_3s.a[1,:]' .+ nt8_3s.b[1, :]' .* xs
	scatter(xs, mu_africa[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

# ╔═╡ d60aaa22-6b2c-11eb-1e68-f1609c237a37
begin
	mlu_a = meanlowerupper(mu_africa)
	fig1 = plot(;ylims=(0.7, 1.4), xlab="ruggedness (standardized)",
		ylab="log GDP (standardaized)", title="African nations")
	scatter!(df_africa.rugged_s, df_africa.log_gdp_s, leg=false)
	plot!(xs, mlu_a.mean,
		ribbon=(mlu_a.mean .- mlu_a.lower, mlu_a.upper - mlu_a.mean))
	df_a = df_africa[df_africa.rugged_s .> 0.5, :]
	for r in eachrow(df_a)
		annotate!([(r.rugged_s+0.04, r.log_gdp_s+0.015,
			Plots.text(r.country, 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ a2bcceb8-6b2f-11eb-03cc-b54f771a9174
begin
	df_other = df[df.cid .== 2, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_other = nt8_3s.a[2, :]' .+ nt8_3s.b[2, :]' .* xs
	scatter(xs, mu_other[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

# ╔═╡ dea1e592-6b33-11eb-2497-df10350753a0
begin
	mlu_o = meanlowerupper(mu_other, (0.055, 0.945))
	fig2 = plot(;ylims=(0.7, 1.4), xlab="ruggedness (standardized)",
		ylab="log GDP (standardaized)", title="Non-African nations")

	scatter!(df_other.rugged_s, df_other.log_gdp_s, leg=false)
	plot!(xs, mlu_o.mean,
		ribbon=(mlu_o.mean .- mlu_o.lower, mlu_o.upper - mlu_o.mean))
	df_o = df_other[df_other.rugged_s .> 0.6, :]
	for r in eachrow(df_o)
		annotate!([(r.rugged_s+0.04, r.log_gdp_s+0.015,
			Plots.text(r.country, 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ 9cd48a0e-6b34-11eb-05a5-939aed1ad460
plot(fig1, fig2, layout=(1, 2))

# ╔═╡ 45767e2e-6a63-11eb-3e12-354a7e32a374
md" ## End of clip-08-13-17s.jl"

# ╔═╡ Cell order:
# ╟─51fc19b8-59a8-11eb-2214-15aca59b807b
# ╠═63ba08cc-59a8-11eb-0a0f-27efac60d779
# ╠═6db218c6-59a8-11eb-2a8b-7107354cf590
# ╠═8aaa4bcc-59a8-11eb-2003-f1213b116565
# ╠═e890c59c-6a68-11eb-0d33-4d52a21d0ccf
# ╠═8e815d5c-6a66-11eb-21dc-99734c31f4e1
# ╠═7e9e3674-6aea-11eb-3206-c1f775fe2d78
# ╠═12db71d0-6aeb-11eb-341c-e3243ba74862
# ╠═81c10f50-6af6-11eb-291b-a9dabe8a297c
# ╠═a83bde26-6af6-11eb-29ab-83fc8ed39292
# ╠═ba035d2a-6b2b-11eb-382d-313cc52aeb1a
# ╠═a27a15de-7069-11eb-277c-2f2d7b4dfa8b
# ╠═c1a6492a-6b2b-11eb-0f91-796cd055a303
# ╠═0721effc-6af7-11eb-1149-5f8050095c92
# ╠═246d50ae-6af7-11eb-188e-5dd9a1382b32
# ╠═9331b922-6b14-11eb-0fa2-b7ac480b546c
# ╠═d60aaa22-6b2c-11eb-1e68-f1609c237a37
# ╠═a2bcceb8-6b2f-11eb-03cc-b54f771a9174
# ╠═dea1e592-6b33-11eb-2497-df10350753a0
# ╠═9cd48a0e-6b34-11eb-05a5-939aed1ad460
# ╟─45767e2e-6a63-11eb-3e12-354a7e32a374
