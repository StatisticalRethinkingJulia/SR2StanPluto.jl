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
md" ## Figure 8.2s"

# ╔═╡ 8aaa4bcc-59a8-11eb-2003-f1213b116565
begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	df_africa = df[df.cont_africa .== 1, [:rgdppc_2000, :rugged]]
	dropmissing!(df_africa, :rgdppc_2000)
	dropmissing!(df_africa, :rugged)
	df_africa.log_gdp = log.(df_africa[:, :rgdppc_2000])
	scale!(df_africa, [:log_gdp, :rugged])
	PRECIS(df_africa)
end

# ╔═╡ 25ee6cd8-6a54-11eb-0a72-3fb09ee63b0e
begin
	df_non_africa = df[df.cont_africa .== 0, [:rgdppc_2000, :rugged]]
	dropmissing!(df_non_africa, :rgdppc_2000)
	dropmissing!(df_non_africa, :rugged)
	df_non_africa.log_gdp = log.(df_non_africa[:, :rgdppc_2000])
	scale!(df_non_africa, [:log_gdp, :rugged])
end;

# ╔═╡ d7d3e626-6a45-11eb-1820-a3ec98e556b1
stan8_0 = "
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

# ╔═╡ a3e7c070-6a46-11eb-072b-3943db854020
begin
	data1 = (N = size(df_africa, 1), G = df_africa.log_gdp_s,
		R = df_africa.rugged_s)
	m8_1s = SampleModel("m8.1s", stan8_0)
	rc8_1_1s = stan_sample(m8_1s; data=data1)
	if success(rc8_1_1s)
		post8_1_1s_df = read_samples(m8_1s; output_format=:dataframe)
		PRECIS(post8_1_1s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ cc11715a-6a54-11eb-1955-d38a021a3bb3
begin
	data2 = (N = size(df_non_africa, 1), G = df_non_africa.log_gdp_s,
		R = df_non_africa.rugged_s)
	rc8_1_2s = stan_sample(m8_1s; data=data2)
	if success(rc8_1_2s)
		post8_1_2s_df = read_samples(m8_1s; output_format=:dataframe)
		PRECIS(post8_1_2s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 1968b688-6a49-11eb-2dec-9986830b4a7e
begin
	p1 = plotbounds(
		df_africa, :rugged, :log_gdp,
		post8_1_1s_df, [:a, :b, :sigma];
		bounds=[:none, :hpdi],
		colors=[:orange, :lightblue],
		title="African nations",
		xlab="ruggedness",
		ylab="log GDP"
	)
	
	df_afr = df[df.cont_africa .== 1, [:country, :rgdppc_2000, :rugged]]
	df_afr = df_afr[df_afr.rugged .> 4, :]
	for (ind, country) in enumerate(df_afr.country)
		annotate!([([df_afr.rugged[ind]+0.3], [log(df_afr.rgdppc_2000[ind])+0.15],
			Plots.text(df_afr.country[ind], 6, :red, :right))])
	end
end

# ╔═╡ 0f36fb46-6a5d-11eb-2d34-91266e770493
begin
	p2 = plotbounds(
		df_non_africa, :rugged, :log_gdp,
		post8_1_2s_df, [:a, :b, :sigma];
		bounds=[:none, :hpdi],
		colors=[:orange, :lightblue],
		title="Non-African nations",
		xlab="ruggedness",
		ylab="log GDP"
	)


	df_na = df[:, [:country, :rgdppc_2000, :rugged]]
	dropmissing!(df_na, :rgdppc_2000)
	dropmissing!(df_na, :rugged)
	df_na = df_na[df_na.rugged .> 4, :]
	for (ind, country) in enumerate(df_na.country)
		println(country)
		if !(country in df_afr.country)
			annotate!([([df_na.rugged[ind]+0.3],
						[log(df_na.rgdppc_2000[ind])+0.15],
				Plots.text(df_na.country[ind], 6, :red, :right))])
		end
	end
	plot(p1, p2, layout=(1,2))
end

# ╔═╡ 45767e2e-6a63-11eb-3e12-354a7e32a374
md" ## End of figure 8.2s"

# ╔═╡ Cell order:
# ╟─51fc19b8-59a8-11eb-2214-15aca59b807b
# ╠═63ba08cc-59a8-11eb-0a0f-27efac60d779
# ╠═6db218c6-59a8-11eb-2a8b-7107354cf590
# ╠═8aaa4bcc-59a8-11eb-2003-f1213b116565
# ╠═25ee6cd8-6a54-11eb-0a72-3fb09ee63b0e
# ╠═d7d3e626-6a45-11eb-1820-a3ec98e556b1
# ╠═a3e7c070-6a46-11eb-072b-3943db854020
# ╠═cc11715a-6a54-11eb-1955-d38a021a3bb3
# ╠═1968b688-6a49-11eb-2dec-9986830b4a7e
# ╠═0f36fb46-6a5d-11eb-2d34-91266e770493
# ╟─45767e2e-6a63-11eb-3e12-354a7e32a374
