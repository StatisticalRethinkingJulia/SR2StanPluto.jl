### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 43e8fa28-fda8-11ea-0051-dd3db29697b8
using Pkg, DrWatson

# ╔═╡ 43e9386e-fda8-11ea-245e-57c3be7b7977
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ e0197532-fda6-11ea-2023-27973dec779c
md"## Clip-05-37s.jl"

# ╔═╡ 43e9b9ea-fda8-11ea-06af-87a022dcae90
md"### snippet 5.29"

# ╔═╡ 43f71298-fda8-11ea-31ae-1136eb790910
begin
	df = CSV.read(sr_datadir("milk.csv"), delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	df.lmass = log.(df.mass)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 43f87ef8-fda8-11ea-1764-9b59eb6c3e8b
md"### snippet 5.1"

# ╔═╡ 44037e3e-fda8-11ea-0d38-bdae456569f2
m5_6 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 44041268-fda8-11ea-3918-c1a03b0e6936
md"## Define the SampleModel, etc."

# ╔═╡ 440ddc4e-fda8-11ea-218b-e9d90d16c8d6
begin
	m5_6s = SampleModel("m5.6", m5_6);
	m5_6_data = Dict("N" => size(df, 1), "M" => df.lmass_s, "K" => df.kcal_per_g_s);
	rc = stan_sample(m5_6s, data=m5_6_data);
end;

# ╔═╡ 4414afce-fda8-11ea-04bc-c743afb894bc
if success(rc)

  # Describe the draws

  dfa6 = read_samples(m5_6s; output_format=:dataframe)

  title = "Kcal_per_g vs. log mass" * "\nshowing 89% predicted and hpd range"
  plotbounds(
    df, :lmass, :kcal_per_g,
    dfa6, [:a, :bM, :sigma];
    title=title
  )
end

# ╔═╡ 4415fff0-fda8-11ea-3a82-332931a21614
md"## End of clip-05-37s.jl"

# ╔═╡ Cell order:
# ╟─e0197532-fda6-11ea-2023-27973dec779c
# ╠═43e8fa28-fda8-11ea-0051-dd3db29697b8
# ╠═43e9386e-fda8-11ea-245e-57c3be7b7977
# ╟─43e9b9ea-fda8-11ea-06af-87a022dcae90
# ╠═43f71298-fda8-11ea-31ae-1136eb790910
# ╟─43f87ef8-fda8-11ea-1764-9b59eb6c3e8b
# ╠═44037e3e-fda8-11ea-0d38-bdae456569f2
# ╟─44041268-fda8-11ea-3918-c1a03b0e6936
# ╠═440ddc4e-fda8-11ea-218b-e9d90d16c8d6
# ╠═4414afce-fda8-11ea-04bc-c743afb894bc
# ╟─4415fff0-fda8-11ea-3a82-332931a21614
