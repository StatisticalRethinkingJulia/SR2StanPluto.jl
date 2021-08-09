### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5fe9a49a-fdc2-11ea-3ff9-01e000224b3a
using Pkg, DrWatson

# ╔═╡ 5fe9db1c-fdc2-11ea-0c8c-7db1e606cbcb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ 5b3cfe6e-fdc2-11ea-2462-cb4109cb77ee
md"## Clip-05-49.1s.jl"

# ╔═╡ 5fea720a-fdc2-11ea-2dde-493a3df79ff2
begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df[!, :clade_id] = Int.(indexin(df[:, :clade], unique(df[:, :clade])))
	scale!(df, [:kcal_per_g])
	PRECIS(df[:, [:clade_id, :kcal_per_g]])
end

# ╔═╡ 5ffa4cfc-fdc2-11ea-0dd3-659a65ad4949
stan5_9 = "
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
	data = (N = size(df, 1), clade_id = df.clade_id,
    	K = df.kcal_per_g_s, k = length(unique(df[:, :clade_id])))
	init = (a = [-1.0, 0,0, 1.0, 1.0], sigma = 1.0,)
	q5_9s, m5_9s, _ = stan_quap("m5.9", stan5_9; data, init)

	if !isnothing(m5_9s)
		post5_9s_df = read_samples(m5_9s, :dataframe)
		PRECIS(post5_9s_df)
	end
end

# ╔═╡ 7e7479dc-fdc2-11ea-2644-a75204ec3851
if !isnothing(q5_9s)
	quap5_9s_df = sample(q5_9s)
	PRECIS(quap5_9s_df)
end

# ╔═╡ 7e7528a0-fdc2-11ea-1031-973876c110eb
rethinking = "
       mean   sd  5.5% 94.5%
a[1]  -0.48 0.22 -0.83 -0.14
a[2]   0.37 0.22  0.02  0.71
a[3]   0.68 0.26  0.26  1.09
a[4]  -0.59 0.27 -1.02 -0.15
sigma  0.72 0.10  0.57  0.87
";

# ╔═╡ 7e89657a-fdc2-11ea-33a9-779fdfd53519
md"## End of clip-05-49.1s.jl"

# ╔═╡ Cell order:
# ╟─5b3cfe6e-fdc2-11ea-2462-cb4109cb77ee
# ╠═5fe9a49a-fdc2-11ea-3ff9-01e000224b3a
# ╠═5fe9db1c-fdc2-11ea-0c8c-7db1e606cbcb
# ╠═5fea720a-fdc2-11ea-2dde-493a3df79ff2
# ╠═5ffa4cfc-fdc2-11ea-0dd3-659a65ad4949
# ╟─0233ffa6-fdc1-11ea-202f-d18f84a47bb1
# ╠═90cf5430-fdc2-11ea-279a-19fbadfdf16b
# ╠═7e7479dc-fdc2-11ea-2644-a75204ec3851
# ╠═7e7528a0-fdc2-11ea-1031-973876c110eb
# ╟─7e89657a-fdc2-11ea-33a9-779fdfd53519
