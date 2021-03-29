### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 0f1a134c-fea8-11ea-012a-dd9ffc2c4404
using Pkg, DrWatson

# ╔═╡ 0f1a4e18-fea8-11ea-272e-9f7fb0ad303e
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 0f21786e-fea8-11ea-2ba5-c97874afaae5
for f in ["m6.3s.jl", "m6.4s.jl"]
  include(projectdir("models", "06", f))
end

# ╔═╡ 6ae0c75e-fe76-11ea-1f07-a922579b94d7
md"## Clip-06-10-12s.jl"

# ╔═╡ 0f1adcca-fea8-11ea-3331-5b9bd92e1368
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end;

# ╔═╡ 966d4c74-834d-11eb-3b15-a5c73f6d2ba7
md"
!!! note
	Restart this notebook to execute below `include()` cell again.
"

# ╔═╡ 0f2e35d6-fea8-11ea-0034-cfd003aea49b
stan6_5 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
  vector[N] L;
}
parameters{
  real a;
  real bL;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bL ~ normal( 0 , 0.5 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bL * L + bF * F;
  K ~ normal( mu , sigma );
}
";

# ╔═╡ 0f2f0862-fea8-11ea-3968-3d8494532b8b
md"##### Define the SampleModel, etc."

# ╔═╡ 0f3462bc-fea8-11ea-09af-4135dc5fd195
begin
	m6_5s = SampleModel("m6.5s", stan6_5);
	m6_5_data = Dict("N" => size(df, 1), "L" => df.perc_lactose_s, "F" => df.perc_fat_s,
		"K" => 	df.kcal_per_g_s);
	rc6_5s = stan_sample(m6_5s, data=m6_5_data)
	success(rc6_5s) && (post6_5s_df = read_samples(m6_5s; output_format=:dataframe))
end;

# ╔═╡ 0f408786-fea8-11ea-3868-89d746f4fb34
success(rc6_5s) && (p6_5s = Particles(post6_5s_df))

# ╔═╡ 0f4126fc-fea8-11ea-3fde-3f1ded9aaedb
if success(rc6_5s)
	(s6_5s, f6_5s) = plot_model_coef([m6_3s, m6_4s, m6_5s], [:a, :bF, :bL, :sigma];
		title="Multicollinearity for milk model using quap()")
	f6_5s
end

# ╔═╡ 0f4ed43a-fea8-11ea-0aef-033de524b9d4
success(rc6_5s) && s6_5s

# ╔═╡ 0f561d94-fea8-11ea-24c0-39334d22238e
md"### Snippet 6.11"

# ╔═╡ 0f5da062-fea8-11ea-218b-b90a9e3f07ca
pairsplot(df, [:kcal_per_g, :perc_fat, :perc_lactose])

# ╔═╡ 0f64d190-fea8-11ea-057c-83a01a41598d
md"### Snippet 6.12"

# ╔═╡ 0f66a1fa-fea8-11ea-0a72-afdfd848c896
cor(df.perc_fat, df.perc_lactose)

# ╔═╡ 0f6db8a0-fea8-11ea-37e7-4d787a14072d
md"## End of clip-06-10-12s.jl"

# ╔═╡ Cell order:
# ╟─6ae0c75e-fe76-11ea-1f07-a922579b94d7
# ╠═0f1a134c-fea8-11ea-012a-dd9ffc2c4404
# ╠═0f1a4e18-fea8-11ea-272e-9f7fb0ad303e
# ╠═0f1adcca-fea8-11ea-3331-5b9bd92e1368
# ╟─966d4c74-834d-11eb-3b15-a5c73f6d2ba7
# ╠═0f21786e-fea8-11ea-2ba5-c97874afaae5
# ╠═0f2e35d6-fea8-11ea-0034-cfd003aea49b
# ╟─0f2f0862-fea8-11ea-3968-3d8494532b8b
# ╠═0f3462bc-fea8-11ea-09af-4135dc5fd195
# ╠═0f408786-fea8-11ea-3868-89d746f4fb34
# ╠═0f4126fc-fea8-11ea-3fde-3f1ded9aaedb
# ╠═0f4ed43a-fea8-11ea-0aef-033de524b9d4
# ╟─0f561d94-fea8-11ea-24c0-39334d22238e
# ╠═0f5da062-fea8-11ea-218b-b90a9e3f07ca
# ╟─0f64d190-fea8-11ea-057c-83a01a41598d
# ╠═0f66a1fa-fea8-11ea-0a72-afdfd848c896
# ╟─0f6db8a0-fea8-11ea-37e7-4d787a14072d
