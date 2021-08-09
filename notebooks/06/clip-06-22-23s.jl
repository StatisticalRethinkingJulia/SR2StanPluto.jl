### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 026297d2-ff3b-11ea-0b8e-bfe900aee548
using Pkg, DrWatson

# ╔═╡ 0262d116-ff3b-11ea-3529-6385864e656f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ eceaf076-ff39-11ea-342c-6f995361e350
md"## Clip-06-22-23s.jl"

# ╔═╡ 02636216-ff3b-11ea-3664-23da6dd85310
begin
	df = sim_happiness()
	df.mid = df.married .+ 1
	
	# or `df = filter(row -> row[:age] > 17, df)`

	df = df[df.age .> 17, :]
	df.A = (df.age .- 18) / (65 - 18)
	Text(precis(df; io=String))
end

# ╔═╡ 02712162-ff3b-11ea-1fac-7791273aef31
stan6_9 = "
data {
  int <lower=1> N;
  vector[N] happiness;
  vector[N] A;
  int <lower=1>  k;
  int mid[N];
}
parameters {
  real <lower=0> sigma;
  vector[k] a;
  real bA;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  bA ~ normal(0, 2);
  for (i in 1:N) {
    mu[i] = a[mid[i]] + bA * A[i];
  }
  happiness ~ normal(mu, sigma);
}
";

# ╔═╡ 0271c84c-ff3b-11ea-220e-d36d3603ebd6
begin
	m6_9s = SampleModel("m6.9s", stan6_9)
	m6_9_data = Dict(:N => nrow(df), :k => 2, :happiness => df.happiness, :A => df.A, :mid => df.mid)
	rc6_9s = stan_sample(m6_9s, data=m6_9_data)
	success(rc6_9s) && (part6_9s = read_samples(m6_9s, :particles))
end

# ╔═╡ 027d15e4-ff3b-11ea-3c1d-73ab679b7357
if success(rc6_9s)
  post6_9s_df = read_samples(m6_9s, :dataframe)
  Text(precis(post6_9s_df; io=String))
end

# ╔═╡ 027da7b6-ff3b-11ea-047c-39a0d0864962
md"## End of clip-06-22-23s.jl"

# ╔═╡ Cell order:
# ╟─eceaf076-ff39-11ea-342c-6f995361e350
# ╠═026297d2-ff3b-11ea-0b8e-bfe900aee548
# ╠═0262d116-ff3b-11ea-3529-6385864e656f
# ╠═02636216-ff3b-11ea-3664-23da6dd85310
# ╠═02712162-ff3b-11ea-1fac-7791273aef31
# ╠═0271c84c-ff3b-11ea-220e-d36d3603ebd6
# ╠═027d15e4-ff3b-11ea-3c1d-73ab679b7357
# ╟─027da7b6-ff3b-11ea-047c-39a0d0864962
