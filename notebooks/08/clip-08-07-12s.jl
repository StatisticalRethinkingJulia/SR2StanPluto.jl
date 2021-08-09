### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 63ba08cc-59a8-11eb-0a0f-27efac60d779
using Pkg, DrWatson

# ╔═╡ 6db218c6-59a8-11eb-2a8b-7107354cf590
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 51fc19b8-59a8-11eb-2214-15aca59b807b
md" ## Clip-08-07-12s.jl"

# ╔═╡ f346a9a1-de24-40ef-bf2f-eb046ed800d5
@quickactivate "StatisticalRethinkingStan"

# ╔═╡ 8aaa4bcc-59a8-11eb-2003-f1213b116565
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
	PRECIS(df[:, [:log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ 4c3738f0-ba84-456a-a53f-c2690be9c077
df[1:8, [:log_gdp, :rugged, :cont_africa, :log_gdp_s, :rugged_s]]

# ╔═╡ 60053fa4-f1f9-4754-825e-170a095a284d
md"
```
8×5 DataFrame
 Row │ log_gdp  rugged   cont_africa  log_gdp_std  rugged_std
     │ Float64  Float64  Int64        Float64      Float64
─────┼────────────────────────────────────────────────────────
   1 │ 7.49261    0.858            1     1.00276    0.138342
   2 │ 6.43238    1.78             1     0.860869   0.287004
   3 │ 6.86612    0.141            1     0.918918   0.0227346
   4 │ 6.90617    0.236            1     0.924278   0.0380522
   5 │ 8.9493     0.181            1     1.19772    0.0291841
   6 │ 7.04582    0.197            1     0.942968   0.0317639
   7 │ 7.36241    0.224            1     0.985338   0.0361174
   8 │ 7.54046    0.515            1     1.00917    0.0830377
```"

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
	m8_1s = SampleModel("m8.1s", stan8_1)
	rc8_1s = stan_sample(m8_1s; data)
	if success(rc8_1s)
		post8_1s_df = read_samples(m8_1s, :dataframe)
		PRECIS(post8_1s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 04a39568-6a6c-11eb-19ea-f55be3914a51
begin
	x = range(0, stop=1, length=50)
	plot(;leg=false)
	for i in 1:10:4000
		y = post8_1s_df.a[i] .+ post8_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1s_df.a) .+ mean(post8_1s_df.b) .* x, color=:darkblue)
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

# ╔═╡ 8b889740-7142-11eb-3d74-b1b9dc6f3282
plot_models([m8_1s, m8_2s], [:a, Symbol("a.1"), Symbol("a.2"), :b, :sigma])

# ╔═╡ 4a5070f8-6af4-11eb-31ca-a7a3ae504821
compare([m8_1s, m8_2s], :waic)

# ╔═╡ 4fa4b38c-7069-11eb-1202-7552c5dcd671
plot_models([m8_1s, m8_2s], :waic)

# ╔═╡ f6c60a90-6e29-11eb-1133-99ad7b37e0af
compare([m8_1s, m8_2s], :psis)

# ╔═╡ 7244381c-6e2b-11eb-2373-1d6c5d27de80
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

# ╔═╡ dad9e286-6e2c-11eb-1e89-9f3cb4e2d06b
l, ls, pk = psisloo(m8_1s)

# ╔═╡ 133600ce-6e2d-11eb-3030-0bad514887eb
sum(ls)

# ╔═╡ 943f0ba2-6af4-11eb-2698-b3e2be715e88
begin
	nt8_2s = read_samples(m8_2s)
	hpdi(nt8_2s.a[1,:] .- nt8_2s.a[2, :])
end

# ╔═╡ 45767e2e-6a63-11eb-3e12-354a7e32a374
md" ## End of clip-08-07-12s.jl"

# ╔═╡ Cell order:
# ╟─51fc19b8-59a8-11eb-2214-15aca59b807b
# ╠═63ba08cc-59a8-11eb-0a0f-27efac60d779
# ╠═f346a9a1-de24-40ef-bf2f-eb046ed800d5
# ╠═6db218c6-59a8-11eb-2a8b-7107354cf590
# ╠═8aaa4bcc-59a8-11eb-2003-f1213b116565
# ╠═4c3738f0-ba84-456a-a53f-c2690be9c077
# ╟─60053fa4-f1f9-4754-825e-170a095a284d
# ╠═e890c59c-6a68-11eb-0d33-4d52a21d0ccf
# ╠═8e815d5c-6a66-11eb-21dc-99734c31f4e1
# ╠═04a39568-6a6c-11eb-19ea-f55be3914a51
# ╠═7e9e3674-6aea-11eb-3206-c1f775fe2d78
# ╠═12db71d0-6aeb-11eb-341c-e3243ba74862
# ╠═8b889740-7142-11eb-3d74-b1b9dc6f3282
# ╠═4a5070f8-6af4-11eb-31ca-a7a3ae504821
# ╠═4fa4b38c-7069-11eb-1202-7552c5dcd671
# ╠═f6c60a90-6e29-11eb-1133-99ad7b37e0af
# ╟─7244381c-6e2b-11eb-2373-1d6c5d27de80
# ╠═dad9e286-6e2c-11eb-1e89-9f3cb4e2d06b
# ╠═133600ce-6e2d-11eb-3030-0bad514887eb
# ╠═943f0ba2-6af4-11eb-2698-b3e2be715e88
# ╟─45767e2e-6a63-11eb-3e12-354a7e32a374
