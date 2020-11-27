### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 2ee4fbc2-f76f-11ea-3d93-255361bf59bf
using Pkg, DrWatson

# ╔═╡ 2ee54dd2-f76f-11ea-3558-4bee58526bef
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 82c63e9e-f76e-11ea-2211-9f53eef8f1c5
md"## Fig2.6s.jl"

# ╔═╡ 2ee5dc7a-f76f-11ea-21e3-27f29484f62e
md"##### Define a grid."

# ╔═╡ 2ef1bc68-f76f-11ea-35cb-2f037a1b2ef3
begin
	N = 201
	p_grid = range( 0 , stop=1 , length=N)
end;

# ╔═╡ 2ef258b0-f76f-11ea-0dc0-89d11bd4bf3e
md"##### Define three priors."

# ╔═╡ 2f00541c-f76f-11ea-3ff8-675f1eef2261
begin
	prior = []
	append!(prior, [pdf.(Uniform(0, 1), p_grid)])
	append!(prior, [[p < 0.5 ? 0 : 1 for p in p_grid]])
	append!(prior, [[exp( -5*abs( p - 0.5 ) ) for p in p_grid]])
	likelihood = pdf.(Binomial.(9, p_grid), 6)
end;

# ╔═╡ 2f00f65e-f76f-11ea-1f90-a743b56587ff
figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9);

# ╔═╡ 2f0af1d6-f76f-11ea-0663-5fd115ec0389
for i in 1:3
  j = (i-1)*3 + 1
  figs[j] = plot(p_grid, prior[i], leg=false, ylims=(0, 1), title="Prior")
  figs[j+1] = plot(p_grid, likelihood, leg=false, title="Likelihood")
  figs[j+2] = plot(p_grid, prior[i].*likelihood, leg=false, title="Posterior")
end

# ╔═╡ 2f0b7958-f76f-11ea-20fa-5187eb219ed2
plot(figs..., layout=(3, 3))

# ╔═╡ 2f16fcf6-f76f-11ea-134c-2d98715fdf6f
md"## End of Fig2.6s.jl"

# ╔═╡ Cell order:
# ╟─82c63e9e-f76e-11ea-2211-9f53eef8f1c5
# ╠═2ee4fbc2-f76f-11ea-3d93-255361bf59bf
# ╠═2ee54dd2-f76f-11ea-3558-4bee58526bef
# ╟─2ee5dc7a-f76f-11ea-21e3-27f29484f62e
# ╠═2ef1bc68-f76f-11ea-35cb-2f037a1b2ef3
# ╟─2ef258b0-f76f-11ea-0dc0-89d11bd4bf3e
# ╠═2f00541c-f76f-11ea-3ff8-675f1eef2261
# ╠═2f00f65e-f76f-11ea-1f90-a743b56587ff
# ╠═2f0af1d6-f76f-11ea-0663-5fd115ec0389
# ╠═2f0b7958-f76f-11ea-20fa-5187eb219ed2
# ╟─2f16fcf6-f76f-11ea-134c-2d98715fdf6f
