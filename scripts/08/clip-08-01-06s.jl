
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-08-01-06s.jl"

begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	data = (N = size(df, 1), G = df.log_gdp_s,
		R = df.rugged_s)
	PRECIS(df[:, [:log_gdp, :log_gdp_s, :rugged, :rugged_s]])
end

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

begin
	m8_1_1s = SampleModel("m8.1.1s", stan8_1_1)
	rc8_1_1s = stan_sample(m8_1_1s)
	if success(rc8_1_1s)
		post8_1_1s_df = read_samples(m8_1_1s; output_format=:dataframe)
		PRECIS(post8_1_1s_df[:, [:a, :b]])
	end
end

begin
	x = 0:0.01:1
	p1 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:20:4000
		y = post8_1_1s_df.a[i] .+ post8_1_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_1s_df.a) .+ mean(post8_1_1s_df.b) .* x, color=:darkblue)
end;

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

begin
	m8_1_2s = SampleModel("m8.1.2s", stan8_1_2)
	rc8_1_2s = stan_sample(m8_1_2s)
	if success(rc8_1_2s)
		post8_1_2s_df = read_samples(m8_1_2s; output_format=:dataframe)
		PRECIS(post8_1_2s_df[:, [:a, :b]])
	end
end

begin
	p2 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_2s_df.a[i] .+ post8_1_2s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_2s_df.a) .+ mean(post8_1_2s_df.b) .* x, color=:darkblue)

	plot(p1, p2, layout=(1, 2))
end

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

begin
	m8_1_3s = SampleModel("m8.1.3s", stan8_1_3)
	rc8_1_3s = stan_sample(m8_1_3s; data)
	if success(rc8_1_3s)
		post8_1_3s_df = read_samples(m8_1_3s; output_format=:dataframe)
		PRECIS(post8_1_3s_df[:, [:a, :b, :sigma]])
	end
end

begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_3s_df.a[i] .+ post8_1_3s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_3s_df.a) .+ mean(post8_1_3s_df.b) .* x, color=:darkblue)
end

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
	mu = a + b * (R - 0.125);
}

model {
	a ~ normal(1, 1);
	b ~ normal(0, 1);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
";

begin
	m8_1_4s = SampleModel("m8.1.4s", stan8_1_4)
	rc8_1_4s = stan_sample(m8_1_4s; data)
	if success(rc8_1_4s)
		post8_1_4s_df = read_samples(m8_1_4s; output_format=:dataframe)
		PRECIS(post8_1_4s_df[:, [:a, :b, :sigma]])
	end
end

begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_4s_df.a[i] .+ post8_1_4s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_4s_df.a) .+ mean(post8_1_4s_df.b) .* x, color=:darkblue)
end

md" ## End of clip-08-01-06s.jl"

