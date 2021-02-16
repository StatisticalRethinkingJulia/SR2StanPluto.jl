
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

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

begin
	m8_1s = SampleModel("m8.1s", stan8_1)
	rc8_1s = stan_sample(m8_1s; data)
	if success(rc8_1s)
		post8_1s_df = read_samples(m8_1s; output_format=:dataframe)
		PRECIS(post8_1s_df[:, [:a, :b, :sigma]])
	end
end

begin
	x = range(0, stop=1, length=50)
	plot(;leg=false)
	for i in 1:10:4000
		y = post8_1s_df.a[i] .+ post8_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1s_df.a) .+ mean(post8_1s_df.b) .* x, color=:darkblue)
end

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

begin
	m8_2s = SampleModel("m8.2s", stan8_2)
	rc8_2s = stan_sample(m8_2s; data)
	if success(rc8_2s)
		post8_2s_df = read_samples(m8_2s; output_format=:dataframe)
		PRECIS(post8_2s_df[:, [Symbol("a.1"), Symbol("a.2"), :b, :sigma]])
	end
end

compare([m8_1s, m8_2s], :waic) |> display

compare([m8_1s, m8_2s], :psis)  |> display

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

begin
	nt = read_samples(m8_2s)
	lp = nt.log_lik'
end;