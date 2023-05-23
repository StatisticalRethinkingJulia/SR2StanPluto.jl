### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 62c80a26-975a-11ed-2e09-2dce0e33bb70
using Pkg

# ╔═╡ aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 58ece6dd-a20f-4624-898a-40cae4b471e4
begin
	# General packages for this script
	using Test
	
	# Graphics related packages
	using CairoMakie
	using GraphViz

	# DAG support
	using CausalInference

	# Stan specific
	using StanSample

	# Project support functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ ad08dd09-222a-4071-92d4-38deebaf2e82
md" ### PC Algorithm: How it works"

# ╔═╡ e4552c81-d0db-4434-b81a-c86f1af515e5
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(10px, 5%);
    	padding-right: max(10px, 36%);
	}
</style>
"""

# ╔═╡ 261cca70-a6dd-4bed-b2f2-8667534d0ceb
let
	Random.seed!(13)
	N = 1000
	global p = 0.02
	x = rand(N)
	y = rand(N)
	z = x + y + rand(N) * 0.25
	w = z + rand(N) * 0.25

	global X = [x y z w]
	global df = DataFrame(x=x, y=y, z=z, w=w)
	global covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	df
end

# ╔═╡ 1d414e0f-af74-4130-8f7b-b08d259bc33f
covm

# ╔═╡ 09f4825a-34ed-4e39-9fd9-c6ddc0610e6c
g_dot_str="DiGraph d1 {x->z; y->z; z->w;}";

# ╔═╡ eff73cbb-a04c-46de-b3bf-1e164ebe411f
d1 = create_fci_dag("d1", df, g_dot_str);

# ╔═╡ f1302070-b876-4355-b434-9eb025dc1db2
gvplot(d1)

# ╔═╡ 71b95bc5-13f9-4278-bfc2-a3632b4c1552
d2 = create_pc_dag("d1", df, g_dot_str);

# ╔═╡ bfdb1885-15b9-4a6a-9bf4-30b0bb434b4c
gvplot(d2)

# ╔═╡ a6a8dd0a-44e9-4acf-987c-2d41b245ac6c
md" #### Illustration of how the PC algorithm works."

# ╔═╡ 080bf7df-6b9b-4e92-8122-06cb830f7010
md" ##### DAG `d2` is used (abused) to illustrate the PC algorithm."

# ╔═╡ 38443eb2-7a82-4f07-9a7b-7222233154db
md"""

Excerpt from "Review of Causal Discovery".

