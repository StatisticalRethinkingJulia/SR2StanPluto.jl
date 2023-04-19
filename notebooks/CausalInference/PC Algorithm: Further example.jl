### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 62c80a26-975a-11ed-2e09-2dce0e33bb70
using Pkg

# ╔═╡ 58ece6dd-a20f-4624-898a-40cae4b471e4
begin
	# General packages for this script
	using Test
	
	# Graphics related packages
	using CairoMakie
	using GraphViz
	using Graphs

	# DAG support
	using CausalInference

	# Stan specific
	using StanSample

	# Project support functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ ad08dd09-222a-4071-92d4-38deebaf2e82
md" ### PC Algorithm: Further example"

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

# ╔═╡ aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 261cca70-a6dd-4bed-b2f2-8667534d0ceb
let
	Random.seed!(1)
	N = 1000
	x = rand(Uniform(0,2π), N)
	v = sin.(x) + randn(N)*0.25
	w = cos.(x) + randn(N)*0.25
	z = 3 * v.^2 - w + randn(N)*0.25 
	s = z.^2 + randn(N)*0.25

	global X = [x v w z s]
	global df = DataFrame(x=x, v=v, w=w, z=z, s=s)
	global covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	df
end

# ╔═╡ 0ef59054-afd5-443b-a1c9-914798c98017
g_dot_str="DiGraph dag_1 {x->v; v->z; x->w; w->z; z->s;}";

# ╔═╡ 6bbfe4cb-f7e1-4503-a386-092882a1a49c
@time dag_1 = create_dag("dag_1", df; g_dot_str);

# ╔═╡ 5b3cb27a-cc3a-4932-999e-334ca801f54c
dag_1.est_g_dot_str

# ╔═╡ 728aa5ff-d581-43f7-bacf-c04787480bb7
gvplot(dag_1)

# ╔═╡ a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
dsep(dag_1, :x, :v)

# ╔═╡ 00ad74d9-62d8-4ced-8bf1-eace47470272
dsep(dag_1, :x, :s, [:w], verbose=true)

# ╔═╡ 5533711c-6cbb-4407-8081-1ab44a09a8b9
dsep(dag_1, :x, :s, [:z], verbose=true)

# ╔═╡ 6d999053-3612-4e8d-b2f2-2ddf3eae5630
dsep(dag_1, :x, :z, [:v, :w], verbose=true)

# ╔═╡ 4b75351b-c1d9-47b7-97c1-49eb90ea5fb1
@time dag_2 = create_dag("dag_2", df, 0.025; g_dot_str, est_func=cmitest);

# ╔═╡ 66fae38a-f622-444f-bfce-2c52d336bfdb
gvplot(dag_2)

# ╔═╡ cebdd43f-cf43-4de3-8bf1-02c49641af1e
g_oracle = fcialg(5, dseporacle, dag_1.g)

# ╔═╡ 059b9b71-31e2-43a9-b9aa-6136709640a3
g_gauss = fcialg(dag_1.df, 0.05, gausscitest)

# ╔═╡ 61caf151-016d-41f8-8fc7-3bf7d414c89c
let
    fci_oracle_dot_str = to_gv(g_oracle, dag_1.vars)
    fci_gauss_dot_str = to_gv(g_gauss, dag_1.vars)
    g1 = GraphViz.Graph(dag_1.g_dot_str)
    g2 = GraphViz.Graph(dag_1.est_g_dot_str)
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
# ╠═0ef59054-afd5-443b-a1c9-914798c98017
# ╠═6bbfe4cb-f7e1-4503-a386-092882a1a49c
# ╠═5b3cb27a-cc3a-4932-999e-334ca801f54c
# ╠═728aa5ff-d581-43f7-bacf-c04787480bb7
# ╠═a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
# ╠═00ad74d9-62d8-4ced-8bf1-eace47470272
# ╠═5533711c-6cbb-4407-8081-1ab44a09a8b9
# ╠═6d999053-3612-4e8d-b2f2-2ddf3eae5630
# ╠═4b75351b-c1d9-47b7-97c1-49eb90ea5fb1
# ╠═66fae38a-f622-444f-bfce-2c52d336bfdb
# ╠═cebdd43f-cf43-4de3-8bf1-02c49641af1e
# ╠═059b9b71-31e2-43a9-b9aa-6136709640a3
# ╠═61caf151-016d-41f8-8fc7-3bf7d414c89c
