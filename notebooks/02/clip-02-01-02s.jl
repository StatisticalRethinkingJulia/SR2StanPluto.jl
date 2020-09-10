### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 431b8a8c-f2d8-11ea-24fd-d1163faecf19
using Pkg, DrWatson

# ╔═╡ 431bbfd4-f2d8-11ea-3afe-57f83d09e5e4
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 0141727a-f2d8-11ea-08d1-a1b216f3ffee
md"## Clip-02-01-02s.jl"

# ╔═╡ 431f9776-f2d8-11ea-1b0b-311cfa2d41ad
md"### snippet 2.1"

# ╔═╡ 43247cdc-f2d8-11ea-3afb-7757672ed539
begin
	ways  = [0, 3, 8, 9, 0];
	ways/sum(ways)
end

# ╔═╡ 432963dc-f2d8-11ea-1170-a10c13c88fc7
md"### snippet 2.2"

# ╔═╡ 4329e23a-f2d8-11ea-193d-196b19e87ff1
md"##### Create a distribution with n = 9 (e.g. tosses) and p = 0.5."

# ╔═╡ 4334f736-f2d8-11ea-1328-df16f55a4050
d = Binomial(9, 0.5)

# ╔═╡ 4335fb88-f2d8-11ea-2383-611db2ab2904
md"##### Probability density for 6 `waters` holding n = 9 and p = 0.5."

# ╔═╡ 433ef846-f2d8-11ea-3f8e-533dbd4759df
pdf(d, 6)

# ╔═╡ 433f9102-f2d8-11ea-29e5-d708d609ff1e
md"## End of clip-02-01-02s.jl"

# ╔═╡ Cell order:
# ╟─0141727a-f2d8-11ea-08d1-a1b216f3ffee
# ╠═431b8a8c-f2d8-11ea-24fd-d1163faecf19
# ╠═431bbfd4-f2d8-11ea-3afe-57f83d09e5e4
# ╟─431f9776-f2d8-11ea-1b0b-311cfa2d41ad
# ╠═43247cdc-f2d8-11ea-3afb-7757672ed539
# ╠═432963dc-f2d8-11ea-1170-a10c13c88fc7
# ╠═4329e23a-f2d8-11ea-193d-196b19e87ff1
# ╠═4334f736-f2d8-11ea-1328-df16f55a4050
# ╠═4335fb88-f2d8-11ea-2383-611db2ab2904
# ╠═433ef846-f2d8-11ea-3f8e-533dbd4759df
# ╟─433f9102-f2d8-11ea-29e5-d708d609ff1e
