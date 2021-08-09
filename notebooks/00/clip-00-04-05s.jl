### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ ead8af44-dfef-11ea-104e-d7b1bc038f70
using Pkg, DrWatson

# ╔═╡ 0b586340-de65-11ea-39a9-1be72fd535d5
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ c5bf8a48-de64-11ea-0be8-cd41ff1e44aa
md"## Clip-00-04-05s.jl"

# ╔═╡ b85b1474-de64-11ea-089d-b947253b7bb7
md"##### Load packages."

# ╔═╡ 92dba6fc-de64-11ea-1a2a-6fec4bfff88d
md"### snippet 0.4"

# ╔═╡ 54362642-de65-11ea-31ec-991677bf86a9
begin
	df = (CSV.read(sr_path("..", "data", "Howell1.csv"), DataFrame; delim=';'))
	howell1 = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ d4620956-7f57-11eb-0038-ffea229c5f88
md"
!!! note
	As output in Pluto differs from output in e.g. the Julia REPL a number of capitalized functions have been created for Pluto, e.g. PRECIS vs. precis.
"

# ╔═╡ adfe9074-df14-11ea-38a2-a1e45e0b41e4
PRECIS(howell1)

# ╔═╡ df4e5f92-de65-11ea-2815-4b96147b9ade
md"##### Fit a linear regression of weight on height"

# ╔═╡ e99260d4-de65-11ea-2988-1154824a802b
m = lm(@formula(height ~ weight), howell1)

# ╔═╡ ad851604-de65-11ea-3d0c-a33a2e28c4df
md"##### Plot residuals against height"

# ╔═╡ 220f7abe-de66-11ea-0297-5d4c46c73e6f
scatter( howell1.height, residuals(m), xlab="Height",
	ylab="Model residual values", lab="Model residuals", leg=:bottomright)

# ╔═╡ 6592dcfe-de66-11ea-2705-b5b07acd5c1e
md"## End of clip-00-04-05s.jl"

# ╔═╡ Cell order:
# ╟─c5bf8a48-de64-11ea-0be8-cd41ff1e44aa
# ╟─b85b1474-de64-11ea-089d-b947253b7bb7
# ╠═ead8af44-dfef-11ea-104e-d7b1bc038f70
# ╠═0b586340-de65-11ea-39a9-1be72fd535d5
# ╟─92dba6fc-de64-11ea-1a2a-6fec4bfff88d
# ╠═54362642-de65-11ea-31ec-991677bf86a9
# ╟─d4620956-7f57-11eb-0038-ffea229c5f88
# ╠═adfe9074-df14-11ea-38a2-a1e45e0b41e4
# ╟─df4e5f92-de65-11ea-2815-4b96147b9ade
# ╠═e99260d4-de65-11ea-2988-1154824a802b
# ╟─ad851604-de65-11ea-3d0c-a33a2e28c4df
# ╠═220f7abe-de66-11ea-0297-5d4c46c73e6f
# ╟─6592dcfe-de66-11ea-2705-b5b07acd5c1e
