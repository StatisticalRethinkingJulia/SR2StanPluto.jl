### A Pluto.jl notebook ###
# v0.12.14

using Markdown
using InteractiveUtils

# ╔═╡ 5fe9a49a-fdc2-11ea-3ff9-01e000224b3a
using Pkg, DrWatson

# ╔═╡ 5fe9db1c-fdc2-11ea-0c8c-7db1e606cbcb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 5b3cfe6e-fdc2-11ea-2462-cb4109cb77ee
md"## Clip-05-49.1s.jl"

# ╔═╡ 5fea720a-fdc2-11ea-2dde-493a3df79ff2
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
	df[!, :lmass] = log.(df[:, :mass])

	df[!, :clade_id] = Int.(indexin(df[:, :clade], unique(df[:, :clade])))
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

# ╔═╡ 5ff9b7ba-fdc2-11ea-3031-21fe01c50969
begin
	c_id= [4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	kcal_per_g = [
	  0.49, 0.51, 0.46, 0.48, 0.60, 0.47, 0.56, 0.89,
	  0.91, 0.92, 0.80, 0.46, 0.71, 0.71, 0.73, 0.68, 0.72,
	  0.97, 0.79, 0.84, 0.48, 0.62, 0.51, 0.54, 0.49, 0.53, 0.48, 0.55, 0.71]

	PRECIS(DataFrame(:clade_id => c_id, :K => kcal_per_g))
end

# ╔═╡ 5ffa4cfc-fdc2-11ea-0dd3-659a65ad4949
m5_9 = "
data{
  int <lower=1> N;              // Sample size
  int <lower=1> k;
  vector[N] K;
  int clade_id[N];
}
parameters{
  vector[k] a;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.5 );
  for ( i in 1:N ) {
      mu[i] = a[clade_id[i]];
  }
  K ~ normal( mu , sigma );
}
";

# ╔═╡ 0233ffa6-fdc1-11ea-202f-d18f84a47bb1
md"##### Define the SampleModel."

# ╔═╡ 90cf5430-fdc2-11ea-279a-19fbadfdf16b
begin
	m5_9s = SampleModel("m5.9", m5_9)
	m5_9_data = Dict("N" => size(df, 1), "clade_id" => df[:, :clade_id],
    "K" => df[!, :kcal_per_g_s], "k" => length(unique(df[:, :clade])))
	rc5_9s = stan_sample(m5_9s, data=m5_9_data)
	if success(rc5_9s)
		dfa5_9s = read_samples(m5_9s; output_format=:dataframe)
		part5_9s = Particles(dfa5_9s)
	end
end

# ╔═╡ 7e7479dc-fdc2-11ea-2644-a75204ec3851
success(rc5_9s) && quap(dfa5_9s)

# ╔═╡ 7e7528a0-fdc2-11ea-1031-973876c110eb
rethinking = "
	   mean   sd  5.5% 94.5% n_eff Rhat4
a[1]  -0.47 0.24 -0.84 -0.09   384     1
a[2]   0.35 0.25 -0.07  0.70   587     1
a[3]   0.64 0.28  0.18  1.06   616     1
a[4]  -0.53 0.29 -0.97 -0.05   357     1
sigma  0.81 0.11  0.64  0.98   477     1
";

# ╔═╡ 7e7bf644-fdc2-11ea-3322-871214a78eaf
success(rc5_9s) && mean(df[:, :lmass])

# ╔═╡ 7e89657a-fdc2-11ea-33a9-779fdfd53519
md"## End of clip-05-49.1s.jl"

# ╔═╡ Cell order:
# ╟─5b3cfe6e-fdc2-11ea-2462-cb4109cb77ee
# ╠═5fe9a49a-fdc2-11ea-3ff9-01e000224b3a
# ╠═5fe9db1c-fdc2-11ea-0c8c-7db1e606cbcb
# ╠═5fea720a-fdc2-11ea-2dde-493a3df79ff2
# ╠═5ff9b7ba-fdc2-11ea-3031-21fe01c50969
# ╠═5ffa4cfc-fdc2-11ea-0dd3-659a65ad4949
# ╟─0233ffa6-fdc1-11ea-202f-d18f84a47bb1
# ╠═90cf5430-fdc2-11ea-279a-19fbadfdf16b
# ╠═7e7479dc-fdc2-11ea-2644-a75204ec3851
# ╠═7e7528a0-fdc2-11ea-1031-973876c110eb
# ╠═7e7bf644-fdc2-11ea-3322-871214a78eaf
# ╟─7e89657a-fdc2-11ea-33a9-779fdfd53519
