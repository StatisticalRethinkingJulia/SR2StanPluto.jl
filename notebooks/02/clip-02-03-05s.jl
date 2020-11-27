### A Pluto.jl notebook ###
# v0.12.11

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
md"### snippet 2.3"

# ╔═╡ 88323b44-f2d9-11ea-2bbe-99dfb265b837
md"###### Define a grid."

# ╔═╡ 8832e9be-f2d9-11ea-2f5f-f134b218bd3f
begin
	grid_length = 201
	p_grid = range( 0 , stop=1 , length=grid_length )
end;

# ╔═╡ 1142ab70-00fd-11eb-1f89-1d54a300634c
md"### snippet 2.4"

# ╔═╡ f84f4a88-00fc-11eb-23a2-c9628d2d9c44
begin
	figs1 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
	N = [5, 20, 50]

	for i in 1:3                                         # Decrease p_grip step size
		p_grid = range( 0 , stop=1 , length=N[i] )
		prior = pdf.(Uniform(0, 1), p_grid)
		likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid]
		post = (prior .* likelihood) / sum(prior .* likelihood)
		figs1[i] = plot(p_grid, post, leg=false, title="$(N[i]) points")
		figs1[i] = scatter!(p_grid, post, leg=false)
	end
end

# ╔═╡ 947c9762-00fd-11eb-3354-f5cedc0a755f
plot(figs1..., layout=(1,3))

# ╔═╡ 191a81ec-00fd-11eb-02d1-c3da0afec13a
md"### snippet 2.5"

# ╔═╡ 883d19fe-f2d9-11ea-1d14-c9150b6cb248
md"###### Compare three priors (Fig 2.7)."

# ╔═╡ 883de758-f2d9-11ea-1613-6bd1d8167430
begin
	prior = []
	append!(prior, [pdf.(Uniform(0, 1), p_grid)])
	append!(prior, [[p < 0.5 ? 0 : 1 for p in p_grid]])
	append!(prior, [[exp( -5*abs( p - 0.5 ) ) for p in p_grid]])
end;

# ╔═╡ 8842c3e0-f2d9-11ea-09a6-97c7be044674
likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid];

# ╔═╡ 884d0e7c-f2d9-11ea-29df-4f16cabad935
begin
	figs2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
	for i in 1:3
  		j = (i-1)*3 + 1
  		figs2[j] = plot(p_grid, prior[i], leg=false, ylims=(0, 1), title="Prior")
  		figs2[j+1] = plot(p_grid, likelihood, leg=false, title="Likelihood")
  		figs2[j+2] = plot(p_grid, prior[i].*likelihood, leg=false, title="Posterior")
	end
	plot(figs2..., layout=(3, 3))
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
# ╟─1142ab70-00fd-11eb-1f89-1d54a300634c
# ╠═f84f4a88-00fc-11eb-23a2-c9628d2d9c44
# ╠═947c9762-00fd-11eb-3354-f5cedc0a755f
# ╟─191a81ec-00fd-11eb-02d1-c3da0afec13a
# ╟─883d19fe-f2d9-11ea-1d14-c9150b6cb248
# ╠═883de758-f2d9-11ea-1613-6bd1d8167430
# ╠═8842c3e0-f2d9-11ea-09a6-97c7be044674
# ╠═884d0e7c-f2d9-11ea-29df-4f16cabad935
# ╟─8853c3b6-f2d9-11ea-0bf1-a117f04cf61c
