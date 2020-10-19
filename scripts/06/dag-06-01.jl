
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

md"## Dag-06-01.jl"

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

Text(precis(df; io=String))

StatsPlots.cornerplot(Array(df), label=names(df))

begin
	d = OrderedDict(
	  :u => :a,
	  :c => :a,
	  :b => [:u, :c],
	  :y => :c,
	  :x => :u
	)
	u = [:u]

	dag6_1 = DAG("dag6.1", d, df=df)
end

begin
	fname = joinpath(mktempdir(), "sr6.1.dot")
	to_graphviz(dag6_1, fname)
	Sys.isapple() && run(`open -a GraphViz.app $(fname)`)
end;

to_dagitty(dag6_1)

to_ggm(dag6_1)

dag6_1.s

Text(pluto_string(basis_set(dag6_1)))

t = shipley_test(dag6_1)

begin
	f = [:a]
	s = [:b]
	conditioning_set = [:u, :c]
	e = d_separation(dag6_1, f, s, c=conditioning_set)
end

adjustment_sets(dag6_1, :x, :y)

md"##### Not yet implemented:"


md"## End of dag-06-01.jl"

