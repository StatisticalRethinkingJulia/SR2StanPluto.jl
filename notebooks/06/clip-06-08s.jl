### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 822b4836-fe75-11ea-161f-35d589ab833f
using Pkg, DrWatson

# ╔═╡ 822b886e-fe75-11ea-3fd5-313bd9474e67
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 416556d6-fe6e-11ea-338a-fb39b7c0f00f
md"## Clip-06-08s.jl"

# ╔═╡ 822c0d84-fe75-11ea-27b2-cb1e8fa46fb1
begin
df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end

# ╔═╡ 823966f0-fe75-11ea-3c37-25437bd882cd
m6_3 = "
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
# Define the SampleModel, etc..

begin
	m6_3s = SampleModel("m6.3", m6_3);
	m6_3_data = Dict("N" => size(df, 1), "F" => df.perc_fat_s, "K" => df.kcal_per_g_s);
	rc = stan_sample(m6_3s, data=m6_3_data);
	success(rc) && (dfa6_3 = read_samples(m6_3s; output_format=:dataframe))
end

# ╔═╡ 82456bc6-fe75-11ea-3e9a-256e1fb9844f
success(rc) && (p = Particles(dfa6_3))

# ╔═╡ 82509064-fe75-11ea-16cb-e506f49efd72
success(rc) && quap(dfa6_3)

# ╔═╡ 8251194e-fe75-11ea-1403-d743608a5169
hpdi(p.bF.particles, alpha=0.11)

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
