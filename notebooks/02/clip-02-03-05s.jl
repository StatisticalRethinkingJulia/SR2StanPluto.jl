### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 87fc561c-f2d9-11ea-23db-9db85b2985f5
using Pkg, DrWatson

# ╔═╡ 882509ae-f2d9-11ea-37c8-d76341cf0094
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 088e5b28-f2d9-11ea-0778-1da6a0b64752
md"## Clip-02-03-05s.jl"

# ╔═╡ 882588ae-f2d9-11ea-33ae-85ac7828cff4
md"### snippets 2.3 - 2.5"

# ╔═╡ 88323b44-f2d9-11ea-2bbe-99dfb265b837
md"###### Define a grid."

# ╔═╡ 8832e9be-f2d9-11ea-2f5f-f134b218bd3f
begin
	N = 201
	p_grid = range( 0 , stop=1 , length=N )
end

# ╔═╡ 883d19fe-f2d9-11ea-1d14-c9150b6cb248
md"###### Define three priors."

# ╔═╡ 883de758-f2d9-11ea-1613-6bd1d8167430
begin
	prior = []
	append!(prior, [pdf.(Uniform(0, 1), p_grid)])
	append!(prior, [[p < 0.5 ? 0 : 1 for p in p_grid]])
	append!(prior, [[exp( -5*abs( p - 0.5 ) ) for p in p_grid]])
end

# ╔═╡ 8842c3e0-f2d9-11ea-09a6-97c7be044674
likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid];

# ╔═╡ 884d0e7c-f2d9-11ea-29df-4f16cabad935
begin
	p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
	for i in 1:3
  		j = (i-1)*3 + 1
  		p[j] = plot(p_grid, prior[i], leg=false, ylims=(0, 1), title="Prior")
  		p[j+1] = plot(p_grid, likelihood, leg=false, title="Likelihood")
  		p[j+2] = plot(p_grid, prior[i].*likelihood, leg=false, title="Posterior")
	end
	plot(p..., layout=(3, 3))
end

# ╔═╡ 8853c3b6-f2d9-11ea-0bf1-a117f04cf61c
md"## End of clip-02-03-05s.jl"

# ╔═╡ Cell order:
# ╟─088e5b28-f2d9-11ea-0778-1da6a0b64752
# ╠═87fc561c-f2d9-11ea-23db-9db85b2985f5
# ╠═882509ae-f2d9-11ea-37c8-d76341cf0094
# ╟─882588ae-f2d9-11ea-33ae-85ac7828cff4
# ╟─88323b44-f2d9-11ea-2bbe-99dfb265b837
# ╠═8832e9be-f2d9-11ea-2f5f-f134b218bd3f
# ╟─883d19fe-f2d9-11ea-1d14-c9150b6cb248
# ╠═883de758-f2d9-11ea-1613-6bd1d8167430
# ╠═8842c3e0-f2d9-11ea-09a6-97c7be044674
# ╠═884d0e7c-f2d9-11ea-29df-4f16cabad935
# ╟─8853c3b6-f2d9-11ea-0bf1-a117f04cf61c
