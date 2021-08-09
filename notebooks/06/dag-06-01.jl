### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 37b25b6c-0fca-11eb-30d6-5535f598aaa0
using Pkg, DrWatson

# ╔═╡ 37b286e6-0fca-11eb-3e6a-d5ab5ea90e7b
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

# ╔═╡ 341f81d2-0fca-11eb-1b58-6b7b5eabfb62
md"## Dag-06-01.jl"

# ╔═╡ 37b2fc52-0fca-11eb-219f-b1666981d04d
begin
	N = 100
	b_AU = 0.5
	b_AC = 3
	b_UX = -1
	b_UB = 2
	b_CB = -1.5
	b_CY = 1
	b_XY = 5

	df = DataFrame(
	  :a => rand(Normal(), N)
	);
	df[!, :u] = rand(Normal(1, 2), N) + b_AU * df[:, :a]
	df[!, :c] = rand(Normal(0, 1), N) + b_AC * df[:, :a]
	df[!, :b] = rand(Normal(1, 1), N) + b_UB * df[:, :u]
	df[!, :x] = rand(Normal(-2, 1), N) + b_UX * df[:, :u]
	df[!, :y] = rand(Normal(1, 2), N) + b_XY * df[:, :x] + b_CY * df[:, :c]
end;

# ╔═╡ 37c260a2-0fca-11eb-0d33-27dcd7ab3971
Text(precis(df; io=String))

# ╔═╡ 37c3189e-0fca-11eb-218d-d96bdfb39d6e
StatsPlots.cornerplot(Array(df), label=names(df))

# ╔═╡ 758d47f6-0fcc-11eb-397a-39c7367983a2
begin
	d = OrderedDict(
	  :u => :a,
	  :c => :a,
	  :b => [:u, :c],
	  :y => :c,
	  :x => :u
	)
	u = [:u]

	dag6_1 = DAG("dag6_1", d, df=df)
end

# ╔═╡ fb10c140-0fc8-11eb-282c-6fd55a6ad00a
begin
	fname = joinpath(mktempdir(), "sr6_1.dot")
	to_graphviz(dag6_1, fname)
	Sys.isapple() && run(`open -a GraphViz.app $(fname)`)
end;

# ╔═╡ 8bd44082-0fcc-11eb-20c7-172b6e851e75
to_dagitty(dag6_1)

# ╔═╡ 8bd473ae-0fcc-11eb-39d9-b7d714632f2a
to_ggm(dag6_1)

# ╔═╡ 8bd50666-0fcc-11eb-0f30-89beb27a18a4
dag6_1.s

# ╔═╡ 8be5475e-0fcc-11eb-327b-617e0455a8cc
Text(pluto_string(basis_set(dag6_1)))

# ╔═╡ 8beeb8d6-0fcc-11eb-3cff-07974d4f96f3
t = shipley_test(dag6_1)

# ╔═╡ 8bf9fcfa-0fcc-11eb-0319-5d443826ea28
begin
	f = [:a]
	s = [:b]
	conditioning_set = [:u, :c]
	e = d_separation(dag6_1, f, s, c=conditioning_set)
end

# ╔═╡ 8c0971e4-0fcc-11eb-113e-eb5b6aaf9ae2
adjustment_sets(dag6_1, :x, :y)

# ╔═╡ aafdca8c-0fcc-11eb-0e09-35fddd6c4c56
md"##### Not yet implemented:"

# ╔═╡ a4d98e04-0fcc-11eb-1ced-21ac5710803c
#adjustment_sets(dag6_1, :x, :y, u)

# ╔═╡ 8c118b0e-0fcc-11eb-3822-cf40af523ac1
md"## End of dag-06-01.jl"

# ╔═╡ Cell order:
# ╟─341f81d2-0fca-11eb-1b58-6b7b5eabfb62
# ╠═37b25b6c-0fca-11eb-30d6-5535f598aaa0
# ╠═37b286e6-0fca-11eb-3e6a-d5ab5ea90e7b
# ╠═37b2fc52-0fca-11eb-219f-b1666981d04d
# ╠═37c260a2-0fca-11eb-0d33-27dcd7ab3971
# ╠═37c3189e-0fca-11eb-218d-d96bdfb39d6e
# ╠═758d47f6-0fcc-11eb-397a-39c7367983a2
# ╠═fb10c140-0fc8-11eb-282c-6fd55a6ad00a
# ╠═8bd44082-0fcc-11eb-20c7-172b6e851e75
# ╠═8bd473ae-0fcc-11eb-39d9-b7d714632f2a
# ╠═8bd50666-0fcc-11eb-0f30-89beb27a18a4
# ╠═8be5475e-0fcc-11eb-327b-617e0455a8cc
# ╠═8beeb8d6-0fcc-11eb-3cff-07974d4f96f3
# ╠═8bf9fcfa-0fcc-11eb-0319-5d443826ea28
# ╠═8c0971e4-0fcc-11eb-113e-eb5b6aaf9ae2
# ╟─aafdca8c-0fcc-11eb-0e09-35fddd6c4c56
# ╠═a4d98e04-0fcc-11eb-1ced-21ac5710803c
# ╟─8c118b0e-0fcc-11eb-3822-cf40af523ac1
