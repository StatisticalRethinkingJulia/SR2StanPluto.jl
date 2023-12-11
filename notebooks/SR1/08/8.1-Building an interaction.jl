### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 140bb156-a292-4369-acf2-e15014d51adf
using Pkg

# ╔═╡ 4c1821f5-d854-4bd2-a1f6-951ad6530b78
begin
	using Distributions
	using StatsPlots
	using StatsBase
	using LaTeXStrings
	using CSV
	using DataFrames
	using LinearAlgebra
	using Random
	using StanSample
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ 6e067e1a-a09c-42f5-bcfe-666199da4876
md" ## Clip-08-01-06s.jl"

# ╔═╡ 6aac6dbb-0feb-4791-ad53-10ebc2f76021
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
	describe(df[:, [:log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ a7acb9d6-3fe7-428b-8ea4-b9578a7dc84f
stan8_1_1 = "
parameters {
	real a;
	real b;
}

model {
	a ~ normal(1, 1);
	b ~ normal(0, 1);
}
";

# ╔═╡ b06db312-75e9-4dd5-8245-cd84535f4a6d
begin
	m8_1_1s = SampleModel("m8.1.1s", stan8_1_1)
	rc8_1_1s = stan_sample(m8_1_1s)
	if success(rc8_1_1s)
		post8_1_1s_df = read_samples(m8_1_1s, :dataframe)
		describe(post8_1_1s_df[:, [:a, :b]])
	end
end

# ╔═╡ 6f3bfaea-b86a-4458-9eaf-18538e06723e
let
	x = 0:0.01:1
	global p1 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:20:4000
		y = post8_1_1s_df.a[i] .+ post8_1_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_1s_df.a) .+ mean(post8_1_1s_df.b) .* x, color=:darkblue)
end;

# ╔═╡ 85164715-3624-4f06-97a5-615a5f09af4d
stan8_1_2 = "
parameters {
	real a;
	real b;
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.1);
}
";

# ╔═╡ 56f4b606-bc49-4eb7-938a-9cd0e0523f9b
begin
	m8_1_2s = SampleModel("m8.1.2s", stan8_1_2)
	rc8_1_2s = stan_sample(m8_1_2s)
	if success(rc8_1_2s)
		post8_1_2s_df = read_samples(m8_1_2s, :dataframe)
		describe(post8_1_2s_df[:, [:a, :b]])
	end
end

# ╔═╡ 2f57edcc-da19-44a1-a081-e689ead59226
stan8_1_3 = "
parameters {
	real a;
	real b;
real sigma;
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.3);
	sigma ~ exponential(1);
}
";

# ╔═╡ d6b0ffde-f7d6-4575-9f44-6e6221439448
begin
	m8_1_3s = SampleModel("m8.1.3s", stan8_1_3)
	rc8_1_3s = stan_sample(m8_1_3s; data)
	if success(rc8_1_3s)
		post8_1_3s_df = read_samples(m8_1_3s, :dataframe)
		describe(post8_1_3s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 8d308ab7-e0d6-41d3-aa9c-748f24bbb465
r_hat = mean(df.rugged_s)

# ╔═╡ bec44281-4340-4243-9bdd-98ad0660476a
stan8_1_4 = "
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
	mu = a + b * (R - $r_hat);
}

model {
	a ~ normal(1, 1);
	b ~ normal(0, 1);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
";

# ╔═╡ eecda578-00bc-4707-a469-0c70cc584124
begin
	m8_1_4s = SampleModel("m8.1.4s", stan8_1_4)
	rc8_1_4s = stan_sample(m8_1_4s; data)
	if success(rc8_1_4s)
		post8_1_4s_df = read_samples(m8_1_4s, :dataframe)
		describe(post8_1_4s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ eaadfc6e-8c12-4925-9567-47d2f8aa9ef3
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

# ╔═╡ 66e324fb-3c93-4909-9c2b-57558adfc5d1
begin
	m8_1s = SampleModel("m8.1s", stan8_1)
	rc8_1s = stan_sample(m8_1s; data)
	if success(rc8_1s)
		post8_1s_df = read_samples(m8_1s, :dataframe)
		describe(post8_1s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 9713e7c6-8170-4064-801c-f9c940bb078e
begin
	x = range(0, stop=1, length=50)
	plot(;leg=false)
	for i in 1:10:4000
		y = post8_1s_df.a[i] .+ post8_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1s_df.a) .+ mean(post8_1s_df.b) .* x, color=:darkblue)
end

# ╔═╡ d5606f18-af1f-42b1-97d1-3c4404f140aa
begin
	p2 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_2s_df.a[i] .+ post8_1_2s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_2s_df.a) .+ mean(post8_1_2s_df.b) .* x, color=:darkblue)

	plot(p1, p2, layout=(1, 2))
end

