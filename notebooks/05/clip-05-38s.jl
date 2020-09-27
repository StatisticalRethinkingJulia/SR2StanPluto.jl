### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 0b91d166-fdaa-11ea-3dac-ebd4d51a729f
using Pkg, DrWatson

# ╔═╡ 0b92178e-fdaa-11ea-3be6-27667afc3797
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 0b92bf04-fdaa-11ea-0131-4989f4bde90b
for i in 5:6
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

# ╔═╡ bd517e12-fda8-11ea-2835-77cfacec77f7
md"## Clip-05-38s.jl"

# ╔═╡ 0ba11a90-fdaa-11ea-311a-e71e9889d9bf
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	df.lmass = log.(df.mass)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 0ba1c21a-fdaa-11ea-009d-5dcaf34749be
m5_7 = "
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

# ╔═╡ 0bac81b4-fdaa-11ea-0449-89f05d4b2780
md"##### Define the SampleModel, etc."

# ╔═╡ 0bacf8a6-fdaa-11ea-2c4e-ed3ec21de17e
begin
	m5_7s = SampleModel("m5.7", m5_7);
	m5_7_data = Dict("N" => size(df, 1), "M" => df[!, :lmass_s],
		"K" => df[!, :kcal_per_g_s], "NC" => df[!, :neocortex_perc_s]);
	rc = stan_sample(m5_7s, data=m5_7_data);
	success(rc) && (dfa7 = read_samples(m5_7s; output_format=:dataframe))
end;

# ╔═╡ 0bb730c8-fdaa-11ea-13f4-65a4d5d6081c
success(rc) && Particles(dfa7)

# ╔═╡ 0bb8537c-fdaa-11ea-3eb2-3fba4b89dedf
success(rc) && quap(dfa7)

# ╔═╡ 0bc2f976-fdaa-11ea-0212-29e5fd84c264
begin
	(s1, p1) = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	p1
end

# ╔═╡ e74a9ef6-00eb-11eb-3520-a75d0472d1d9
s1

# ╔═╡ 240a2114-fdb2-11ea-370a-81c8b32ddbc4
plot(p1)

# ╔═╡ 0bc6882a-fdaa-11ea-0714-0baec236fdc3
begin
	(s2, p2) = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Quap estimates", func=quap)
	p2
end

# ╔═╡ 30858154-fdb2-11ea-2096-db053629c188
s2

# ╔═╡ 0bce9330-fdaa-11ea-03be-395a30d110ea
md"## End of clip-05-38s.jl"

# ╔═╡ Cell order:
# ╟─bd517e12-fda8-11ea-2835-77cfacec77f7
# ╠═0b91d166-fdaa-11ea-3dac-ebd4d51a729f
# ╠═0b92178e-fdaa-11ea-3be6-27667afc3797
# ╠═0b92bf04-fdaa-11ea-0131-4989f4bde90b
# ╠═0ba11a90-fdaa-11ea-311a-e71e9889d9bf
# ╠═0ba1c21a-fdaa-11ea-009d-5dcaf34749be
# ╟─0bac81b4-fdaa-11ea-0449-89f05d4b2780
# ╠═0bacf8a6-fdaa-11ea-2c4e-ed3ec21de17e
# ╠═0bb730c8-fdaa-11ea-13f4-65a4d5d6081c
# ╠═0bb8537c-fdaa-11ea-3eb2-3fba4b89dedf
# ╠═0bc2f976-fdaa-11ea-0212-29e5fd84c264
# ╠═e74a9ef6-00eb-11eb-3520-a75d0472d1d9
# ╠═240a2114-fdb2-11ea-370a-81c8b32ddbc4
# ╠═0bc6882a-fdaa-11ea-0714-0baec236fdc3
# ╠═30858154-fdb2-11ea-2096-db053629c188
# ╟─0bce9330-fdaa-11ea-03be-395a30d110ea
