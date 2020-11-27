### A Pluto.jl notebook ###
# v0.12.12

using Markdown
using InteractiveUtils

# ╔═╡ 98ed9a78-f50c-11ea-1d20-7bcaee689a99
using Pkg, DrWatson

# ╔═╡ 98edd6be-f50c-11ea-26c3-ff6ac7641060
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 6e665478-f50c-11ea-1861-3f509f92ac5c
md"## Fig3.6s.jl"

# ╔═╡ 98ee52ec-f50c-11ea-22bc-c1075a60bfed
md"### snippet 3.23"

# ╔═╡ 98f67062-f50c-11ea-23f3-539ae4f7e67b
begin
	N = 10000
	p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
	for j in 1:9

	  prob = j * 0.1
	  d = rand(Binomial(9, prob), N);
	  h = fit(Histogram, d, -0.5:1:9.5)

	  p[j] = plot(xlim=(0,9), xticks=0:9)
	  for (i, w) in enumerate(h.weights)
		plot!(p[j], [i-1, i-1], [0.0, w], color=:blue,
		  leg=false, title="prob=$(round(prob, digits=1))")
	  end
	end
end

# ╔═╡ 98f93450-f50c-11ea-3767-e526c9109464
plot(p..., layout=(3,3))

# ╔═╡ 99019636-f50c-11ea-3ac3-4107ebb330c5
md"## End of Fig3.6s.jl"

# ╔═╡ Cell order:
# ╟─6e665478-f50c-11ea-1861-3f509f92ac5c
# ╠═98ed9a78-f50c-11ea-1d20-7bcaee689a99
# ╠═98edd6be-f50c-11ea-26c3-ff6ac7641060
# ╟─98ee52ec-f50c-11ea-22bc-c1075a60bfed
# ╠═98f67062-f50c-11ea-23f3-539ae4f7e67b
# ╠═98f93450-f50c-11ea-3767-e526c9109464
# ╟─99019636-f50c-11ea-3ac3-4107ebb330c5
