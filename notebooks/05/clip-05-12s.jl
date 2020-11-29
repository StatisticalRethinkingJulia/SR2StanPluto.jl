### A Pluto.jl notebook ###
# v0.12.14

using Markdown
using InteractiveUtils

# ╔═╡ ce85691e-fc77-11ea-0aee-df1ba52cecd7
using Pkg, DrWatson

# ╔═╡ ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ ce8df1ec-fc77-11ea-1c7d-ad620c19fbbd
for i in 1:3
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

# ╔═╡ 9741f266-fc76-11ea-0689-cd04b7b16135
md"## Clip-05-12s.jl"

# ╔═╡ ce861b20-fc77-11ea-0b79-8dd922420260
md"##### Include models [`m5_1s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.1s.jl), [`m5_2s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.2s.jl) and [`m5_3s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.3s.jl):"

# ╔═╡ 47566d90-fcda-11ea-0662-8fa0dd0583c4
md"##### Normal estimates:"

# ╔═╡ ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
if success(rc5_3s)
	(s1, p1) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM]; 
		title="Particles (Normal) estimates")
	p1
end

# ╔═╡ b04e701c-fcd9-11ea-38ce-414484022e20
s1

# ╔═╡ 318b8252-fcda-11ea-1909-335ff6f1e4af
md"##### Quap estimates:"

# ╔═╡ ce97d09a-fc77-11ea-22c5-1da0cf5c001d
if success(rc5_3s)
	(s2, p2) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM];
		title="Quap estimates", func=quap)
	p2
end

# ╔═╡ 22d5823a-fcda-11ea-07cb-07ee2c78626d
s2

# ╔═╡ cea73280-fc77-11ea-348f-8973a4e7a5d3
md"## End of clip-05-12s.jl"

# ╔═╡ Cell order:
# ╟─9741f266-fc76-11ea-0689-cd04b7b16135
# ╠═ce85691e-fc77-11ea-0aee-df1ba52cecd7
# ╠═ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
# ╟─ce861b20-fc77-11ea-0b79-8dd922420260
# ╠═ce8df1ec-fc77-11ea-1c7d-ad620c19fbbd
# ╟─47566d90-fcda-11ea-0662-8fa0dd0583c4
# ╠═ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
# ╠═b04e701c-fcd9-11ea-38ce-414484022e20
# ╟─318b8252-fcda-11ea-1909-335ff6f1e4af
# ╠═ce97d09a-fc77-11ea-22c5-1da0cf5c001d
# ╠═22d5823a-fcda-11ea-07cb-07ee2c78626d
# ╟─cea73280-fc77-11ea-348f-8973a4e7a5d3