[Clark Glymour, Kun Zhang* and Peter Spirtes](https://www.frontiersin.org/articles/10.3389/fgene.2019.00524/full)

This material may be protected by copyright.

1. Form a complete undirected graph, as in Figure B.
"""

# ╔═╡ 9f44ad38-b85f-4aeb-975c-610b0f30c133
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure B: Fully connected,\nundirected graph")

# ╔═╡ 5b009a6c-770c-48d7-97ed-4e5449381312
md"
2. Eliminate edges between variables that are unconditionally independent; in this case that is the :x − :y edge, giving the graph in Figure C.
"

# ╔═╡ a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
dsep(d1, :x, :y)

# ╔═╡ 181f069d-7820-4867-afb7-4dd7cc0b70a5
d2.est_g_dot_str="DiGraph dag_1 {x->z [color=blue, arrowhead=none]; x->w [color=blue, arrowhead=none]; y->z [color=blue, arrowhead=none]; y->w [color=blue, arrowhead=none]; z->w [color=blue, arrowhead=none];}"

# ╔═╡ 7c037a74-11d4-4366-b6e2-c8185ca73464
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure C: :x and :y are independent")

# ╔═╡ 1fdae2d6-ac23-4db3-8fc6-5649cccf1ba0
md"""
3. For each pair of variables (A, B) having an edge between them, and for each variable C with an edge connected to either of them, eliminate the edge between A and B if A  B | C as in Figure 1D.
4. For each pair of variables A, B having an edge between them, and for each pair of variables {C, D} with edges both connected to A or both connected to B, eliminate the edge between A and B if A  B | {C, D}.
"""

# ╔═╡ 00ad74d9-62d8-4ced-8bf1-eace47470272
dsep(d1, :x, :w, verbose=true)

# ╔═╡ 5533711c-6cbb-4407-8081-1ab44a09a8b9
dsep(d1, :x, :w, [:z], verbose=true)

# ╔═╡ 6d999053-3612-4e8d-b2f2-2ddf3eae5630
dsep(d1, :y, :w, [:z], verbose=true)

# ╔═╡ 486def96-57dc-4ad7-ae26-b8ba99f02037
d2.est_g_dot_str="DiGraph dag_1 {x->z [color=red, arrowhead=none]; y->z [color=red, arrowhead=none]; z->w [color=red, arrowhead=none];}"

# ╔═╡ abf035da-9544-4c67-8475-0d1bd8d2989d
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure D: Remove :x - :w and :y - :w")

# ╔═╡ 6e783dc5-49d2-4759-a5f0-4e1f44f178a9
md"""
5. For each triple of variables (A, B, C) such that A and B are adjacent, B and C are adjacent, and A and C are not adjacent, orient the edges A − B − C as A → B ← C, if B was not in the set conditioning on which A and C became independent and the edge between them was accordingly eliminated. We call such a triple of variables a v-structure.
"""

# ╔═╡ 728c0de8-c99b-411e-a419-271f5404a252
d2.est_g_dot_str="DiGraph dag_1 {x->z ; y->z; z->w [color=red, arrowhead=none];}"

# ╔═╡ 8a631946-6e92-4a60-a896-c8d41b77f59a
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure E: Apply v-structure rule")

# ╔═╡ 40551853-22ba-4d58-afdc-249b7685321f
md"""
6. For each triple of variables such that A → B−C, and A and C are not adjacent, orient the edge B−C as B → C. This is called orientation propagation.
"""

# ╔═╡ 8cfe323f-e48f-4705-be8a-cbb3669498d9
d2.est_g_dot_str="DiGraph dag_1 {x->z; y->z; z->w;}"

# ╔═╡ 5f5f504d-0209-439b-b076-616924ce93d7
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure F: Apply orientation propagation\non link :z - :w")

# ╔═╡ 8b8404ca-4bc7-4006-a456-aade8e12c0b4
md"""
7. Not all possible rules have been illustrated here!.

See also the references and examples in [CausalInference.jl](https://mschauer.github.io/CausalInference.jl/latest/).
"""

# ╔═╡ 53022a21-f9de-4ae4-8e87-1a2e88c0ebef
g_oracle = fcialg(4, dseporacle, d1.g)

# ╔═╡ 490f0730-c8b7-49f9-a48c-fd3929f4ae78
g_gauss = fcialg(df, 0.05, gausscitest)

# ╔═╡ 9b5fabdd-f36c-49b1-8409-88643f273647
let
    fci_oracle_dot_str = to_gv(g_oracle, d1.vars)
    fci_gauss_dot_str = to_gv(g_gauss, d1.vars)
    g1 = GraphViz.Graph(d1.g_dot_str)
    g2 = GraphViz.Graph(d1.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

# ╔═╡ Cell order:
# ╟─ad08dd09-222a-4071-92d4-38deebaf2e82
# ╠═e4552c81-d0db-4434-b81a-c86f1af515e5
# ╠═62c80a26-975a-11ed-2e09-2dce0e33bb70
# ╠═aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
# ╠═58ece6dd-a20f-4624-898a-40cae4b471e4
# ╠═261cca70-a6dd-4bed-b2f2-8667534d0ceb
# ╠═1d414e0f-af74-4130-8f7b-b08d259bc33f
# ╠═09f4825a-34ed-4e39-9fd9-c6ddc0610e6c
# ╠═eff73cbb-a04c-46de-b3bf-1e164ebe411f
# ╠═f1302070-b876-4355-b434-9eb025dc1db2
# ╠═71b95bc5-13f9-4278-bfc2-a3632b4c1552
# ╠═bfdb1885-15b9-4a6a-9bf4-30b0bb434b4c
# ╟─a6a8dd0a-44e9-4acf-987c-2d41b245ac6c
# ╟─080bf7df-6b9b-4e92-8122-06cb830f7010
# ╟─38443eb2-7a82-4f07-9a7b-7222233154db
# ╠═9f44ad38-b85f-4aeb-975c-610b0f30c133
# ╟─5b009a6c-770c-48d7-97ed-4e5449381312
# ╠═a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
# ╠═181f069d-7820-4867-afb7-4dd7cc0b70a5
# ╠═7c037a74-11d4-4366-b6e2-c8185ca73464
# ╟─1fdae2d6-ac23-4db3-8fc6-5649cccf1ba0
# ╠═00ad74d9-62d8-4ced-8bf1-eace47470272
# ╠═5533711c-6cbb-4407-8081-1ab44a09a8b9
# ╠═6d999053-3612-4e8d-b2f2-2ddf3eae5630
# ╠═486def96-57dc-4ad7-ae26-b8ba99f02037
# ╠═abf035da-9544-4c67-8475-0d1bd8d2989d
# ╟─6e783dc5-49d2-4759-a5f0-4e1f44f178a9
# ╠═728c0de8-c99b-411e-a419-271f5404a252
# ╠═8a631946-6e92-4a60-a896-c8d41b77f59a
# ╟─40551853-22ba-4d58-afdc-249b7685321f
# ╠═8cfe323f-e48f-4705-be8a-cbb3669498d9
# ╠═5f5f504d-0209-439b-b076-616924ce93d7
# ╟─8b8404ca-4bc7-4006-a456-aade8e12c0b4
# ╠═53022a21-f9de-4ae4-8e87-1a2e88c0ebef
# ╠═490f0730-c8b7-49f9-a48c-fd3929f4ae78
# ╠═9b5fabdd-f36c-49b1-8409-88643f273647
