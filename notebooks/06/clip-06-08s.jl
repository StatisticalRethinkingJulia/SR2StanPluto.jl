### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 822b4836-fe75-11ea-161f-35d589ab833f
using Pkg, DrWatson

# ╔═╡ 822b886e-fe75-11ea-3fd5-313bd9474e67
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ 416556d6-fe6e-11ea-338a-fb39b7c0f00f
md"## Clip-06-08s.jl"

# ╔═╡ 822c0d84-fe75-11ea-27b2-cb1e8fa46fb1
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end;

# ╔═╡ 823966f0-fe75-11ea-3c37-25437bd882cd
stan6_3 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
}
parameters{
  real a;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bF * F;
  K ~ normal( mu , sigma );
}
";

# ╔═╡ 82435d7e-fe75-11ea-3f52-7daa1879898d
begin
	data = (N = size(df, 1), F = df.perc_fat_s, K = df.kcal_per_g_s)
	init = (a=0.0, bF=1.0, sigma=1.0)
	q6_3s, m6_3s, o6_3s = stan_quap("m6.3s", stan6_3; data, init);
	if !isnothing(m6_3s)
		post6_3s_df = read_samples(m6_3s, :dataframe)
		PRECIS(post6_3s_df)
	end
end

# ╔═╡ 82456bc6-fe75-11ea-3e9a-256e1fb9844f
!isnothing(m6_3s) && (part6_3s = Particles(post6_3s_df))

# ╔═╡ 82509064-fe75-11ea-16cb-e506f49efd72
if !isnothing(q6_3s)
	quap6_3s_df = sample(q6_3s)
	PRECIS(quap6_3s_df)
end

# ╔═╡ 8251194e-fe75-11ea-1403-d743608a5169
hpdi(part6_3s.bF.particles, alpha=0.11)

# ╔═╡ 825cb330-fe75-11ea-2df5-a92dca779683
md"## End of clip-06-08s.jl"

# ╔═╡ Cell order:
# ╟─416556d6-fe6e-11ea-338a-fb39b7c0f00f
# ╠═822b4836-fe75-11ea-161f-35d589ab833f
# ╠═822b886e-fe75-11ea-3fd5-313bd9474e67
# ╠═822c0d84-fe75-11ea-27b2-cb1e8fa46fb1
# ╠═823966f0-fe75-11ea-3c37-25437bd882cd
# ╠═82435d7e-fe75-11ea-3f52-7daa1879898d
# ╠═82456bc6-fe75-11ea-3e9a-256e1fb9844f
# ╠═82509064-fe75-11ea-16cb-e506f49efd72
# ╠═8251194e-fe75-11ea-1403-d743608a5169
# ╟─825cb330-fe75-11ea-2df5-a92dca779683
