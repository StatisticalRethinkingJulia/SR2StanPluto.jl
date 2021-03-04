### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9778402c-ff65-11ea-2af4-0fb4c0d1e78e
using Pkg, DrWatson

# ╔═╡ 977878f8-ff65-11ea-356c-8b889c8037b4
begin
	@quickactivate "StatisticalRethinkingStan"
	using LinearAlgebra
	using StatisticalRethinking
end

# ╔═╡ 6426d13e-ff65-11ea-0e72-732d3a4de0f1
md"## clip-09-02s.jl"

# ╔═╡ 9778f07e-ff65-11ea-3d7f-35819188f757
md"### Snippet 9.2"

# ╔═╡ 97850170-ff65-11ea-16e9-af62429b511f
md"##### Number of samples."

# ╔═╡ 9785681a-ff65-11ea-3216-2b23598b1bef
T = 1000

# ╔═╡ 9793e066-ff65-11ea-2067-01c3caab76bf
md"##### Compute radial distance."

# ╔═╡ 97946ee6-ff65-11ea-0c08-43c9a52edf8d
rad_dist(x) = sqrt(sum(x .^ 2))

# ╔═╡ 979c7abe-ff65-11ea-2001-336b1bb02638
md"##### Plot densities."

# ╔═╡ 97ad992a-ff65-11ea-1e52-43039c4f5462
begin
	fig = density(xlabel="Radial distance from mode", ylabel="Density")
	for d in [1, 10, 100, 1000]
		m = MvNormal(zeros(d), Diagonal(ones(d)))
		local y = rand(m, T)
		rd = [rad_dist( y[:, i] ) for i in 1:T] 
		density!(rd, lab="d=$d")
	end
	fig
end

# ╔═╡ 97b95942-ff65-11ea-1da3-23a8c109072b
md"## End of clip-09-02s.jl"

# ╔═╡ Cell order:
# ╟─6426d13e-ff65-11ea-0e72-732d3a4de0f1
# ╠═9778402c-ff65-11ea-2af4-0fb4c0d1e78e
# ╠═977878f8-ff65-11ea-356c-8b889c8037b4
# ╟─9778f07e-ff65-11ea-3d7f-35819188f757
# ╟─97850170-ff65-11ea-16e9-af62429b511f
# ╠═9785681a-ff65-11ea-3216-2b23598b1bef
# ╟─9793e066-ff65-11ea-2067-01c3caab76bf
# ╠═97946ee6-ff65-11ea-0c08-43c9a52edf8d
# ╟─979c7abe-ff65-11ea-2001-336b1bb02638
# ╠═97ad992a-ff65-11ea-1e52-43039c4f5462
# ╟─97b95942-ff65-11ea-1da3-23a8c109072b
