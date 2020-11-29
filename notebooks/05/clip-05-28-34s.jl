### A Pluto.jl notebook ###
# v0.12.14

using Markdown
using InteractiveUtils

# ╔═╡ b78a501c-fda3-11ea-06bb-5175ada30398
using Pkg, DrWatson

# ╔═╡ b78a9662-fda3-11ea-25be-871b1258e163
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ b0b04904-fda3-11ea-2a13-efbb8da05490
md"## Clip-05-28-34s.jl"

# ╔═╡ b78b1934-fda3-11ea-119c-5398009c1521
md"### snippet 5.28 - 5.31"

# ╔═╡ b7997a6a-fda3-11ea-325a-7d0fc706cdff
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df.lmass = log.(df.mass)
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 9fe858dc-fda3-11ea-38c8-df4b1d6e8419
stan_5_5_draft = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}
parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 1);           //Priors
  bN ~ normal(0, 1);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ d65e8eea-fda3-11ea-0f78-6d8a183f5818
md"##### Define the SampleModel, etc."

# ╔═╡ d65ec40a-fda3-11ea-2e15-2f55dd308dd9
begin
	m5_5_drafts = SampleModel("m5.5.draft", stan_5_5_draft);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df.neocortex_perc_s,
		"K" => df.kcal_per_g_s);
	rc5_5_drafts = stan_sample(m5_5_drafts, data=m5_5_data)
end;

# ╔═╡ 407845b4-fd4a-11ea-1ed5-65581b68ccda
if success(rc5_5_drafts)
  post5_5_drafts_df = read_samples(m5_5_drafts; output_format=:dataframe)
end;

# ╔═╡ d8d01f36-fda3-11ea-2b26-59b86a4e23ca
md"## Result rethinking."

# ╔═╡ d8d1b594-fda3-11ea-2bae-e1be39ef751e
rethinking = "
        mean   sd  5.5% 94.5%
  a     0.09 0.24 -0.28  0.47
  bN    0.16 0.24 -0.23  0.54
  sigma 1.00 0.16  0.74  1.26
";

# ╔═╡ d8d8a4e4-fda3-11ea-3bda-0b8c90e63d65
Particles(post5_5_drafts_df)

# ╔═╡ d8db84ca-fda3-11ea-35c2-1f671cea8a32
if success(rc5_5_drafts)
  p = plot(title="m5.5.drafts: a ~ Normal(0, 1), bN ~ Normal(0, 1)")
  x = -2:0.01:2
  for j in 1:100
    y = post5_5_drafts_df[j, :a] .+ post5_5_drafts_df[j, :bN]*x
    plot!(p, x, y, color=:lightgrey, leg=false)
  end
	plot(p)
end

# ╔═╡ d8e7b710-fda3-11ea-13e3-e7141d1245d8
md"## End of clip-05-28-34s.jl"

# ╔═╡ Cell order:
# ╟─b0b04904-fda3-11ea-2a13-efbb8da05490
# ╠═b78a501c-fda3-11ea-06bb-5175ada30398
# ╠═b78a9662-fda3-11ea-25be-871b1258e163
# ╟─b78b1934-fda3-11ea-119c-5398009c1521
# ╠═b7997a6a-fda3-11ea-325a-7d0fc706cdff
# ╠═9fe858dc-fda3-11ea-38c8-df4b1d6e8419
# ╟─d65e8eea-fda3-11ea-0f78-6d8a183f5818
# ╠═d65ec40a-fda3-11ea-2e15-2f55dd308dd9
# ╠═407845b4-fd4a-11ea-1ed5-65581b68ccda
# ╟─d8d01f36-fda3-11ea-2b26-59b86a4e23ca
# ╠═d8d1b594-fda3-11ea-2bae-e1be39ef751e
# ╠═d8d8a4e4-fda3-11ea-3bda-0b8c90e63d65
# ╠═d8db84ca-fda3-11ea-35c2-1f671cea8a32
# ╟─d8e7b710-fda3-11ea-13e3-e7141d1245d8
