### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ d92d9128-ff38-11ea-272f-efcfee7b02b8
using Pkg, DrWatson

# ╔═╡ d92dd1c6-ff38-11ea-121e-f39c0c802eb4
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ a89cef42-ff38-11ea-38d7-593e33625297
md"## Clip-06-21s.jl"

# ╔═╡ d92e44a8-ff38-11ea-053c-87f8d3c1f02b
df = sim_happiness();

# ╔═╡ d935f02c-ff38-11ea-2207-fb9bcb82eea0
Text(precis(df; io=String))

# ╔═╡ d936592a-ff38-11ea-1e51-ad81cbe981c7
md"## End of clip-06-21s.jl"

# ╔═╡ Cell order:
# ╟─a89cef42-ff38-11ea-38d7-593e33625297
# ╠═d92d9128-ff38-11ea-272f-efcfee7b02b8
# ╠═d92dd1c6-ff38-11ea-121e-f39c0c802eb4
# ╠═d92e44a8-ff38-11ea-053c-87f8d3c1f02b
# ╠═d935f02c-ff38-11ea-2207-fb9bcb82eea0
# ╟─d936592a-ff38-11ea-1e51-ad81cbe981c7
