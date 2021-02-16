
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-08-13-17s.jl"

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
	data = (N = size(df, 1), K = length(unique(df.cid)), 
		G = df.log_gdp_s, R = df.rugged_s, cid=df.cid)
	m8_1s = SampleModel("m8.1s", stan8_1)
	rc8_1s = stan_sample(m8_1s; data)
	if success(rc8_1s)
		post8_1s_df = read_samples(m8_1s; output_format=:dataframe)
		PRECIS(post8_1s_df[:, [:a, :b, :sigma]])
	end
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

begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data)
	if success(rc8_3s)
		post8_3s_df = read_samples(m8_3s; output_format=:dataframe)
		PRECIS(post8_3s_df[:, [Symbol("a.1"), Symbol("a.2"), 
					Symbol("b.1"), Symbol("b.2"), :sigma]])
	end
end

compare([m8_2s, m8_2s, m8_3s], :waic)

compare([m8_2s, m8_2s, m8_3s], :psis)

loo8_3s, loos8_3s, pk8_3s = psisloo(m8_3s)

pk_plot(pk8_3s)

begin
	nt8_3s = read_samples(m8_3s)
	xs = -0.1:0.01:1.1
	df_africa = df[df.cid .== 1, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_africa = nt8_3s.a[1,:]' .+ nt8_3s.b[1, :]' .* xs
	scatter(xs, mu_africa[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

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

begin
	df_other = df[df.cid .== 2, [:country, :log_gdp_s, :rugged_s, :cid]]
	mu_other = nt8_3s.a[2, :]' .+ nt8_3s.b[2, :]' .* xs
	scatter(xs, mu_other[:, 1:50], leg=false, markersize=1, 
		color=:blue, alpha=0.1)
end

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

plot(fig1, fig2, layout=(1, 2))

md" ## End of clip-08-13-17s.jl"

