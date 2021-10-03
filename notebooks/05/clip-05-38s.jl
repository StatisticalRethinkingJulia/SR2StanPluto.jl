### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 0b91d166-fdaa-11ea-3dac-ebd4d51a729f
using Pkg, DrWatson

# ╔═╡ 0b92178e-fdaa-11ea-3be6-27667afc3797
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ bd517e12-fda8-11ea-2835-77cfacec77f7
md"## Clip-05-38s.jl"

# ╔═╡ d95b1330-6d3c-11eb-0fea-0771c632bafb
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
	df[!, :lmass] = log.(df[:, :mass])
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
	data = (N = size(df, 1), M = df[!, :lmass_s],
		K = df[!, :kcal_per_g_s], NC = df[!, :neocortex_perc_s]);
end;

# ╔═╡ 4e59a4d0-6d3d-11eb-1017-6fdad80c1702
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

# ╔═╡ 4e59ded0-6d3d-11eb-33e9-ebe8d1541013
begin
	m5_5s = SampleModel("m5.5", stan5_5)
	rc5_5s = stan_sample(m5_5s; data)
end;

# ╔═╡ 52b02cea-6d3d-11eb-182c-c7850d2d587c
stan5_6 = "
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

# ╔═╡ 84ff396e-6d3d-11eb-03bd-21dde805868a
begin
	m5_6s = SampleModel("m5.6", stan5_6);
	rc5_6s = stan_sample(m5_6s; data)
end;

# ╔═╡ 0ba1c21a-fdaa-11ea-009d-5dcaf34749be
stan5_7 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 0bacf8a6-fdaa-11ea-2c4e-ed3ec21de17e
begin
	m5_7s = SampleModel("m5.7", stan5_7)
	rc5_7s = stan_sample(m5_7s; data)
end;

# ╔═╡ 0bc2f976-fdaa-11ea-0212-29e5fd84c264
if success(rc5_5s) && success(rc5_6s) && success(rc5_7s)
	(s1, p1) = plot_model_coef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	p1
end

# ╔═╡ e74a9ef6-00eb-11eb-3520-a75d0472d1d9
s1

# ╔═╡ 0bce9330-fdaa-11ea-03be-395a30d110ea
md"## End of clip-05-38s.jl"

# ╔═╡ Cell order:
# ╟─bd517e12-fda8-11ea-2835-77cfacec77f7
# ╠═0b91d166-fdaa-11ea-3dac-ebd4d51a729f
# ╠═0b92178e-fdaa-11ea-3be6-27667afc3797
# ╠═d95b1330-6d3c-11eb-0fea-0771c632bafb
# ╠═4e59a4d0-6d3d-11eb-1017-6fdad80c1702
# ╠═4e59ded0-6d3d-11eb-33e9-ebe8d1541013
# ╠═52b02cea-6d3d-11eb-182c-c7850d2d587c
# ╠═84ff396e-6d3d-11eb-03bd-21dde805868a
# ╠═0ba1c21a-fdaa-11ea-009d-5dcaf34749be
# ╠═0bacf8a6-fdaa-11ea-2c4e-ed3ec21de17e
# ╠═0bc2f976-fdaa-11ea-0212-29e5fd84c264
# ╠═e74a9ef6-00eb-11eb-3520-a75d0472d1d9
# ╟─0bce9330-fdaa-11ea-03be-395a30d110ea
