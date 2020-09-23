
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

md"## Clip-04-07-09s.jl"

DMA_1 = OrderedDict(
  :d => [:a, :m],
  :m => :a
);

DMA_dag_1 = DAG("DMA_dag1", DMA_1)

begin
	fname1 = joinpath(mktempdir(), "DMA_dag_1.dot")
	to_graphviz(DMA_dag_1, fname1)
	Sys.isapple() && run(`open -a GraphViz.app $(fname1)`)
end;

Text(pluto_string(basis_set(DMA_dag_1)))

adjustment_sets(DMA_dag_1, :a, :d)

DMA_2 = OrderedDict(
  [:d, :m] => :a
)

DMA_dag_2 = DAG("DMA_dag_2", DMA_2)

begin
	fname2 = joinpath(mktempdir(), "DMA_dag_2.dot")
	to_graphviz(DMA_dag_2, fname2)
	Sys.isapple() && run(`open -a GraphViz.app $(fname2)`)
end;

Text(pluto_string(basis_set(DMA_dag_2)))

adjustment_sets(DMA_dag_2, :a, :d)

md"## End of clip-05-07-09s.jl"