# ╔═╡ ce65c4a5-fc99-4289-a85c-d8138f924ce3
begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_3s_df.a[i] .+ post8_1_3s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_3s_df.a) .+ mean(post8_1_3s_df.b) .* x, color=:darkblue)
end

# ╔═╡ e8ad10ca-30a3-4fc5-b79a-50636ae38530
begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_4s_df.a[i] .+ post8_1_4s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_4s_df.a) .+ mean(post8_1_4s_df.b) .* x, color=:darkblue)
end

# ╔═╡ c8b79400-bedc-4f6a-ac41-d32d81fbc214
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

# ╔═╡ 0a733393-cf87-4255-ad32-0f95f733a68a
begin
	m8_2s = SampleModel("m8.2s", stan8_2)
	rc8_2s = stan_sample(m8_2s; data)
	if success(rc8_2s)
		post8_2s_df = read_samples(m8_2s, :dataframe)
		describe(post8_2s_df[:, [Symbol("a.1"), Symbol("a.2"), :b, :sigma]])
	end
end

# ╔═╡ cdb5e797-9e37-4252-ba33-7f2a94f3550f
plot_models([m8_1s, m8_2s], [:a, Symbol("a.1"), Symbol("a.2"), :b, :sigma])

# ╔═╡ cfd7c68b-bd48-41c5-974c-9c747092c12d
compare([m8_1s, m8_2s], :waic)

# ╔═╡ 74bfab5a-0247-42bd-8ef4-77e670e00b79
plot_models([m8_1s, m8_2s], :waic)

# ╔═╡ 9228c435-25c6-400b-a9ed-9fde0869663b
compare([m8_1s, m8_2s], :psis)

# ╔═╡ f9327753-f3a2-4345-a2eb-724ef18e1c2e
md"
```

> PSIS(m8.1)
       PSIS    lppd  penalty  std_err
1 -188.6114 94.3057 2.755778 13.35391

> PSIS(m8.2)
       PSIS     lppd  penalty  std_err
1 -252.1136 126.0568 4.272533 15.29773

> compare( m8.1 , m8.2 )
       WAIC   SE dWAIC   dSE pWAIC weight
m8.2 -252.3 15.3   0.0    NA   4.3      1
m8.1 -188.7 13.3  63.5 15.15   2.7      0

> compare( m8.1 , m8.2, func=PSIS )
Some Pareto k values are high (>0.5). Set pointwise=TRUE to inspect individual points.
       PSIS    SE dPSIS   dSE pPSIS weight
m8.2 -252.1 15.28   0.0    NA   4.3      1
m8.1 -188.7 13.40  63.4 15.16   2.7      0
```
"

# ╔═╡ 787ec1b3-3e71-4871-ad78-c3befaeb7eec
l, ls, pk = psisloo(m8_1s)

# ╔═╡ 1ce41ea7-14ea-48dc-a3ed-518033eccb72
sum(ls)

# ╔═╡ a403fc42-2e62-4b33-930d-680d6b0a883b
begin
	nt8_2s = read_samples(m8_2s, :namedtuple)
	hpdi(nt8_2s.a[1,:] .- nt8_2s.a[2, :])
end

# ╔═╡ d537f2c7-5dfc-4125-95dd-a96b2ed5118d
pk_plot(pk)

# ╔═╡ 7f3cb4d6-4e6f-43f9-9822-de9eb035b8fb
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

# ╔═╡ 1ff403ba-aaf9-4228-b351-3c1b2c47aaf7
begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data)
	if success(rc8_3s)
		post8_3s_df = read_samples(m8_3s, :dataframe)
		describe(post8_3s_df[:, [Symbol("a.1"), Symbol("a.2"), 
					Symbol("b.1"), Symbol("b.2"), :sigma]])
	end
end

# ╔═╡ dab74868-20f9-4fe0-9a42-10586c2cdbf9
compare([m8_1s, m8_2s, m8_3s], :waic)

# ╔═╡ 0af2da85-ec2b-43b9-af74-eeaf96538603
plot_models([m8_1s, m8_2s, m8_3s], :waic)

# ╔═╡ 3e7e9975-fa5b-48ea-9742-eaa64c2f1d59
compare([m8_1s, m8_2s, m8_3s], :psis)

# ╔═╡ 547d29a2-0082-4e22-882f-6616223525fa
begin
	loo8_1s, loos8_1s, pk8_1s = psisloo(m8_1s)
end

# ╔═╡ 51322dcd-1428-4836-80a3-fa10bdbd2a75
pk_plot(pk8_1s)

# ╔═╡ 87fabc74-8dfc-4539-bd33-6b12c87ad761
begin
	loo8_2s, loos8_2s, pk8_2s = psisloo(m8_2s)
	pk_plot(pk8_2s)
end

