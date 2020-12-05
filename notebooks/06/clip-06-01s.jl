### A Pluto.jl notebook ###
# v0.12.14

using Markdown
using InteractiveUtils

# ╔═╡ c09f8480-fe4b-11ea-2f60-b315991fbf20
using Pkg, DrWatson

# ╔═╡ c0c7bd2e-fe4b-11ea-3f66-6dc48fb0eace
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 99746fa2-fe4a-11ea-0d78-9bad2014c6ce
md"## Clip-06-01s.jl"

# ╔═╡ c0c8b03a-fe4b-11ea-33f6-91a335f4d901
begin
	N = 200
	prob = 0.1

	df = DataFrame(
	  nw = rand(Normal(), N),
	  tw = rand(Normal(), N)
	)
	df.s = df.tw + df.nw
	scale!(df, [:s, :nw, :tw])

	q = quantile(df.s, 1-prob)

	selected_df = filter(row -> row.s > q, df)
	unselected_df = filter(row -> row.s <= q, df)

	cor(selected_df.nw, selected_df.tw)
end

# ╔═╡ c0ce63ae-fe4b-11ea-0438-0359324fac9b
stan6_0 = "
data {
  int <lower=1> N;
  vector[N] nw;
  vector[N] tw;
}
parameters {
  real a;
  real aS;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + aS * nw;
  a ~ normal(0, 5.0);
  aS ~ normal(0, 1.0);
  sigma ~ exponential(1);
  tw ~ normal(mu, sigma);
}
";

# ╔═╡ c0df6122-fe4b-11ea-0d95-5366fce018a1
begin
	m6_0s = SampleModel("m6.0s", stan6_0)
	m_6_0_data = Dict(
	  :nw => selected_df.nw_s,
	  :tw => selected_df.tw_s,
	  :N => size(selected_df, 1)
	)
	rc6_0s = stan_sample(m6_0s, data=m_6_0_data)
	success(rc6_0s) && (part6_0s = read_samples(m6_0s, output_format=:particles))
end

# ╔═╡ c0e0cf76-fe4b-11ea-0130-3f2bb12f36a0
if success(rc6_0s)
  x = -2.0:0.01:3.0
  plot(xlabel="newsworthiness", ylabel="trustworthiness",
    title="Science distortion")
  scatter!(selected_df[:, :nw], selected_df[:, :tw], color=:blue, lab="selected")
  scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, lab="unselected")
  plot!(x, mean(part6_0s.a) .+ mean(part6_0s.aS) .* x, lab="Regression line")
end

# ╔═╡ 5bfe710c-fe4c-11ea-16c2-fdb21351103b
if success(rc6_0s)
  post6_0s_df = read_samples(m6_0s, output_format=:dataframe)
  fig1 = plotbounds(df, :nw, :tw, post6_0s_df , [:a, :aS, :sigma])
  scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, lab="unselected")
end

# ╔═╡ c0eed12a-fe4b-11ea-2f8c-3f4aed9007fd
md"## End of clip-06-01s.jl"

# ╔═╡ Cell order:
# ╟─99746fa2-fe4a-11ea-0d78-9bad2014c6ce
# ╠═c09f8480-fe4b-11ea-2f60-b315991fbf20
# ╠═c0c7bd2e-fe4b-11ea-3f66-6dc48fb0eace
# ╠═c0c8b03a-fe4b-11ea-33f6-91a335f4d901
# ╠═c0ce63ae-fe4b-11ea-0438-0359324fac9b
# ╠═c0df6122-fe4b-11ea-0d95-5366fce018a1
# ╠═c0e0cf76-fe4b-11ea-0130-3f2bb12f36a0
# ╠═5bfe710c-fe4c-11ea-16c2-fdb21351103b
# ╟─c0eed12a-fe4b-11ea-2f8c-3f4aed9007fd
