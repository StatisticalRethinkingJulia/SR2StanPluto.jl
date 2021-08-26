### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 3fbe924e-f792-11ea-1cb2-5d1fb71e77b3
using Pkg, DrWatson

# ╔═╡ 3fbec6ec-f792-11ea-0a62-83a272a57a5b
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
	using PrettyTables
end

# ╔═╡ b3057494-f791-11ea-3ec6-1587562245eb
md"## Intro-logpdf-1s.jl"

# ╔═╡ 3fbf493c-f792-11ea-06b2-adf07fe86716
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df2 = filter(row -> row[:age] >= 18, df)
end;

# ╔═╡ 3fca0eaa-f792-11ea-2a3d-75f1f0db58b2
md"##### This is an alternative way of writing the Stan language model for the heights example."

# ╔═╡ 3fd3ad14-f792-11ea-2edc-6f151b03b780
md"##### This is referred to in chapter 9. The model block resembles the way loglik() functions used for Optim are constructed."

# ╔═╡ 3fd42ba4-f792-11ea-22ef-272a936150d1
heightsmodel = "
// Inferring a Rate
data {
  int<lower=1> N;
  real<lower=0> h[N];
}
parameters {
  real mu;
  real<lower=0,upper=250> sigma;
}
model {
  // Priors for mu and sigma
  target += normal_lpdf(mu | 178, 20);

  // Observed heights, add loglikelihood to target
  target += normal_lpdf(h | mu, sigma);
}
";

# ╔═╡ 3fddb2dc-f792-11ea-2602-f16d4a595972
sm = SampleModel("heights", heightsmodel);

# ╔═╡ 3fde4396-f792-11ea-3fb2-336c91f459d3
heightsdata = Dict("N" => length(df2[:, :height]), "h" =>df2.height);

# ╔═╡ 3fe6c480-f792-11ea-1faa-cdec32a7d865
rc = stan_sample(sm, data=heightsdata);

# ╔═╡ 3fefbbe4-f792-11ea-3602-612bbf22dc17
if success(rc)
 	chns = read_samples(sm)
	CHNS(chns)
end

# ╔═╡ 1288ad5f-1a74-4ed4-9065-420c9bb28139
axiskeys(chns)

# ╔═╡ cdd365e8-92f0-442c-9714-d005d0897a7b
HTML(pretty_table(String, chns[1:3, 1:2, :], backend=:html))

# ╔═╡ 3ff6ee3c-f792-11ea-1aa9-e129fcaf7171
md"## End intro-logpdf-1s.jl"

# ╔═╡ Cell order:
# ╟─b3057494-f791-11ea-3ec6-1587562245eb
# ╠═3fbe924e-f792-11ea-1cb2-5d1fb71e77b3
# ╠═3fbec6ec-f792-11ea-0a62-83a272a57a5b
# ╠═3fbf493c-f792-11ea-06b2-adf07fe86716
# ╟─3fca0eaa-f792-11ea-2a3d-75f1f0db58b2
# ╟─3fd3ad14-f792-11ea-2edc-6f151b03b780
# ╠═3fd42ba4-f792-11ea-22ef-272a936150d1
# ╠═3fddb2dc-f792-11ea-2602-f16d4a595972
# ╠═3fde4396-f792-11ea-3fb2-336c91f459d3
# ╠═3fe6c480-f792-11ea-1faa-cdec32a7d865
# ╠═3fefbbe4-f792-11ea-3602-612bbf22dc17
# ╠═1288ad5f-1a74-4ed4-9065-420c9bb28139
# ╠═cdd365e8-92f0-442c-9714-d005d0897a7b
# ╟─3ff6ee3c-f792-11ea-1aa9-e129fcaf7171
