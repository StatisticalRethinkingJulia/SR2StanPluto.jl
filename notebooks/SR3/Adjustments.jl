### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 859783d0-73c9-4d1a-aab7-1d1bc474389e
using Pkg

# ╔═╡ c80881ad-605b-40fc-a492-d253fef966c8
Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

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
md"## SR 2023: Adjustment."

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
	F += D
	H += D
	global df = DataFrame(A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)
end

# ╔═╡ a1412d5f-da0a-48d7-8186-47bdcd931b06
p = 0.25;

# ╔═╡ cf96a450-0680-456d-a178-afba6d3721ff
@time begin
	g_dot_str = "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}"
	est_func = gausscitest
    vars = Symbol.(names(df))
	nt = namedtuple(vars, [df[!, k] for k in vars])
    (g_tuple_list, _) = create_tuple_list(g_dot_str, vars)
end	

# ╔═╡ 5db66288-1193-4f1c-bb51-03f3be399786
@time let
	g3 = pcalg(nt, p, gausscitest)
end

# ╔═╡ 63586904-0755-46a2-9e69-5c796e30679c
@time let
    global g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end

    global est_g = pcalg(nt, p, est_func)
end

# ╔═╡ eeb7d08e-1921-4518-a9d3-5ac6a97591b7
@time let
    # Create d.est_tuple_list
    global est_g_tuple_list = Tuple{Int, Int}[]
    for (f, edge) in enumerate(est_g.fadjlist)
        for l in edge
            push!(est_g_tuple_list, (f, l))
        end
    end
    
    # Create d.est_g_dot_str
    global est_g_dot_str = "digraph est_g_pc {"
    for e in g_tuple_list
        f = e[1]
        l = e[2]
        if length(setdiff(est_g_tuple_list, [(e[2], e[1])])) !== length(est_g_tuple_list)

           est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
        else
            est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]);"
        end
    end
    est_g_dot_str = est_g_dot_str * "}"
end

# ╔═╡ 7f7a84ce-f246-4f79-9db2-1d4946fee186
@time let
    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    global dag_pc_2 = PCDAG("pc", g, g_tuple_list, g_dot_str, Symbol.(names(df)), est_g, est_g_tuple_list,
        est_g_dot_str, p, df, covm)
end;

# ╔═╡ 25b6bcca-4b77-4f5b-a5d4-cbe6a6e8b250
function create_pc_dag_2(name::AbstractString, df::DataFrame, g_dot_str::AbstractString,
    p::Float64=0.25; est_func=gausscitest)

    vars = Symbol.(names(df))
    nt = namedtuple(vars, [df[!, k] for k in vars])
    (g_tuple_list, _) = create_tuple_list(g_dot_str, vars)
	
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end
    
    est_g = pcalg(nt, p, est_func)
	println(g)

    # Create d.est_tuple_list
    est_g_tuple_list = Tuple{Int, Int}[]
    for (f, edge) in enumerate(est_g.fadjlist)
        for l in edge
            push!(est_g_tuple_list, (f, l))
        end
    end
    
    # Create d.est_g_dot_str
    est_g_dot_str = "digraph est_g_$(name) {"
    for e in g_tuple_list
        f = e[1]
        l = e[2]
        if length(setdiff(est_g_tuple_list, [(e[2], e[1])])) !== length(est_g_tuple_list)

           est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
        else
            est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]);"
        end
    end
    est_g_dot_str = est_g_dot_str * "}"

    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    return PCDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_tuple_list,
        est_g_dot_str, p, df, covm)
end


# ╔═╡ bc3e4cae-ccaf-44b8-be58-1d90e7870350
@time dag_pc = create_pc_dag_2("pc", df, "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}", p);

# ╔═╡ d844ca9f-4302-44e6-b4ac-7758b03c8e68
gvplot(dag_pc_2)

# ╔═╡ 74d9e42d-2556-4d68-9ecd-a6aa3644ec7b
gvplot(dag_pc)

# ╔═╡ 3c459abd-d64f-4bc6-99c7-fbc82eb3c280
dag_fci = create_fci_dag("fci", df, "Digraph FCI {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}");

# ╔═╡ 8c0fc0b3-5ff9-4943-be6a-05cf27208210
gvplot(dag_fci)

# ╔═╡ e246455c-fa2c-4831-8774-3c52baa55ea8
ancestors(dag_pc.g, X) == Set([1,2,3,4,6])

# ╔═╡ 9c3fc9de-4822-4e98-9f17-a943dacb8d8c
descendants(dag_pc.g, X) == Set([6,7,8])

# ╔═╡ 543103c9-46f3-4f0f-bea7-4e091d9d870d
alt_test_dsep(dag_pc.g, X, Y, Set([3,4,7]))

# ╔═╡ 583229e3-352e-4091-9ffb-c8c35a791a50
alt_test_dsep(dag_pc.g, X, Y, Set([4,5,7]))

# ╔═╡ bd40b88b-9f08-41ad-a733-12fc5be3746c
alt_test_dsep(dag_pc.g, X, Y, Set([1,4,7]))

# ╔═╡ 6385e966-1b57-4c34-b19a-539be73ae4a1
!alt_test_dsep(dag_pc.g, X, Y, Set(7))

# ╔═╡ 520da0ac-0573-4e68-9b3d-9954eb6f5dbf
!alt_test_dsep(dag_pc.g, X, Y, Set([4,7]))

