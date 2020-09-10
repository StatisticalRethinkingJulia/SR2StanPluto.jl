### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ f4e4df6a-f2de-11ea-210f-05f38fcb8e26
using Pkg, DrWatson

# ╔═╡ f4e5213c-f2de-11ea-15a6-b1b36f79b689
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 2301974a-f2de-11ea-123c-6d4e743fa71c
md"## Clip-02-06-07s.jl"

# ╔═╡ f4e5a9cc-f2de-11ea-0d6b-c7f8fdf3a605
md"### snippet 2.6"

# ╔═╡ f4f2d3ae-f2de-11ea-0986-591fccf0bfcb
md"##### The Stan language model."

# ╔═╡ f4fa0a5c-f2de-11ea-0c13-67e466b46681
m2_0 = "
// Inferring a Rate
data {
  int w;
  int l;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ uniform(0, 1);

  // Observed Counts
  w ~ binomial(w + l, theta);
}
";

# ╔═╡ f4fa9a76-f2de-11ea-0adf-cd14695dc705
md"##### Define the Stanmodel and set the output format to :mcmcchains."

# ╔═╡ f5051912-f2de-11ea-0dde-9966ea7b7a1a
m2_0s = SampleModel("m2_0s", m2_0);

# ╔═╡ f50bbb1c-f2de-11ea-0a71-f5dc72196881
md"##### Use 9 observations as input data for stan_sample."

# ╔═╡ f50cd894-f2de-11ea-2246-33ef06f78d3c
begin
	w = 6
	l = 3
	m2_0s_data = Dict(:w => w, :l => l);
end

# ╔═╡ f51904de-f2de-11ea-34ef-3d416146dfba
md"##### Sample using stan_sample(,,,)."

# ╔═╡ f5209456-f2de-11ea-106c-79586c01a530
rc = stan_sample(m2_0s, data=m2_0s_data);

# ╔═╡ f521d852-f2de-11ea-2ed5-2bd626644c7c
md"### snippet 2.7"

# ╔═╡ f52f5d6a-f2de-11ea-2bf4-5175c412ef56
if success(rc)
	x = 0.0:0.01:1.0
 	df = read_samples(m2_0s; output_format=:dataframe)
 	quapfit = quap(df)
 	density(df.theta, lab="Stan samples")
 	plot!( x, pdf.(Beta( w+1 , l+1 ) , x ), lab="Conjugate solution")
 	plot!( x, pdf.(Normal(mean(quapfit.theta), std(quapfit.theta)) , x ), lab="Stan quap solution")
end

# ╔═╡ f5377072-f2de-11ea-3703-05a2357a9cfa
md"## End of clip-02-06-07s.jl"

# ╔═╡ Cell order:
# ╟─2301974a-f2de-11ea-123c-6d4e743fa71c
# ╠═f4e4df6a-f2de-11ea-210f-05f38fcb8e26
# ╠═f4e5213c-f2de-11ea-15a6-b1b36f79b689
# ╟─f4e5a9cc-f2de-11ea-0d6b-c7f8fdf3a605
# ╟─f4f2d3ae-f2de-11ea-0986-591fccf0bfcb
# ╠═f4fa0a5c-f2de-11ea-0c13-67e466b46681
# ╟─f4fa9a76-f2de-11ea-0adf-cd14695dc705
# ╠═f5051912-f2de-11ea-0dde-9966ea7b7a1a
# ╟─f50bbb1c-f2de-11ea-0a71-f5dc72196881
# ╠═f50cd894-f2de-11ea-2246-33ef06f78d3c
# ╟─f51904de-f2de-11ea-34ef-3d416146dfba
# ╠═f5209456-f2de-11ea-106c-79586c01a530
# ╟─f521d852-f2de-11ea-2ed5-2bd626644c7c
# ╠═f52f5d6a-f2de-11ea-2bf4-5175c412ef56
# ╟─f5377072-f2de-11ea-3703-05a2357a9cfa
