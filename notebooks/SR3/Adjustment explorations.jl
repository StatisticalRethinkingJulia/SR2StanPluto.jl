### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# ╔═╡ 859783d0-73c9-4d1a-aab7-1d1bc474389e
using Pkg

# ╔═╡ c80881ad-605b-40fc-a492-d253fef966c8
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
    # General packages
    using LaTeXStrings

	# CausalInference related
	using CausalInference

	# Graphics related packages
	using CairoMakie
	using GraphViz
	
	# Stan related packages
	using StanSample

	# Project functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 00d5774b-5ef0-4d01-b21d-1749beec466a
md"## Adjustment explorations"

# ╔═╡ bd8e4305-bb79-409b-9930-e11e579b8cd0
md"##### Set page layout for notebook."

# ╔═╡ da00c7fe-43ff-4e3a-ab43-0dfd9444f779
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 15%);
	}
</style>
"""

# ╔═╡ 09d39755-53f0-412d-acb3-ba33c7400d32
begin
	g2 = SimpleDiGraph(Edge.([(1, 3), (3, 6), (2, 5), (5, 8), (6, 7), (7, 8), (1, 4), (2, 4), (4, 6), (4, 8)]))
	X = Set(6)
	Y = Set(8)
end

# ╔═╡ be65de6f-35f5-43e9-8004-30dd3f189456
let
	N = 20
	A = rand(N)
	C = rand(N) + 0.4 .* A
	F = rand(N) + 0.5 .* C
	B = rand(N)
	E = rand(N) + 0.4 .* B
	H = rand(N) + 0.5 .* E
	G = rand(N) + 0.4 .* F
	H = rand(N) + 0.5 .* G
	D = rand(N) + 0.2 .* A + 0.3 .* B
	F += 0.9 .* D
	H += 0.95 .* D
	global nt = (A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)
	global df = DataFrame(A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)
end

# ╔═╡ a1412d5f-da0a-48d7-8186-47bdcd931b06
p = 0.25;

# ╔═╡ f378ced9-c1db-457a-93f4-43e864edd116
est_g = pcalg(nt, 0.25, gausscitest)

# ╔═╡ bc3e4cae-ccaf-44b8-be58-1d90e7870350
@time dag_pc = create_pcalg_gauss_dag("pc", df, "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}"; p=p);

# ╔═╡ 74d9e42d-2556-4d68-9ecd-a6aa3644ec7b
gvplot(dag_pc)

# ╔═╡ 8f5372b9-6f66-4154-982e-d726d4b2f3c4
@time dag_ges = create_ges_dag("ges", df, "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}";
	penalty=1.0);

# ╔═╡ 2c067276-fc40-4dc9-8005-af6be72829c8
gvplot(dag_ges)

# ╔═╡ 3c459abd-d64f-4bc6-99c7-fbc82eb3c280
dag_fci = create_fci_dag("fci", df, "Digraph FCI {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}");

# ╔═╡ 8c0fc0b3-5ff9-4943-be6a-05cf27208210
gvplot(dag_fci)

# ╔═╡ e246455c-fa2c-4831-8774-3c52baa55ea8
ancestors(dag_pc.g, X) == Set([1,2,3,4,6])

# ╔═╡ 89fe7a31-e7c2-465d-ba7d-9602941065c0
function ancestors2(d::ROS.AbstractDAG, from::Symbol)

    f = findfirst(x -> x == from, d.vars)
    res = ancestors(d.g, f)
	return [d.vars[i] for i in res]
end

# ╔═╡ b33a6fbe-05fa-4155-a1f2-88725ab16e83
ancestors2(dag_pc, :F)

# ╔═╡ 9c3fc9de-4822-4e98-9f17-a943dacb8d8c
descendants(dag_pc.g, X) == Set([6,7,8])

# ╔═╡ 01d76b8d-8667-49f4-90a1-9c76a94cf56b
function descendants2(d::ROS.AbstractDAG, from::Symbol)

    f = findfirst(x -> x == from, d.vars)
    res = descendants(d.g, f)
	return [d.vars[i] for i in res]
end

# ╔═╡ d0b84bb6-2e66-43c3-b4c7-15484f5ba14f
descendants2(dag_pc, :F)

# ╔═╡ 543103c9-46f3-4f0f-bea7-4e091d9d870d
alt_test_dsep(dag_pc.g, X, Y, Set([3,4,7]))

# ╔═╡ cdfc6ba0-a859-42fb-9170-c33f80645609
function alt_test_dsep2(d::ROS.AbstractDAG, f::Symbol, l::Symbol, s::Vector{Symbol}=Symbol[]; kwargs...)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end
    return alt_test_dsep(d.g, Set(findfirst(x -> x == f, d.vars)), Set(findfirst(x -> x == l, d.vars)), Set(cond); kwargs...)
end

# ╔═╡ cde38284-3e27-467e-b472-01a4c40291cc
alt_test_dsep2(dag_pc, :F, :H)

# ╔═╡ fa3d9cd0-8740-453b-b653-34259c15eda5
alt_test_dsep2(dag_pc, :F, :H, [:C, :D, :G])

# ╔═╡ 583229e3-352e-4091-9ffb-c8c35a791a50
alt_test_dsep(dag_pc.g, X, Y, Set([4,5,7]))

# ╔═╡ 475d9bfd-21a4-4ff4-83d9-3ab70e82396c
alt_test_dsep2(dag_pc, :F, :H, [:D, :E, :G])

# ╔═╡ bd40b88b-9f08-41ad-a733-12fc5be3746c
alt_test_dsep(dag_pc.g, X, Y, Set([1,4,7]))

# ╔═╡ 09d5125a-26a0-4ec9-8d2d-d69d12635d7e
alt_test_dsep2(dag_pc, :F, :H, [:A, :D, :G])

# ╔═╡ 6385e966-1b57-4c34-b19a-539be73ae4a1
!alt_test_dsep(dag_pc.g, X, Y, Set(7))

# ╔═╡ dc802ef0-6a6f-4454-98e6-9eaddf11f536
alt_test_dsep2(dag_pc, :F, :H, [:G])

# ╔═╡ 520da0ac-0573-4e68-9b3d-9954eb6f5dbf
!alt_test_dsep(dag_pc.g, X, Y, Set([4,7]))

# ╔═╡ f92a0dc7-2b63-4025-81c7-30be354cb2a0
alt_test_dsep2(dag_pc, :F, :H, [:D, :G])

# ╔═╡ bb44baa3-314c-47be-9d7b-a8734aa9e170
!alt_test_backdoor(dag_pc.g, X, Y, Set([3,4,7]))

# ╔═╡ ae5e81d0-e008-4a61-b1a2-ae554d504d07
backdoor_criterion(dag_pc, :F, :H, [:C, :D, :G])

# ╔═╡ 90a9f758-da8f-4ecd-a7c5-1b8aa491f036
function alt_test_backdoor2(d::ROS.AbstractDAG, from::Symbol, to::Symbol, s::Vector{Symbol}=Symbol[])

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    alt_test_backdoor(d.g, Set(f), Set(l), Set(cond))
end

# ╔═╡ 963eb747-419e-4a88-96d8-e14a59564ca1
alt_test_backdoor2(dag_pc, :F, :H, [:C, :D, :G])

# ╔═╡ fa214c43-3fb6-4cfd-8b34-f75e71d59bb2
!alt_test_backdoor(dag_pc.g, X, Y, Set([3,5]))

# ╔═╡ 1659fb5f-15ed-41f9-81fb-c177a4f80cf1
alt_test_backdoor2(dag_pc, :F, :H, [:C, :E])

# ╔═╡ 57eab6bd-3204-4479-bdf1-f61e12c9fec7
alt_test_backdoor(dag_pc.g, X, Y, Set([4,2]))

# ╔═╡ 71b37e78-b00b-4fdb-8cbe-60b7480f0635
alt_test_backdoor2(dag_pc, :F, :H, [:C, :D, :G])

# ╔═╡ fb13c83a-c004-42e3-882a-92dcc07c1058
test_covariate_adjustment(dag_pc.g, X, Y, Set([3,4]))

# ╔═╡ 1bd0e17f-6e11-4f96-992b-af4accdc36f5
function test_covariate_adjustment2(d::ROS.AbstractDAG, from::Symbol, to::Symbol, s::Vector{Symbol}=Symbol[])

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    test_covariate_adjustment(d.g, Set(f), Set(l), Set(cond))
end

# ╔═╡ 6c54d08f-9b74-4faa-ae4c-fd5bbd127d95
test_covariate_adjustment2(dag_pc, :F, :H, [:C, :D])

# ╔═╡ ee20a363-6ea2-41c8-95aa-3987efdbe890
!test_covariate_adjustment(dag_pc.g, X, Y, Set([2,4,7]))

# ╔═╡ c075c038-e621-496a-aabd-5a9cb6ab4a30
test_covariate_adjustment2(dag_pc, :F, :H, [:B, :D, :G])

# ╔═╡ 39485be5-31bd-431d-879c-e231ee40e181
test_covariate_adjustment(dag_pc.g, X, Y, Set([5,4]))

# ╔═╡ ac7bdea8-1eb1-4f2f-a029-25b999270ec6
test_covariate_adjustment2(dag_pc, :F, :H, [:E, :D])

# ╔═╡ 5e5157e3-dc5e-43a8-bc1e-c417f357feea
begin
	function find_dsep2(d::ROS.AbstractDAG, from::Vector{Symbol}, to::Vector{Symbol})
	
	    f = Int[findfirst(x -> x == j, d.vars) for j in from]
	    l = Int[findfirst(x -> x == j, d.vars) for j in to
		]
		return find_dsep(d.g, Set(f), Set(l))
	end
	
	function find_dsep2(d::ROS.AbstractDAG, from::Symbol, to::Symbol, include=Symbol[], exclude=Symbol[])

	    f = findfirst(x -> x == from, d.vars)
	    l = findfirst(x -> x == to, d.vars)
	    incl = Int[findfirst(x -> x == j, d.vars) for j in include]
	    excl = Int[findfirst(x -> x == j, d.vars) for j in setdiff(d.vars, exclude)]
		if length(include) == 0 && length(exclude) == 0
	    	res = Set(find_dsep(d.g, Set(f), Set(l), Set(incl), Set(excl)))
			return [Symbol[d.vars[i] for i in res]]
		else
	    	return find_dsep(d.g, Set(f), Set(l), Set(incl), Set(excl))
		end
	end
end

# ╔═╡ d5cdfb94-9ad2-4a4a-a3e0-5cc7b0af5d93
methods(find_dsep2)

# ╔═╡ 9972b3be-122e-41a5-88d0-0599464418ae
find_dsep(dag_pc.g, X, Y) == Set([1,2,3,4,5,7])

# ╔═╡ 1916e0c7-0a58-472d-9e02-161e22d3e609
find_dsep2(dag_pc, :F, :H)

# ╔═╡ fdc25ad0-6a83-4b55-b5b2-44016d0249cb
find_dsep(dag_pc.g, X, Y, Set{Int64}(), setdiff(Set(1:8), [4,6,8])) == false

# ╔═╡ 943281cd-c8f5-41d4-91fb-e38009353bfd
find_dsep(dag_pc.g, Set([1,6]), Set(2)) == false

# ╔═╡ fd41d40b-5584-4767-bf4c-dd147243d458
find_dsep2(dag_pc, [:A, :F], [:B])

# ╔═╡ 18c5e0cb-e586-4799-9468-8302453f8f03
find_min_dsep(dag_pc.g, X, Y) == Set([3,4,7])

# ╔═╡ 29493226-6af2-4c7f-8756-9e6eb38df3df
find_covariate_adjustment(dag_pc.g, X, Y, Set(7), Set([1,2,3,4,5])) == false

# ╔═╡ 8e1d73b4-b713-4251-aad0-aef968695b37
find_covariate_adjustment(dag_pc.g, X, Y, Set{Int64}(), Set([3,4,5,7])) == Set([3,4,5])

# ╔═╡ 5bd2a324-b9d1-4b9e-a186-0ef5088c8b37
find_backdoor_adjustment(dag_pc.g, X, Y) == Set([1,2,3,4,5])

# ╔═╡ 4124c101-0257-433e-9a26-91c09137e3b6
find_frontdoor_adjustment(dag_pc.g, X, Y) == Set(7)

# ╔═╡ d125d72b-389d-4c53-8584-dd85f705e566
find_min_covariate_adjustment(dag_pc.g, X, Y) ==  Set([3,4])

# ╔═╡ 78522992-2faf-4072-8465-11ad5402c1d6
find_min_backdoor_adjustment(dag_pc.g, X, Y) == Set([3,4])

# ╔═╡ bab94d9a-8231-44e4-a9ae-d6f6a19387da
find_min_frontdoor_adjustment(dag_pc.g, X, Y) == Set(7)

# ╔═╡ 22658676-89da-4301-819f-7b1be9c5fe8f
Set(list_dseps(dag_pc.g, X, Y, Set{Int64}(), Set{Int64}([3,4,5,7]))) == Set([Set([4, 7, 3]), Set([5, 4, 7]), Set([5, 4, 7, 3])])

# ╔═╡ 8176dbc4-2a85-4410-8841-eabbfcb23f19
Set(list_dseps(dag_pc.g, X, Y, Set{Int64}(), Set{Int64}([3,4,5,7])))

# ╔═╡ 1791b7ad-088b-4847-a5dd-a457e951eacd
Set(list_covariate_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2]))) == Set([Set([3,4]), Set([4,5]), Set([3,4,5])])

# ╔═╡ 522686b1-c3a2-46d3-943d-2bd7261e3476
Set(list_covariate_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2])))

# ╔═╡ ffef95e6-d73b-4da9-b155-d9468dd839e0
Set(list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2]))) == Set([Set([3,4]), Set([4,5]), Set([3,4,5])])

# ╔═╡ e6c65963-5aa7-4f5a-9600-0a74475d8656
Set(list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2])))

# ╔═╡ 17e0b653-f468-458c-a9f2-e465662dfc65
list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2]))

# ╔═╡ b1b4d77e-2c39-484e-88bc-b51d510b728b
Set(list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set([3]), setdiff(Set(1:8), [1,2])))

# ╔═╡ 97cba8dc-49d8-4a9a-999d-f706ce231fa1
Set(list_frontdoor_adjustment(dag_pc.g, X, Y)) == Set([Set(7)])

# ╔═╡ 03c68f60-e53b-4643-abb6-2bf0b7084525
Set(list_frontdoor_adjustment(dag_pc.g, X, Y))

# ╔═╡ 3f9edeee-cf4a-440c-9382-050b34d25a7b
dag_pc.vars

# ╔═╡ a51a8347-8765-41b7-b7e4-4e0daa16cd65
setdiff(dag_pc.vars, [:F, :H])

# ╔═╡ cb52c513-ac71-476d-a6d1-f61751546c4d
res = Set(list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2])))

# ╔═╡ 64d258b2-a870-4829-8b33-644e5bc49820
adjustment_sets = [Symbol[dag_pc.vars[i] for i in s] for s in res]

# ╔═╡ 63b318b1-6507-4a9e-923d-66fc63f2adf6
#list_backdoor_adjustment(g, X, Y, I = Set{eltype(g)}(), R = setdiff(Set(vertices(g)), X, Y))
function list_backdoor_adjustments(d::ROS.AbstractDAG, from::Symbol, to::Symbol;
    include=Symbol[], exclude=Symbol[], debug=false)

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    incl = Int[findfirst(x -> x == j, d.vars) for j in include]
    excl = Int[findfirst(x -> x == j, d.vars) for j in setdiff(d.vars, exclude)]
	debug && println("list_backdoor_adjustment(g, $Set($f), $Set($l), $Set($incl), $Set($excl)")
    res =  Set(list_backdoor_adjustment(d.g, Set(f), Set(l), Set(incl), Set(excl)))
	return [Symbol[d.vars[i] for i in j] for j in res]
end

# ╔═╡ 89b17b26-f783-42c9-b458-2db5bc01bd24
list_backdoor_adjustment(dag_pc, :F, :H)

# ╔═╡ a0505327-588a-4d80-b3d4-edeb6b2e3e97
md" ##### :A and :B are not observed, can't be used to adjust."

# ╔═╡ eee9b80b-c102-453e-8112-69b73f390311
list_backdoor_adjustment(dag_pc, :F, :H; exclude=[:A, :B])

# ╔═╡ 0c243a5a-8a3d-4864-a393-56eda6fc82ec
md" #### Adjustment sets must include :C."

# ╔═╡ 61eb92be-f289-4c73-8959-64600a1fea9c
list_backdoor_adjustment(dag_pc, :F, :H; include=[:C], exclude=[:A, :B])

# ╔═╡ 2ab2def3-da31-4593-b4c1-b1d2bb569579
list_backdoor_adjustment(dag_pc, :F, :H; include=[:E, :D], exclude=[:A, :B])

# ╔═╡ 62870e10-5d9b-4eec-8aef-7e887e8775f2
list_backdoor_adjustment(dag_pc, :F, :H; include=[:E, :D], exclude=[:A, :B], debug=true)

# ╔═╡ fde32313-9511-48c7-a5f4-86a1ed66bb98
md" #### Use of `debug` keyword."

# ╔═╡ b787b209-0da7-4987-90ca-e49695de3cfc
list_backdoor_adjustment(dag_pc, :F, :H; include=[:C], exclude=[:A, :B], debug=true)

# ╔═╡ Cell order:
# ╟─00d5774b-5ef0-4d01-b21d-1749beec466a
# ╟─bd8e4305-bb79-409b-9930-e11e579b8cd0
# ╠═da00c7fe-43ff-4e3a-ab43-0dfd9444f779
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╠═09d39755-53f0-412d-acb3-ba33c7400d32
# ╠═be65de6f-35f5-43e9-8004-30dd3f189456
# ╠═a1412d5f-da0a-48d7-8186-47bdcd931b06
# ╠═f378ced9-c1db-457a-93f4-43e864edd116
# ╠═bc3e4cae-ccaf-44b8-be58-1d90e7870350
# ╠═74d9e42d-2556-4d68-9ecd-a6aa3644ec7b
# ╠═8f5372b9-6f66-4154-982e-d726d4b2f3c4
# ╠═2c067276-fc40-4dc9-8005-af6be72829c8
# ╠═3c459abd-d64f-4bc6-99c7-fbc82eb3c280
# ╠═8c0fc0b3-5ff9-4943-be6a-05cf27208210
# ╠═e246455c-fa2c-4831-8774-3c52baa55ea8
# ╠═89fe7a31-e7c2-465d-ba7d-9602941065c0
# ╠═b33a6fbe-05fa-4155-a1f2-88725ab16e83
# ╠═9c3fc9de-4822-4e98-9f17-a943dacb8d8c
# ╠═01d76b8d-8667-49f4-90a1-9c76a94cf56b
# ╠═d0b84bb6-2e66-43c3-b4c7-15484f5ba14f
# ╠═543103c9-46f3-4f0f-bea7-4e091d9d870d
# ╠═cdfc6ba0-a859-42fb-9170-c33f80645609
# ╠═cde38284-3e27-467e-b472-01a4c40291cc
# ╠═fa3d9cd0-8740-453b-b653-34259c15eda5
# ╠═583229e3-352e-4091-9ffb-c8c35a791a50
# ╠═475d9bfd-21a4-4ff4-83d9-3ab70e82396c
# ╠═bd40b88b-9f08-41ad-a733-12fc5be3746c
# ╠═09d5125a-26a0-4ec9-8d2d-d69d12635d7e
# ╠═6385e966-1b57-4c34-b19a-539be73ae4a1
# ╠═dc802ef0-6a6f-4454-98e6-9eaddf11f536
# ╠═520da0ac-0573-4e68-9b3d-9954eb6f5dbf
# ╠═f92a0dc7-2b63-4025-81c7-30be354cb2a0
# ╠═bb44baa3-314c-47be-9d7b-a8734aa9e170
# ╠═ae5e81d0-e008-4a61-b1a2-ae554d504d07
# ╠═90a9f758-da8f-4ecd-a7c5-1b8aa491f036
# ╠═963eb747-419e-4a88-96d8-e14a59564ca1
# ╠═fa214c43-3fb6-4cfd-8b34-f75e71d59bb2
# ╠═1659fb5f-15ed-41f9-81fb-c177a4f80cf1
# ╠═57eab6bd-3204-4479-bdf1-f61e12c9fec7
# ╠═71b37e78-b00b-4fdb-8cbe-60b7480f0635
# ╠═fb13c83a-c004-42e3-882a-92dcc07c1058
# ╠═1bd0e17f-6e11-4f96-992b-af4accdc36f5
# ╠═6c54d08f-9b74-4faa-ae4c-fd5bbd127d95
# ╠═ee20a363-6ea2-41c8-95aa-3987efdbe890
# ╠═c075c038-e621-496a-aabd-5a9cb6ab4a30
# ╠═39485be5-31bd-431d-879c-e231ee40e181
# ╠═ac7bdea8-1eb1-4f2f-a029-25b999270ec6
# ╠═5e5157e3-dc5e-43a8-bc1e-c417f357feea
# ╠═d5cdfb94-9ad2-4a4a-a3e0-5cc7b0af5d93
# ╠═9972b3be-122e-41a5-88d0-0599464418ae
# ╠═1916e0c7-0a58-472d-9e02-161e22d3e609
# ╠═fdc25ad0-6a83-4b55-b5b2-44016d0249cb
# ╠═943281cd-c8f5-41d4-91fb-e38009353bfd
# ╠═fd41d40b-5584-4767-bf4c-dd147243d458
# ╠═18c5e0cb-e586-4799-9468-8302453f8f03
# ╠═29493226-6af2-4c7f-8756-9e6eb38df3df
# ╠═8e1d73b4-b713-4251-aad0-aef968695b37
# ╠═5bd2a324-b9d1-4b9e-a186-0ef5088c8b37
# ╠═4124c101-0257-433e-9a26-91c09137e3b6
# ╠═d125d72b-389d-4c53-8584-dd85f705e566
# ╠═78522992-2faf-4072-8465-11ad5402c1d6
# ╠═bab94d9a-8231-44e4-a9ae-d6f6a19387da
# ╠═22658676-89da-4301-819f-7b1be9c5fe8f
# ╠═8176dbc4-2a85-4410-8841-eabbfcb23f19
# ╠═1791b7ad-088b-4847-a5dd-a457e951eacd
# ╠═522686b1-c3a2-46d3-943d-2bd7261e3476
# ╠═ffef95e6-d73b-4da9-b155-d9468dd839e0
# ╠═e6c65963-5aa7-4f5a-9600-0a74475d8656
# ╠═17e0b653-f468-458c-a9f2-e465662dfc65
# ╠═b1b4d77e-2c39-484e-88bc-b51d510b728b
# ╠═97cba8dc-49d8-4a9a-999d-f706ce231fa1
# ╠═03c68f60-e53b-4643-abb6-2bf0b7084525
# ╠═3f9edeee-cf4a-440c-9382-050b34d25a7b
# ╠═a51a8347-8765-41b7-b7e4-4e0daa16cd65
# ╠═cb52c513-ac71-476d-a6d1-f61751546c4d
# ╠═64d258b2-a870-4829-8b33-644e5bc49820
# ╠═63b318b1-6507-4a9e-923d-66fc63f2adf6
# ╠═89b17b26-f783-42c9-b458-2db5bc01bd24
# ╟─a0505327-588a-4d80-b3d4-edeb6b2e3e97
# ╠═eee9b80b-c102-453e-8112-69b73f390311
# ╟─0c243a5a-8a3d-4864-a393-56eda6fc82ec
# ╠═61eb92be-f289-4c73-8959-64600a1fea9c
# ╠═2ab2def3-da31-4593-b4c1-b1d2bb569579
# ╠═62870e10-5d9b-4eec-8aef-7e887e8775f2
# ╟─fde32313-9511-48c7-a5f4-86a1ed66bb98
# ╠═b787b209-0da7-4987-90ca-e49695de3cfc
