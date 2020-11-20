### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 105d9a64-0fd3-11eb-192d-d37c599b9dc2
using Pkg, DrWatson

# ╔═╡ 1341e8f2-0fd3-11eb-1511-47cd22733425
begin
	@quickactivate "StatisticalRethinkingStan"
	using StructuralCausalModels
	using StatisticalRethinking
end

# ╔═╡ 97cd0aea-0fd1-11eb-0521-8903ecc73a1e
md"## Dag-06-02.jl"

# ╔═╡ 1342211e-0fd3-11eb-0fb5-cd39a62203a6
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

# ╔═╡ 1342b30e-0fd3-11eb-2ccb-394372532970
Text(precis(df; io=String))

# ╔═╡ 13541126-0fd3-11eb-0529-e762f8366698
StatsPlots.cornerplot(Array(df), label=names(df))

# ╔═╡ 8c2f36b8-0fd1-11eb-1400-e7ca54fe97f2
begin
	d = OrderedDict(
	  [:w, :m, :a] => :s,
	  :d => [:a, :w, :m],
	  :m => [:a]
	);

	dag6_2 = DAG("dag6.2", d, df=df)
end

# ╔═╡ 4bbb315c-0fd3-11eb-0b32-f70ce8b38cd3
begin
	fname = mktempdir() * "/dag6.2.dot"
	to_graphviz(dag6_2, fname)
	Sys.isapple() && run(`open -a GraphViz.app $(fname)`)
end;

# ╔═╡ 4bbb7266-0fd3-11eb-060f-f1a72f82ca30
dag6_2.s

# ╔═╡ 4bbc19f0-0fd3-11eb-30b6-7f8cd384b710
Text(pluto_string(basis_set(dag6_2)))

# ╔═╡ 4bc968da-0fd3-11eb-31ab-7133a99fb3ed
t = shipley_test(dag6_2)

# ╔═╡ 4bc9fb06-0fd3-11eb-1c5c-f91ca46cb479
begin
	f = :w; s = :d;
	e = d_separation(dag6_2, [f], [s], c=[:m, :a])
end

# ╔═╡ 4bd7c590-0fd3-11eb-2b79-c9560ef98ee4
ap = all_paths(dag6_2, f, s)

# ╔═╡ 4bd87064-0fd3-11eb-276d-ed4ff376be3d
bp = backdoor_paths(dag6_2, ap, f)

# ╔═╡ 4be6d776-0fd3-11eb-3b49-69805f91a0b8
adjustmentsets = adjustment_sets(dag6_2, :w, :d)

# ╔═╡ 4be77730-0fd3-11eb-085b-fbc552a4e865
md"## End of dag-06-02.jl"

# ╔═╡ Cell order:
# ╠═97cd0aea-0fd1-11eb-0521-8903ecc73a1e
# ╠═105d9a64-0fd3-11eb-192d-d37c599b9dc2
# ╠═1341e8f2-0fd3-11eb-1511-47cd22733425
# ╠═1342211e-0fd3-11eb-0fb5-cd39a62203a6
# ╠═1342b30e-0fd3-11eb-2ccb-394372532970
# ╠═13541126-0fd3-11eb-0529-e762f8366698
# ╠═8c2f36b8-0fd1-11eb-1400-e7ca54fe97f2
# ╠═4bbb315c-0fd3-11eb-0b32-f70ce8b38cd3
# ╠═4bbb7266-0fd3-11eb-060f-f1a72f82ca30
# ╠═4bbc19f0-0fd3-11eb-30b6-7f8cd384b710
# ╠═4bc968da-0fd3-11eb-31ab-7133a99fb3ed
# ╠═4bc9fb06-0fd3-11eb-1c5c-f91ca46cb479
# ╠═4bd7c590-0fd3-11eb-2b79-c9560ef98ee4
# ╠═4bd87064-0fd3-11eb-276d-ed4ff376be3d
# ╠═4be6d776-0fd3-11eb-3b49-69805f91a0b8
# ╟─4be77730-0fd3-11eb-085b-fbc552a4e865
