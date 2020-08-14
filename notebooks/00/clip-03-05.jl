### A Pluto.jl notebook ###
# v0.11.6

using Markdown
using InteractiveUtils

# ╔═╡ 0b586340-de65-11ea-39a9-1be72fd535d5
using DrWatson

# ╔═╡ 0199c268-de65-11ea-145d-7ff65c6ba37e
begin
	using StatisticalRethinking
	using GLM
end

# ╔═╡ c5bf8a48-de64-11ea-0be8-cd41ff1e44aa
md"### clip-03-05.jl"

# ╔═╡ a021c0e4-de64-11ea-10be-53c53e3e2280
@quickactivate "StatisticalRethinkingStan"

# ╔═╡ b85b1474-de64-11ea-089d-b947253b7bb7
md"#### snippet 0.3"

# ╔═╡ 92dba6fc-de64-11ea-1a2a-6fec4bfff88d
md"#### snippet 0.4"

# ╔═╡ 54362642-de65-11ea-31ec-991677bf86a9
begin
	df = (CSV.read(rel_path("..", "data", "Howell1.csv"), DataFrame; delim=';'))
	howell1 = filter(row -> row[:age] >= 18, df);
	first(howell1, 5)
end

# ╔═╡ df4e5f92-de65-11ea-2815-4b96147b9ade
md"##### Fit a linear regression of distance on speed"

# ╔═╡ e99260d4-de65-11ea-2988-1154824a802b
m = lm(@formula(height ~ weight), howell1)

# ╔═╡ ad851604-de65-11ea-3d0c-a33a2e28c4df
md"##### Plot residuals against speed"

# ╔═╡ 220f7abe-de66-11ea-0297-5d4c46c73e6f
scatter( howell1.height, residuals(m), xlab="Height",
  ylab="Model residual values", lab="Model residuals", leg=:bottomright)

# ╔═╡ 6592dcfe-de66-11ea-2705-b5b07acd5c1e
md"### End of 00/clip-04-05.jl"

# ╔═╡ Cell order:
# ╟─c5bf8a48-de64-11ea-0be8-cd41ff1e44aa
# ╠═0b586340-de65-11ea-39a9-1be72fd535d5
# ╠═a021c0e4-de64-11ea-10be-53c53e3e2280
# ╟─b85b1474-de64-11ea-089d-b947253b7bb7
# ╠═0199c268-de65-11ea-145d-7ff65c6ba37e
# ╟─92dba6fc-de64-11ea-1a2a-6fec4bfff88d
# ╠═54362642-de65-11ea-31ec-991677bf86a9
# ╟─df4e5f92-de65-11ea-2815-4b96147b9ade
# ╠═e99260d4-de65-11ea-2988-1154824a802b
# ╟─ad851604-de65-11ea-3d0c-a33a2e28c4df
# ╠═220f7abe-de66-11ea-0297-5d4c46c73e6f
# ╟─6592dcfe-de66-11ea-2705-b5b07acd5c1e
