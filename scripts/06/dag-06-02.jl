
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StructuralCausalModels
	using StatisticalRethinking
end

md"## Dag-06-02.jl"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';')
	df = DataFrame(
	  :s => df[:, :South],
	  :a => df[:, :MedianAgeMarriage],
	  :m => df[:, :Marriage],
	  :w => df[:, :WaffleHouses],
	  :d => df[:, :Divorce]
	)
end;

Text(precis(df; io=String))

StatsPlots.cornerplot(Array(df), label=names(df))

begin
	d = OrderedDict(
	  [:w, :m, :a] => :s,
	  :d => [:a, :w, :m],
	  :m => [:a]
	);

	dag6_2 = DAG("dag6.2", d, df=df)
end

begin
	fname = mktempdir() * "/dag6.2.dot"
	to_graphviz(dag6_2, fname)
	Sys.isapple() && run(`open -a GraphViz.app $(fname)`)
end;

dag6_2.s

Text(pluto_string(basis_set(dag6_2)))

t = shipley_test(dag6_2)

begin
	f = :w; s = :d;
	e = d_separation(dag6_2, [f], [s], c=[:m, :a])
end

ap = all_paths(dag6_2, f, s)

bp = backdoor_paths(dag6_2, ap, f)

adjustmentsets = adjustment_sets(dag6_2, :w, :d)

md"## End of dag-06-02.jl"

