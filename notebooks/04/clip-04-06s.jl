### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 3bd0847c-f2b4-11ea-35d8-c7657a170cf9
using Pkg, DrWatson

# ╔═╡ 3bd0c52c-f2b4-11ea-09e6-05dbd556433f
begin
	using Distributions
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using PlutoUI
end

# ╔═╡ 28342aca-f2b1-11ea-342d-95590e306ff4
md"## Clip-04-06s.jl"

# ╔═╡ 3c567b9a-f2b4-11ea-2798-b5b3bffc3f84
md"## snippet 4.6"

# ╔═╡ 3c60487a-f2b4-11ea-32f7-abda1ad883cf
md"###### Grid of 1001 steps."

# ╔═╡ 3c6a0c78-f2b4-11ea-12a9-a506e7a7cacb
p_grid = range(0, step=0.001, stop=1);

# ╔═╡ 3c7435ce-f2b4-11ea-36a4-e72a5024cfa3
md"###### All priors = 1.0."

# ╔═╡ 3c7f4458-f2b4-11ea-3006-fb69892e25da
prior = ones(length(p_grid));

# ╔═╡ 3c89c428-f2b4-11ea-3216-7dab773dfe79
md"###### Binomial pdf."

# ╔═╡ 3c9436d8-f2b4-11ea-3b46-fbfefa79d535
likelihood = [pdf(Binomial(9, p), 6) for p in p_grid];

# ╔═╡ 3ca753ee-f2b4-11ea-21f5-93f4fee09437
md"###### A Uniform prior has been used, unstandardized posterior is equal to likelihood."

# ╔═╡ 3cab5208-f2b4-11ea-0cff-ddab2410c607
posterior = likelihood .* prior;

# ╔═╡ 3cb6dac6-f2b4-11ea-0c94-a109c74c2d22
md"###### Scale posterior such that they become probabilities."

# ╔═╡ 3cc23a06-f2b4-11ea-3dd3-c5ca6ebe71c3
posterior2 = posterior / sum(posterior);

# ╔═╡ 3cd03f70-f2b4-11ea-1877-11b0102993c8
md"###### Sample using the computed posterior values as weights. In this example we keep the number of samples equal to the length of p_grid, but that is not required."

# ╔═╡ 3cdd29a6-f2b4-11ea-071d-fb6328c01d5f
begin
	samples = sample(p_grid, Weights(posterior), length(p_grid));
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	figs[1] = scatter(1:length(p_grid), samples, markersize = 2, ylim=(0.0, 1.3), lab="Draws")
end

# ╔═╡ 3ce9eac4-f2b4-11ea-0bf6-9f130255ec5a
md"###### Analytical calculation."

# ╔═╡ 3cf665a6-f2b4-11ea-29ad-19ecaf1f423a
begin
	w = 6
	n = 9
	x = 0:0.01:1
	figs[2] = density(samples, ylim=(0.0, 3.0), lab="Sample density", leg=:topleft)
	figs[2] = plot!( x, pdf.(Beta( w+1 , n-w+1 ) , x ), lab="Conjugate solution")
end

# ╔═╡ 3d03bb5c-f2b4-11ea-315e-6fac666895eb
md"###### Quadratic approximation."

# ╔═╡ 3d11472c-f2b4-11ea-3bf6-9d517b13b291
begin
	figs[2] = density(samples, ylim=(0.0, 4.0), lab="Sample density")
	figs[2] = plot!( x, pdf.(Beta( w+1 , n-w+1 ) , x ), lab="Conjugate solution", leg=:topright)

	plot!( figs[2], x, pdf.(Normal( 0.67 , 0.16 ) , x ), lab="Normal approximation",
		fill=(0, .5,:orange))
	plot(figs..., layout=(1, 2))
end

# ╔═╡ 3d1db2f0-f2b4-11ea-3bde-29b8f0be3087
md"## End of clip-04-06s.jl"

# ╔═╡ Cell order:
# ╟─28342aca-f2b1-11ea-342d-95590e306ff4
# ╠═3bd0847c-f2b4-11ea-35d8-c7657a170cf9
# ╠═3bd0c52c-f2b4-11ea-09e6-05dbd556433f
# ╟─3c567b9a-f2b4-11ea-2798-b5b3bffc3f84
# ╟─3c60487a-f2b4-11ea-32f7-abda1ad883cf
# ╠═3c6a0c78-f2b4-11ea-12a9-a506e7a7cacb
# ╟─3c7435ce-f2b4-11ea-36a4-e72a5024cfa3
# ╠═3c7f4458-f2b4-11ea-3006-fb69892e25da
# ╟─3c89c428-f2b4-11ea-3216-7dab773dfe79
# ╠═3c9436d8-f2b4-11ea-3b46-fbfefa79d535
# ╟─3ca753ee-f2b4-11ea-21f5-93f4fee09437
# ╠═3cab5208-f2b4-11ea-0cff-ddab2410c607
# ╟─3cb6dac6-f2b4-11ea-0c94-a109c74c2d22
# ╠═3cc23a06-f2b4-11ea-3dd3-c5ca6ebe71c3
# ╟─3cd03f70-f2b4-11ea-1877-11b0102993c8
# ╠═3cdd29a6-f2b4-11ea-071d-fb6328c01d5f
# ╟─3ce9eac4-f2b4-11ea-0bf6-9f130255ec5a
# ╠═3cf665a6-f2b4-11ea-29ad-19ecaf1f423a
# ╟─3d03bb5c-f2b4-11ea-315e-6fac666895eb
# ╠═3d11472c-f2b4-11ea-3bf6-9d517b13b291
# ╟─3d1db2f0-f2b4-11ea-3bde-29b8f0be3087
