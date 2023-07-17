### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 2fee026b-f071-4c3e-bc5b-9823177d9c4d
using Pkg

# ╔═╡ 99068a6b-1f0c-4176-86f2-7dff4b47a45b
begin
	using CSV
	using Random
	using StatsBase
	using DataFrames
	using StatsPlots
	using StatsFuns
	using LaTeXStrings
	using ParetoSmoothedImportanceSampling
	using StanSample
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ f2d9ff1d-11c6-4fd7-8f6e-411072999d42
md"## 8.2 Symmetry of interations"

# ╔═╡ ecd48461-e555-48f6-bde0-60f0a5366eb5
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


# ╔═╡ 79ccc9cc-5b6e-4dfe-8eec-e5bc3b0c7de7
	data = (N = size(df, 1), K = length(unique(df.cid)), 
		G = df.log_gdp_s, R = df.rugged_s, cid=df.cid);

# ╔═╡ 94bab302-1e91-4852-b7b2-14d46abbc891
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
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(G[i] | mu[i], sigma);
}
";

# ╔═╡ ee257c07-7624-4cd9-9c31-1741fec44eaf
begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data)
	if success(rc8_3s)
		post8_3s_df = read_samples(m8_3s, :dataframe)
	end
end;

# ╔═╡ 6f9040ff-b65a-4859-b393-ddcf0983e0fe
md"### Code 8.14"

# ╔═╡ 885619ae-7f62-4c46-8954-151bd23e7836
PRECIS(post8_3s_df[:, [Symbol("a.1"), Symbol("a.2"), 
	Symbol("b.1"), Symbol("b.2"), :sigma]])

# ╔═╡ f416b40e-84a4-4d0c-92dc-8284472fbe48
md"### Code 8.15"

# ╔═╡ e378e58f-3476-458b-875c-ceed69026c13
md"### Code 8.16"

# ╔═╡ 965017a8-daf7-433a-8b7f-b7c4b942bec8
md"### Code 8.17"

# ╔═╡ 7cd45d1d-f93f-4947-83aa-4dea9d82b633
let
	# build data
	global df3 = post8_3s_df
	rugged_seq = range(-0.2, 1.2, length=30)
	africa     = link(df3, (r, x) -> r["a.1"] + r["b.1"]*(x-r̄), rugged_seq)
	africa     = hcat(africa...)'
	not_africa = link(df3, (r, x) -> r["a.2"] + r["b.2"]*(x-r̄), rugged_seq)
	not_africa = hcat(not_africa...)'
	
	μₐ = mean.(eachrow(africa))
	μₙ = mean.(eachrow(not_africa))
	PIₐ = PI.(eachrow(africa))
	PIₐ = vcat(PIₐ'...)
	PIₙ = PI.(eachrow(not_africa))
	PIₙ = vcat(PIₙ'...);
	
	# plot Africa, cid=1
	p1 = plot(xlab="ruggedness (std)", ylab="log GDP",
		title="African nations", leg=false)
	scatter!(df.rugged_s[df.cid.==1], df.log_gdp_s[df.cid.==1], c=:blue)
	plot!(rugged_seq, [μₐ, μₐ], c=:blue, fillrange=PIₐ, fillalpha=0.2)
	
	# plot non Africa, cid=2
	p2 = plot(xlab="ruggedness (std)", ylab="log GDP",
		title="Non-African nations", leg=false)
	scatter!(df.rugged_s[df.cid.==2], df.log_gdp_s[df.cid.==2], c=:white)
	plot!(rugged_seq, [μₙ, μₙ], c=:black, fillrange=PIₙ, fillalpha=0.2)
	
	plot(p1, p2, size=(800, 400))
end

# ╔═╡ 15726386-60f3-43af-b3fd-b63af456f9f7
md"### Code 8.18"

# ╔═╡ b4479775-7eda-485f-8fb7-93e471a5fcc2
let
	rugged_seq = range(-0.2, 1.2, length=30)
	μA = link(df3, (r, x) -> r["a.1"] + r["b.1"]*(x-r̄), rugged_seq)
	μA = vcat(μA'...)
	μN = link(df3, (r, x) -> r["a.2"] + r["b.2"]*(x-r̄), rugged_seq)
	μN = vcat(μN'...)
	delta = μA .- μN;
	
	# +
	μ = mean.(eachrow(delta))
	PI_v = PI.(eachrow(delta))
	PI_v = vcat(PI_v'...)
	
	plot(xlab="ruggedness", ylab="expected difference log GDP", leg=false)
	plot!(rugged_seq, [μ, μ], c=:blue, fillrange=PI_v, fillalpha=0.2)
	hline!([0.0], s=:dash, c=:black)
	annotate!([
	    (0.0, 0.03, ("Africa higher GPD", 10)),
	    (0.0, -0.03, ("Africa lower GPD", 10)),
	])
end

# ╔═╡ Cell order:
# ╟─f2d9ff1d-11c6-4fd7-8f6e-411072999d42
# ╠═2fee026b-f071-4c3e-bc5b-9823177d9c4d
# ╠═99068a6b-1f0c-4176-86f2-7dff4b47a45b
# ╠═ecd48461-e555-48f6-bde0-60f0a5366eb5
# ╠═79ccc9cc-5b6e-4dfe-8eec-e5bc3b0c7de7
# ╠═94bab302-1e91-4852-b7b2-14d46abbc891
# ╠═ee257c07-7624-4cd9-9c31-1741fec44eaf
# ╟─6f9040ff-b65a-4859-b393-ddcf0983e0fe
# ╠═885619ae-7f62-4c46-8954-151bd23e7836
# ╟─f416b40e-84a4-4d0c-92dc-8284472fbe48
# ╟─e378e58f-3476-458b-875c-ceed69026c13
# ╟─965017a8-daf7-433a-8b7f-b7c4b942bec8
# ╠═7cd45d1d-f93f-4947-83aa-4dea9d82b633
# ╟─15726386-60f3-43af-b3fd-b63af456f9f7
# ╠═b4479775-7eda-485f-8fb7-93e471a5fcc2
