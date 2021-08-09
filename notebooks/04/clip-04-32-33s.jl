### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 62912e52-fb76-11ea-014f-674eaa0c1ded
using Pkg, DrWatson

# ╔═╡ 62916bce-fb76-11ea-1d36-77a8b156aabb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
end

# ╔═╡ 8e62b178-fb75-11ea-0fd3-f16790f4bf4f
md"## Clip-04-32-33s.jl"

# ╔═╡ 62920520-fb76-11ea-099e-952976e305a4
md"### Snippet 4.26"

# ╔═╡ 629f31e6-fb76-11ea-2e8b-774da4fa0cb6
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 62a7bf82-fb76-11ea-3ad9-6bcc0a1b1be3
stan4_1 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ 62aebe34-fb76-11ea-1646-d75ffe9ecd49
md"### Snippet 4.31"

# ╔═╡ 2fc627a0-3cc3-11eb-31a0-47b17099e493
begin
	data = Dict(:N => length(df.height), :h => df.height)
	init = Dict(:mu => 180.0, :sigma => 10.0)
	q4_1s, m4_1s, om = stan_quap("m4.1s", stan4_1; data, init)
end;

# ╔═╡ 62c16610-fb76-11ea-36d5-51093f07a76a
if !isnothing(m4_1s)
	post4_1s_df = read_samples(m4_1s, :dataframe)
	PRECIS(post4_1s_df)
end

# ╔═╡ 243a9eea-0e22-11eb-0e83-2d7bbd03f78a
if !isnothing(q4_1s)
	quap4_1s_df = sample(q4_1s)
	PRECIS(quap4_1s_df)
end

# ╔═╡ 62d7694e-fb76-11ea-28c4-4d1e78f54b82
md"### snippet 4.32"

# ╔═╡ 62e3e746-fb76-11ea-327a-21f83959bb7c
md"##### Computed covariance matrix by stan_quap()."

# ╔═╡ bf7e6a2e-0ef6-11eb-3753-d5cddb8365c2
q4_1s.vcov

# ╔═╡ 0857073c-0bd8-11eb-0c3c-777cd67bac01
diag(q4_1s.vcov) .|> sqrt

# ╔═╡ 03c38850-0b68-11eb-3045-d1d65f44f4c4
md"##### Use Particles."

# ╔═╡ fcb54d46-0b67-11eb-221d-87a459b88a94
part_sim = Particles(4000, MvNormal([mean(quap4_1s_df.mu),
	mean(quap4_1s_df.sigma)], q4_1s.vcov))

# ╔═╡ 4fb21aa6-0be5-11eb-3ff7-d55646170d94
begin
	fig1 = plot(part_sim[1], lab="mu")
	fig2 = plot(part_sim[2], lab="sigma")
	plot(fig1, fig2, layout=(1, 2))
end

# ╔═╡ 62ef3826-fb76-11ea-2369-c157a18c626c
md"### snippet 4.33"

# ╔═╡ 62f79ff0-fb76-11ea-323d-074b61eb40f0
md"##### Compute correlation matrix."

# ╔═╡ 62feda92-fb76-11ea-32a4-454502ca4488
cor(Array(sample(q4_1s)))

# ╔═╡ 9d3356ac-9b22-411a-a2c0-dbde136826ed
begin
	chns = read_samples(m4_1s)
	chns.data
end

# ╔═╡ c4d58d17-aedf-4a92-b77f-3e4256beb4a8
axiskeys(chns)

# ╔═╡ 6306bcf8-fb76-11ea-2feb-af94851021ba
md"## End of clip-04-32-33s.jl"

# ╔═╡ Cell order:
# ╟─8e62b178-fb75-11ea-0fd3-f16790f4bf4f
# ╠═62912e52-fb76-11ea-014f-674eaa0c1ded
# ╠═62916bce-fb76-11ea-1d36-77a8b156aabb
# ╟─62920520-fb76-11ea-099e-952976e305a4
# ╠═629f31e6-fb76-11ea-2e8b-774da4fa0cb6
# ╠═62a7bf82-fb76-11ea-3ad9-6bcc0a1b1be3
# ╟─62aebe34-fb76-11ea-1646-d75ffe9ecd49
# ╠═2fc627a0-3cc3-11eb-31a0-47b17099e493
# ╠═62c16610-fb76-11ea-36d5-51093f07a76a
# ╠═243a9eea-0e22-11eb-0e83-2d7bbd03f78a
# ╟─62d7694e-fb76-11ea-28c4-4d1e78f54b82
# ╟─62e3e746-fb76-11ea-327a-21f83959bb7c
# ╠═bf7e6a2e-0ef6-11eb-3753-d5cddb8365c2
# ╠═0857073c-0bd8-11eb-0c3c-777cd67bac01
# ╟─03c38850-0b68-11eb-3045-d1d65f44f4c4
# ╠═fcb54d46-0b67-11eb-221d-87a459b88a94
# ╠═4fb21aa6-0be5-11eb-3ff7-d55646170d94
# ╟─62ef3826-fb76-11ea-2369-c157a18c626c
# ╟─62f79ff0-fb76-11ea-323d-074b61eb40f0
# ╠═62feda92-fb76-11ea-32a4-454502ca4488
# ╠═9d3356ac-9b22-411a-a2c0-dbde136826ed
# ╠═c4d58d17-aedf-4a92-b77f-3e4256beb4a8
# ╟─6306bcf8-fb76-11ea-2feb-af94851021ba
