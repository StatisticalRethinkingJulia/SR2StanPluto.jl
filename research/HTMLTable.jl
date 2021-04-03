### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 79789782-8d97-11eb-112c-fd8c2c294527
using Pkg, DrWatson

# ╔═╡ dd81850e-8d97-11eb-0cff-8bf4f38f0660
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
	using BrowseTables, Tables
end

# ╔═╡ 3cb90c0e-8db1-11eb-324a-0f66762c31f6
md" ## HTMLTable.jl"

# ╔═╡ 83d6ef06-8e48-11eb-3cf2-f93f08c47e5d
md" ##### rethinking result:"

# ╔═╡ 24856618-d93c-4467-b04b-b952117bfed6
begin
	# make example table, but any table that supports Tables.jl will work
	table = Tables.columntable(collect(i == 5 ?
			(a = missing, b = "string", c = nothing) :
			(a = i, b = Float64(i), c = 'a'-1+i) for i in 1:10))
end;

# ╔═╡ 2e1e3519-81ad-4124-9e2a-c3128465be46
HTMLTable(table) # show HTML table using Julia's display system

# ╔═╡ Cell order:
# ╠═3cb90c0e-8db1-11eb-324a-0f66762c31f6
# ╠═79789782-8d97-11eb-112c-fd8c2c294527
# ╠═dd81850e-8d97-11eb-0cff-8bf4f38f0660
# ╟─83d6ef06-8e48-11eb-3cf2-f93f08c47e5d
# ╠═24856618-d93c-4467-b04b-b952117bfed6
# ╠═2e1e3519-81ad-4124-9e2a-c3128465be46
