### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 2d9b943a-fd04-11ea-2072-4bffc42a2fdf
using Pkg, DrWatson

# ╔═╡ 2d9bd37a-fd04-11ea-2509-4b297c013e6d
begin
	@quickactivate "StatisticalRethinkingStan"
	using StructuralCausalModels
	using StatisticalRethinking
end

# ╔═╡ 1fbdbf76-fd03-11ea-03fb-a52d9bfd4d4c
md"## Clip-04-07-09s.jl"

# ╔═╡ fea4ccac-01d1-11eb-2456-67b005bf8512
md"### snippet 5.7"

# ╔═╡ 1636dc9a-4244-11eb-2c12-cde10a99d0ed
md"##### DMA_1 specifies a causal link from :a to :d (:a directly influences :d) and from :m to :d. Furthermore, there is also a causal link from :a to :m."

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
	Text(read(fname1, String))
end

# ╔═╡ d38bfda6-3106-11eb-3df8-9b9747437288
Sys.isapple() && run(`open -a GraphViz.app $(fname1)`);

# ╔═╡ 36ca0908-01d7-11eb-2783-bb2f25bd2f17
md"### snippet 5.9"

# ╔═╡ 2db49e3c-fd04-11ea-2343-0d29f51022cc
Text(pluto_string(basis_set(DMA_dag_1)))

# ╔═╡ a8f18662-01d4-11eb-01d1-197483e27bd0
md"##### `DMA_dag_1` has no implied conditional independencies.  This means all 3 variables are associated (even after conditioning). This is a testable implications."

# ╔═╡ 2db8f448-fd04-11ea-0ee9-1ff203ccb3cb
adjustment_sets(DMA_dag_1, :a, :d)

# ╔═╡ cbdb6fea-01d5-11eb-0ce3-131585c3339b
md"##### `DMA_dag_1` has no adjustment sets when regressing `:d` on `:a`."

# ╔═╡ 4458c102-01d7-11eb-3d8c-93f9129401fc
md"### snippet 5.8"

# ╔═╡ 2dbfc582-fd04-11ea-2086-e1f761ff9365
DMA_2 = OrderedDict(
  [:d, :m] => :a
)

# ╔═╡ 2dc0543e-fd04-11ea-39c9-6d3da3587f12
DMA_dag_2 = DAG("DMA_dag_2", DMA_2)

# ╔═╡ 2dcccbba-fd04-11ea-104d-797e2b94ebbb
begin
	fname2 = joinpath(mktempdir(), "DMA_dag_2.dot")
	to_graphviz(DMA_dag_2, fname2)
	Text(read(fname2, String))
end

# ╔═╡ 25e479d4-3107-11eb-3912-2fb85b82743f
Sys.isapple() && run(`open -a GraphViz.app $(fname2)`);

# ╔═╡ 18f56d12-fd10-11ea-02a2-c77de8c1416b
Text(pluto_string(basis_set(DMA_dag_2)))

# ╔═╡ f199e5a2-01d5-11eb-3b15-95701444ac4d
md"##### `DMA_dag_2` has 1 testable conditional independence (:d and :m are independent after conditioning on :a). Otherwise all pairs of variables are associated."

# ╔═╡ 2dd8856a-fd04-11ea-1486-2f3c7dd650bb
adjustment_sets(DMA_dag_2, :a, :d)

# ╔═╡ 104634ec-01d6-11eb-186a-7f870a0f4cb8
md"##### `DMA_dag_2` has no adjustment sets."

# ╔═╡ 2de11e4e-fd04-11ea-3d2a-3b1a3dbaeb63
md"## End of clip-05-07-09s.jl"

# ╔═╡ Cell order:
# ╟─1fbdbf76-fd03-11ea-03fb-a52d9bfd4d4c
# ╠═2d9b943a-fd04-11ea-2072-4bffc42a2fdf
# ╠═2d9bd37a-fd04-11ea-2509-4b297c013e6d
# ╟─fea4ccac-01d1-11eb-2456-67b005bf8512
# ╟─1636dc9a-4244-11eb-2c12-cde10a99d0ed
# ╠═2d9c5a52-fd04-11ea-3ea7-c1990f74f046
# ╠═2da77b08-fd04-11ea-2ed1-adedc0ada52b
# ╠═2dabbff6-fd04-11ea-1990-abf87ec712da
# ╠═d38bfda6-3106-11eb-3df8-9b9747437288
# ╟─36ca0908-01d7-11eb-2783-bb2f25bd2f17
# ╠═2db49e3c-fd04-11ea-2343-0d29f51022cc
# ╟─a8f18662-01d4-11eb-01d1-197483e27bd0
# ╠═2db8f448-fd04-11ea-0ee9-1ff203ccb3cb
# ╟─cbdb6fea-01d5-11eb-0ce3-131585c3339b
# ╟─4458c102-01d7-11eb-3d8c-93f9129401fc
# ╠═2dbfc582-fd04-11ea-2086-e1f761ff9365
# ╠═2dc0543e-fd04-11ea-39c9-6d3da3587f12
# ╠═2dcccbba-fd04-11ea-104d-797e2b94ebbb
# ╠═25e479d4-3107-11eb-3912-2fb85b82743f
# ╠═18f56d12-fd10-11ea-02a2-c77de8c1416b
# ╟─f199e5a2-01d5-11eb-3b15-95701444ac4d
# ╠═2dd8856a-fd04-11ea-1486-2f3c7dd650bb
# ╟─104634ec-01d6-11eb-186a-7f870a0f4cb8
# ╟─2de11e4e-fd04-11ea-3d2a-3b1a3dbaeb63