# ╔═╡ f6f57bb2-de54-43f0-957d-7fdd4deeff58
begin
	loo8_3s, loos8_3s, pk8_3s = psisloo(m8_3s)
	pk_plot(pk8_3s)
end

# ╔═╡ 7ea2dc2c-7f96-402b-9d48-ace243f1078a
begin
	nt8_3s = read_samples(m8_3s, :namedtuple)
	xs = -0.1:0.01:1.1
	df_africa = df[df.cid .== 1, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_africa = nt8_3s.a[1,:]' .+ nt8_3s.b[1, :]' .* xs
	scatter(xs, mu_africa[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

# ╔═╡ dee8321f-c935-4cda-b147-19787019ec42
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

# ╔═╡ 474674f3-92ad-481b-96ae-7c08bd7fd8f2
begin
	df_other = df[df.cid .== 2, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_other = nt8_3s.a[2, :]' .+ nt8_3s.b[2, :]' .* xs
	scatter(xs, mu_other[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

# ╔═╡ ee4ccd82-03c7-4111-b237-1f4a7f0cf311
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

# ╔═╡ c53e6a5e-dae4-49f5-a295-1614c55f4ae1
plot(fig1, fig2, layout=(1, 2))

# ╔═╡ Cell order:
# ╠═140bb156-a292-4369-acf2-e15014d51adf
# ╠═4c1821f5-d854-4bd2-a1f6-951ad6530b78
# ╠═6e067e1a-a09c-42f5-bcfe-666199da4876
# ╠═6aac6dbb-0feb-4791-ad53-10ebc2f76021
# ╠═a7acb9d6-3fe7-428b-8ea4-b9578a7dc84f
# ╠═b06db312-75e9-4dd5-8245-cd84535f4a6d
# ╠═6f3bfaea-b86a-4458-9eaf-18538e06723e
# ╠═85164715-3624-4f06-97a5-615a5f09af4d
# ╠═56f4b606-bc49-4eb7-938a-9cd0e0523f9b
# ╠═d5606f18-af1f-42b1-97d1-3c4404f140aa
# ╠═2f57edcc-da19-44a1-a081-e689ead59226
# ╠═d6b0ffde-f7d6-4575-9f44-6e6221439448
# ╠═ce65c4a5-fc99-4289-a85c-d8138f924ce3
# ╠═8d308ab7-e0d6-41d3-aa9c-748f24bbb465
# ╠═bec44281-4340-4243-9bdd-98ad0660476a
# ╠═eecda578-00bc-4707-a469-0c70cc584124
# ╠═e8ad10ca-30a3-4fc5-b79a-50636ae38530
# ╠═eaadfc6e-8c12-4925-9567-47d2f8aa9ef3
# ╠═66e324fb-3c93-4909-9c2b-57558adfc5d1
# ╠═9713e7c6-8170-4064-801c-f9c940bb078e
# ╠═c8b79400-bedc-4f6a-ac41-d32d81fbc214
# ╠═0a733393-cf87-4255-ad32-0f95f733a68a
# ╠═cdb5e797-9e37-4252-ba33-7f2a94f3550f
# ╠═cfd7c68b-bd48-41c5-974c-9c747092c12d
# ╠═74bfab5a-0247-42bd-8ef4-77e670e00b79
# ╠═9228c435-25c6-400b-a9ed-9fde0869663b
# ╟─f9327753-f3a2-4345-a2eb-724ef18e1c2e
# ╠═787ec1b3-3e71-4871-ad78-c3befaeb7eec
# ╠═1ce41ea7-14ea-48dc-a3ed-518033eccb72
# ╠═a403fc42-2e62-4b33-930d-680d6b0a883b
# ╠═d537f2c7-5dfc-4125-95dd-a96b2ed5118d
# ╠═7f3cb4d6-4e6f-43f9-9822-de9eb035b8fb
# ╠═1ff403ba-aaf9-4228-b351-3c1b2c47aaf7
# ╠═dab74868-20f9-4fe0-9a42-10586c2cdbf9
# ╠═0af2da85-ec2b-43b9-af74-eeaf96538603
# ╠═3e7e9975-fa5b-48ea-9742-eaa64c2f1d59
# ╠═547d29a2-0082-4e22-882f-6616223525fa
# ╠═51322dcd-1428-4836-80a3-fa10bdbd2a75
# ╠═87fabc74-8dfc-4539-bd33-6b12c87ad761
# ╠═f6f57bb2-de54-43f0-957d-7fdd4deeff58
# ╠═7ea2dc2c-7f96-402b-9d48-ace243f1078a
# ╠═dee8321f-c935-4cda-b147-19787019ec42
# ╠═474674f3-92ad-481b-96ae-7c08bd7fd8f2
# ╠═ee4ccd82-03c7-4111-b237-1f4a7f0cf311
# ╠═c53e6a5e-dae4-49f5-a295-1614c55f4ae1