# ╔═╡ bb44baa3-314c-47be-9d7b-a8734aa9e170
!alt_test_backdoor(dag_pc.g, X, Y, Set([3,4,7]))

# ╔═╡ fa214c43-3fb6-4cfd-8b34-f75e71d59bb2
!alt_test_backdoor(dag_pc.g, X, Y, Set([3,5]))

# ╔═╡ 57eab6bd-3204-4479-bdf1-f61e12c9fec7
alt_test_backdoor(dag_pc.g, X, Y, Set([4,2]))

# ╔═╡ fb13c83a-c004-42e3-882a-92dcc07c1058
test_covariate_adjustment(dag_pc.g, X, Y, Set([3,4]))

# ╔═╡ ee20a363-6ea2-41c8-95aa-3987efdbe890
!test_covariate_adjustment(dag_pc.g, X, Y, Set([2,4,7]))

# ╔═╡ 39485be5-31bd-431d-879c-e231ee40e181
test_covariate_adjustment(dag_pc.g, X, Y, Set([5,4]))

# ╔═╡ 9972b3be-122e-41a5-88d0-0599464418ae
find_dsep(dag_pc.g, X, Y) == Set([1,2,3,4,5,7])

# ╔═╡ fdc25ad0-6a83-4b55-b5b2-44016d0249cb
find_dsep(dag_pc.g, X, Y, Set{Int64}(), setdiff(Set(1:8), [4,6,8])) == false

# ╔═╡ 943281cd-c8f5-41d4-91fb-e38009353bfd
find_dsep(dag_pc.g, Set([1,6]), Set(2)) == false

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

# ╔═╡ 1791b7ad-088b-4847-a5dd-a457e951eacd
Set(list_covariate_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2]))) == Set([Set([3,4]), Set([4,5]), Set([3,4,5])])

# ╔═╡ ffef95e6-d73b-4da9-b155-d9468dd839e0
Set(list_backdoor_adjustment(dag_pc.g, Set([6]), Set([8]), Set(Int[]), setdiff(Set(1:8), [1,2]))) == Set([Set([3,4]), Set([4,5]), Set([3,4,5])])

# ╔═╡ 97cba8dc-49d8-4a9a-999d-f706ce231fa1
Set(list_frontdoor_adjustment(dag_pc.g, X, Y)) == Set([Set(7)])

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
# ╠═cf96a450-0680-456d-a178-afba6d3721ff
# ╠═5db66288-1193-4f1c-bb51-03f3be399786
# ╠═63586904-0755-46a2-9e69-5c796e30679c
# ╠═eeb7d08e-1921-4518-a9d3-5ac6a97591b7
# ╠═7f7a84ce-f246-4f79-9db2-1d4946fee186
# ╠═25b6bcca-4b77-4f5b-a5d4-cbe6a6e8b250
# ╠═bc3e4cae-ccaf-44b8-be58-1d90e7870350
# ╠═d844ca9f-4302-44e6-b4ac-7758b03c8e68
# ╠═74d9e42d-2556-4d68-9ecd-a6aa3644ec7b
# ╠═3c459abd-d64f-4bc6-99c7-fbc82eb3c280
# ╠═8c0fc0b3-5ff9-4943-be6a-05cf27208210
# ╠═e246455c-fa2c-4831-8774-3c52baa55ea8
# ╠═9c3fc9de-4822-4e98-9f17-a943dacb8d8c
# ╠═543103c9-46f3-4f0f-bea7-4e091d9d870d
# ╠═583229e3-352e-4091-9ffb-c8c35a791a50
# ╠═bd40b88b-9f08-41ad-a733-12fc5be3746c
# ╠═6385e966-1b57-4c34-b19a-539be73ae4a1
# ╠═520da0ac-0573-4e68-9b3d-9954eb6f5dbf
# ╠═bb44baa3-314c-47be-9d7b-a8734aa9e170
# ╠═fa214c43-3fb6-4cfd-8b34-f75e71d59bb2
# ╠═57eab6bd-3204-4479-bdf1-f61e12c9fec7
# ╠═fb13c83a-c004-42e3-882a-92dcc07c1058
# ╠═ee20a363-6ea2-41c8-95aa-3987efdbe890
# ╠═39485be5-31bd-431d-879c-e231ee40e181
# ╠═9972b3be-122e-41a5-88d0-0599464418ae
# ╠═fdc25ad0-6a83-4b55-b5b2-44016d0249cb
# ╠═943281cd-c8f5-41d4-91fb-e38009353bfd
# ╠═18c5e0cb-e586-4799-9468-8302453f8f03
# ╠═29493226-6af2-4c7f-8756-9e6eb38df3df
# ╠═8e1d73b4-b713-4251-aad0-aef968695b37
# ╠═5bd2a324-b9d1-4b9e-a186-0ef5088c8b37
# ╠═4124c101-0257-433e-9a26-91c09137e3b6
# ╠═d125d72b-389d-4c53-8584-dd85f705e566
# ╠═78522992-2faf-4072-8465-11ad5402c1d6
# ╠═bab94d9a-8231-44e4-a9ae-d6f6a19387da
# ╠═22658676-89da-4301-819f-7b1be9c5fe8f
# ╠═1791b7ad-088b-4847-a5dd-a457e951eacd
# ╠═ffef95e6-d73b-4da9-b155-d9468dd839e0
# ╠═97cba8dc-49d8-4a9a-999d-f706ce231fa1
