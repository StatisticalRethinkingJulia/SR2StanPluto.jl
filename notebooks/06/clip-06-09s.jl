### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 1c31a6c8-fe76-11ea-1122-0580af80a98b
using Pkg, DrWatson

# ╔═╡ 1c31e480-fe76-11ea-356d-6b2d21e37ace
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ d1b31aa0-fe75-11ea-0d96-bdbf19c2c1c7
md"## Clip-06-06-09s.jl"

# ╔═╡ 1c325ef6-fe76-11ea-1967-45317ad16daa
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end;

# ╔═╡ 1c3fc474-fe76-11ea-327f-7beea4fb1872
stan6_4 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] L;
}
parameters{
  real a;
  real bL;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bL ~ normal( 0 , 0.5 );
  mu = a + bL * L;
  K ~ normal( mu , sigma );
}
";

# ╔═╡ 1c48ffe4-fe76-11ea-0883-f3715e7beda4
md"##### Define the SampleModel, etc."

# ╔═╡ 1c4ba9c4-fe76-11ea-0aff-ef249af5bdb5
begin
	data = (N = size(df, 1), L = df.perc_lactose_s, K = df.kcal_per_g_s)
	init = (a = 0.0, bL = 1.0, sigma = 1.0)
	q6_4s, m6_4s, o6_4s = stan_quap("m6.3", stan6_4; data, init)
	if !isnothing(m6_4s)
		post6_4s_df = read_samples(m6_4s, :dataframe)
		PRECIS(post6_4s_df)
	end
end

# ╔═╡ 1c57c894-fe76-11ea-0b4f-152cfd868c3f
!isnothing(m6_4s) && (part6_4s = Particles(post6_4s_df))

# ╔═╡ 1c586718-fe76-11ea-10ec-892fadc8778c
if !isnothing(q6_4s)
	quap6_4s_df = sample(q6_4s)
	PRECIS(quap6_4s_df)
end

# ╔═╡ 1c659f3c-fe76-11ea-0e95-c1c2cadaaebc
!isnothing(m6_4s) && hpdi(part6_4s.bL.particles, alpha=0.11)

# ╔═╡ 1c6741e8-fe76-11ea-34f3-c54c70b51171
md"## End of clip-06-06-09s.jl"

# ╔═╡ Cell order:
# ╟─d1b31aa0-fe75-11ea-0d96-bdbf19c2c1c7
# ╠═1c31a6c8-fe76-11ea-1122-0580af80a98b
# ╠═1c31e480-fe76-11ea-356d-6b2d21e37ace
# ╠═1c325ef6-fe76-11ea-1967-45317ad16daa
# ╠═1c3fc474-fe76-11ea-327f-7beea4fb1872
# ╟─1c48ffe4-fe76-11ea-0883-f3715e7beda4
# ╠═1c4ba9c4-fe76-11ea-0aff-ef249af5bdb5
# ╠═1c57c894-fe76-11ea-0b4f-152cfd868c3f
# ╠═1c586718-fe76-11ea-10ec-892fadc8778c
# ╠═1c659f3c-fe76-11ea-0e95-c1c2cadaaebc
# ╟─1c6741e8-fe76-11ea-34f3-c54c70b51171
