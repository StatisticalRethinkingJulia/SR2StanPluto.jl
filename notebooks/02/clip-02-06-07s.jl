### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ f4e4df6a-f2de-11ea-210f-05f38fcb8e26
using Pkg, DrWatson

# ╔═╡ f4e5213c-f2de-11ea-15a6-b1b36f79b689
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
	using PlutoUI
end

# ╔═╡ 2301974a-f2de-11ea-123c-6d4e743fa71c
md"## Clip-02-06-07s.jl"

# ╔═╡ f4e5a9cc-f2de-11ea-0d6b-c7f8fdf3a605
md"### snippet 2.6"

# ╔═╡ f4f2d3ae-f2de-11ea-0986-591fccf0bfcb
md"##### The Stan language model."

# ╔═╡ f4fa0a5c-f2de-11ea-0c13-67e466b46681
stan2_0 = "
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

# ╔═╡ f50bbb1c-f2de-11ea-0a71-f5dc72196881
md"##### Use 9 observations as input data for stan_sample."

# ╔═╡ f50cd894-f2de-11ea-2246-33ef06f78d3c
begin
	w = 6
	l = 3
	data = Dict(:w => w, :l => l)
end;

# ╔═╡ f1a9ca74-29e6-11eb-0a25-a5e20b4e9db7
md"##### Obtain stan_quap() samples."

# ╔═╡ e0bb5132-1006-11eb-3136-3bbc6301f8c2
begin
	q2_0s, m2_0s, om2_0s = StanQuap.stan_quap("m2.0s", stan2_0; data)
	if !isnothing(m2_0s)
		post2_0s_df = read_samples(m2_0s, :dataframe)
		PRECIS(post2_0s_df)
	end
end

# ╔═╡ f654a0e6-81ca-11eb-1166-2bfaeebe1d4d
if !isnothing(q2_0s)
	quap2_0s_df = sample(q2_0s)
	with_terminal() do
		precis(quap2_0s_df)
	end
end

# ╔═╡ f521d852-f2de-11ea-2ed5-2bd626644c7c
md"### snippet 2.7"

# ╔═╡ f52f5d6a-f2de-11ea-2bf4-5175c412ef56
if !isnothing(q2_0s)
	x = 0.0:0.01:1.0
 	density(post2_0s_df.theta, lab="Stan samples")
 	plot!( x, pdf.(Beta( w+1 , l+1 ) , x ), lab="Conjugate solution")
 	plot!( x, pdf.(Normal(mean(quap2_0s_df.theta), std(quap2_0s_df.theta)) , x ),
		lab="Stan quap solution")
	density!(quap2_0s_df.theta, lab="Particle quap solution")
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
# ╟─f50bbb1c-f2de-11ea-0a71-f5dc72196881
# ╠═f50cd894-f2de-11ea-2246-33ef06f78d3c
# ╟─f1a9ca74-29e6-11eb-0a25-a5e20b4e9db7
# ╠═e0bb5132-1006-11eb-3136-3bbc6301f8c2
# ╠═f654a0e6-81ca-11eb-1166-2bfaeebe1d4d
# ╟─f521d852-f2de-11ea-2ed5-2bd626644c7c
# ╠═f52f5d6a-f2de-11ea-2bf4-5175c412ef56
# ╟─f5377072-f2de-11ea-3703-05a2357a9cfa
