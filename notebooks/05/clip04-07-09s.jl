### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 2d9b943a-fd04-11ea-2072-4bffc42a2fdf
using Pkg, DrWatson

# ╔═╡ 2d9bd37a-fd04-11ea-2509-4b297c013e6d
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

# ╔═╡ 1fbdbf76-fd03-11ea-03fb-a52d9bfd4d4c
md"## Clip-04-07-09s.jl"

# ╔═╡ 2d9c5a52-fd04-11ea-3ea7-c1990f74f046
DMA_1 = OrderedDict(
  :d => [:a, :m],
  :m => :a
);

# ╔═╡ 2da77b08-fd04-11ea-2ed1-adedc0ada52b
DMA_dag_1 = DAG("DMA_dag1", DMA_1)

# ╔═╡ 2dabbff6-fd04-11ea-1990-abf87ec712da
begin
	fname1 = joinpath(mktempdir(), "DMA_dag_1.dot")
	to_graphviz(DMA_dag_1, fname1)
	Sys.isapple() && run(`open -a GraphViz.app $(fname1)`)
end;

# ╔═╡ 2db49e3c-fd04-11ea-2343-0d29f51022cc
basis_set(DMA_dag_1).bs

# ╔═╡ 2db8f448-fd04-11ea-0ee9-1ff203ccb3cb
adjustment_sets(DMA_dag_1, :a, :d)

# ╔═╡ 2dbfc582-fd04-11ea-2086-e1f761ff9365
# DMA_dag2:

DMA_2 = OrderedDict(
  [:d, :m] => :a
)

# ╔═╡ 2dc0543e-fd04-11ea-39c9-6d3da3587f12
DMA_dag_2 = DAG("DMA_dag_2", DMA_2)

# ╔═╡ 2dcccbba-fd04-11ea-104d-797e2b94ebbb
begin
	fname2 = joinpath(mktempdir(), "DMA_dag_2.dot")
	to_graphviz(DMA_dag_2, fname2)
	Sys.isapple() && run(`open -a GraphViz.app $(fname2)`)
end;

# ╔═╡ 2dce7442-fd04-11ea-1f21-d17fbe9d1f8a
bs = basis_set(DMA_dag_2)

# ╔═╡ 18f56d12-fd10-11ea-02a2-c77de8c1416b
pluto_string(basis_set(DMA_dag_2))

# ╔═╡ 9a5bffb6-fd14-11ea-069e-29515517c616
pkg"up"

# ╔═╡ 2dd8856a-fd04-11ea-1486-2f3c7dd650bb
adjustment_sets(DMA_dag_2, :a, :d)

# ╔═╡ 2de11e4e-fd04-11ea-3d2a-3b1a3dbaeb63
md"## End of clip-05-07-09s.jl"

# ╔═╡ Cell order:
# ╟─1fbdbf76-fd03-11ea-03fb-a52d9bfd4d4c
# ╠═2d9b943a-fd04-11ea-2072-4bffc42a2fdf
# ╠═2d9bd37a-fd04-11ea-2509-4b297c013e6d
# ╠═2d9c5a52-fd04-11ea-3ea7-c1990f74f046
# ╠═2da77b08-fd04-11ea-2ed1-adedc0ada52b
# ╠═2dabbff6-fd04-11ea-1990-abf87ec712da
# ╠═2db49e3c-fd04-11ea-2343-0d29f51022cc
# ╠═2db8f448-fd04-11ea-0ee9-1ff203ccb3cb
# ╠═2dbfc582-fd04-11ea-2086-e1f761ff9365
# ╠═2dc0543e-fd04-11ea-39c9-6d3da3587f12
# ╠═2dcccbba-fd04-11ea-104d-797e2b94ebbb
# ╠═2dce7442-fd04-11ea-1f21-d17fbe9d1f8a
# ╠═18f56d12-fd10-11ea-02a2-c77de8c1416b
# ╠═9a5bffb6-fd14-11ea-069e-29515517c616
# ╠═2dd8856a-fd04-11ea-1486-2f3c7dd650bb
# ╟─2de11e4e-fd04-11ea-3d2a-3b1a3dbaeb63
