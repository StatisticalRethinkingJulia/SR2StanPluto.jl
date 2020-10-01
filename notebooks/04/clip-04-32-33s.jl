### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 62912e52-fb76-11ea-014f-674eaa0c1ded
using Pkg, DrWatson

# ╔═╡ 62916bce-fb76-11ea-1d36-77a8b156aabb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
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
m4_2 = "
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

# ╔═╡ 62af493c-fb76-11ea-3fb8-15cf5f21732b
m4_2s = SampleModel("heights", m4_2);

# ╔═╡ 62b97556-fb76-11ea-2914-cf968082c17b
m4_2_data = Dict("N" => length(df.height), "h" => df.height);

# ╔═╡ 62c0286a-fb76-11ea-0db1-91794ac99ae6
rc4_2s = stan_sample(m4_2s, data=m4_2_data);

# ╔═╡ 62c16610-fb76-11ea-36d5-51093f07a76a
if success(rc4_2s)
	dfa4_2s = read_samples(m4_2s; output_format=:dataframe)
	quap4_2s = quap(dfa4_2s)
end

# ╔═╡ 6ba0d690-fb77-11ea-2678-ab0839ca8210
Particles(dfa4_2s)

# ╔═╡ 62d7694e-fb76-11ea-28c4-4d1e78f54b82
md"### snippet 4.32"

# ╔═╡ 62e3e746-fb76-11ea-327a-21f83959bb7c
md"##### Compute covariance matrix."

# ╔═╡ 62e6d8f2-fb76-11ea-1f70-a9c8b2002ca4
cov(Array(dfa4_2s))

# ╔═╡ 62ef3826-fb76-11ea-2369-c157a18c626c
md"### snippet 4.33"

# ╔═╡ 62f79ff0-fb76-11ea-323d-074b61eb40f0
md"##### Compute correlation matrix."

# ╔═╡ 62feda92-fb76-11ea-32a4-454502ca4488
cor(Array(dfa4_2s))

# ╔═╡ 6306bcf8-fb76-11ea-2feb-af94851021ba
md"## End of clip-04-32-34s.jl"

# ╔═╡ Cell order:
# ╟─8e62b178-fb75-11ea-0fd3-f16790f4bf4f
# ╠═62912e52-fb76-11ea-014f-674eaa0c1ded
# ╠═62916bce-fb76-11ea-1d36-77a8b156aabb
# ╟─62920520-fb76-11ea-099e-952976e305a4
# ╠═629f31e6-fb76-11ea-2e8b-774da4fa0cb6
# ╠═62a7bf82-fb76-11ea-3ad9-6bcc0a1b1be3
# ╟─62aebe34-fb76-11ea-1646-d75ffe9ecd49
# ╠═62af493c-fb76-11ea-3fb8-15cf5f21732b
# ╠═62b97556-fb76-11ea-2914-cf968082c17b
# ╠═62c0286a-fb76-11ea-0db1-91794ac99ae6
# ╠═62c16610-fb76-11ea-36d5-51093f07a76a
# ╠═6ba0d690-fb77-11ea-2678-ab0839ca8210
# ╟─62d7694e-fb76-11ea-28c4-4d1e78f54b82
# ╟─62e3e746-fb76-11ea-327a-21f83959bb7c
# ╠═62e6d8f2-fb76-11ea-1f70-a9c8b2002ca4
# ╟─62ef3826-fb76-11ea-2369-c157a18c626c
# ╟─62f79ff0-fb76-11ea-323d-074b61eb40f0
# ╠═62feda92-fb76-11ea-32a4-454502ca4488
# ╟─6306bcf8-fb76-11ea-2feb-af94851021ba
