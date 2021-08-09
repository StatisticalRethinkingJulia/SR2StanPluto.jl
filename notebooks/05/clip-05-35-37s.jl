### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 63952e48-fda6-11ea-29d5-c9e748d213cf
using Pkg, DrWatson

# ╔═╡ 639575b0-fda6-11ea-2629-8fdf4e78c434
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 3effb80c-fda4-11ea-1b76-33e901d4c0ad
md"## Clip-05-35-37s.jl"

# ╔═╡ 639604e4-fda6-11ea-0184-af7e26ad59fa
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
	df[!, :lmass] = log.(df[:, :mass])
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 63a35040-fda6-11ea-0016-4bf41ecaa531
md"### snippet 5.35"

# ╔═╡ 63a85bda-fda6-11ea-1664-4d81fe6e0bc2
stan5_5 = "
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
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 63b25188-fda6-11ea-2e79-47306de1cf27
md"## Define the SampleModel, etc."

# ╔═╡ 63b3736c-fda6-11ea-35fe-5b5f3d67aef6
begin
	m5_5s = SampleModel("m5.5", stan5_5);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
		"K" => df[!, :kcal_per_g_s]);
	rc5_5s = stan_sample(m5_5s, data=m5_5_data);
end;

# ╔═╡ 63bc7bba-fda6-11ea-1e4e-3deb1786b246
if success(rc5_5s)
  post5_5s_df = read_samples(m5_5s, :dataframe)
  title = "Kcal_per_g vs. neocortex_perc" * "\nshowing predicted and hpd range"
  plotbounds(
    df, :neocortex_perc, :kcal_per_g,
    post5_5s_df, [:a, :bN, :sigma];
    title=title
  )
end

# ╔═╡ 63bce55a-fda6-11ea-1485-dd20ccc99814
md"## End of clip-05-35-37s.jl"

# ╔═╡ Cell order:
# ╟─3effb80c-fda4-11ea-1b76-33e901d4c0ad
# ╠═63952e48-fda6-11ea-29d5-c9e748d213cf
# ╠═639575b0-fda6-11ea-2629-8fdf4e78c434
# ╠═639604e4-fda6-11ea-0184-af7e26ad59fa
# ╟─63a35040-fda6-11ea-0016-4bf41ecaa531
# ╠═63a85bda-fda6-11ea-1664-4d81fe6e0bc2
# ╟─63b25188-fda6-11ea-2e79-47306de1cf27
# ╠═63b3736c-fda6-11ea-35fe-5b5f3d67aef6
# ╠═63bc7bba-fda6-11ea-1e4e-3deb1786b246
# ╟─63bce55a-fda6-11ea-1485-dd20ccc99814
