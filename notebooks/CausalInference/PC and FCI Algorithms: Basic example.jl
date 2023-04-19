### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 9b058084-14fb-4e0a-b24a-006168f838e9
using Pkg

# ╔═╡ 9b769ccb-efef-4b8a-8cc9-4a197d2117ba
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 9e6eb992-d70d-4f51-812a-9e5ccebda718
begin
	# Graphics related packages
	using CairoMakie
	using GraphViz
	using Graphs
	using MetaGraphs

	# DAG support
	using CausalInference

	# Stan specific
	using StanSample

	# Project support functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 8ed92287-2740-42bf-a13a-591390210e44
md" ### PC and FCI algorithms: Basic example"

# ╔═╡ 8be11140-9ffe-4f2f-abc0-494428a2c67a
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

# ╔═╡ be720ef1-1cde-47b6-b50e-4f74ad377de0
let
	Random.seed!(1)
	N = 1000
	global p = 0.01
	x = rand(N)
	v = x + rand(N) * 0.25
	w = x + rand(N) * 0.25
	z = v + w + rand(N) * 0.25
	s = z + rand(N) * 0.25

	global X = [x v w z s]
	global df = DataFrame(x=x, v=v, w=w, z=z, s=s)
	global covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	df
end

# ╔═╡ 90ae6de7-b88e-4560-84ce-cb1cb07ec0fb
g_dot_str="DiGraph dag_1 {x->v; v->z; x->w; w->z; z->s;}";

# ╔═╡ 383f93fd-6aeb-4e1a-962c-e48a93879d53
dag_1 = create_dag("dag_1", df; g_dot_str);

# ╔═╡ 55f9ca6b-1196-4b0f-928f-42c640d09477
g = pcalg(df, 0.25, gausscitest)

# ╔═╡ 24160907-515c-4b66-bcdd-7cf6ef4427d1
g_oracle = fcialg(5, dseporacle, dag_1.g)

# ╔═╡ e5841b24-2f45-446f-a271-2fb7ecca7f7f
g_gauss = fcialg(dag_1.df, 0.05, gausscitest)

# ╔═╡ 40fa896a-1a8e-4c23-bc73-eb6067aa1f2f
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


# ╔═╡ cdd1ec94-324e-46e5-8b8a-5579a1ba3375
@time est_g_2 = pcalg(df, p, cmitest)

# ╔═╡ e01a8212-3d90-4285-b071-d043c913782f
dsep(dag_1, :x, :v)

# ╔═╡ c6d93947-4655-450f-a6b0-b637a37764f3
dsep(dag_1, :x, :s, [:w], verbose=true)

# ╔═╡ e60b3379-3fb1-424c-9ffd-947ea8333712
dsep(dag_1, :x, :s, [:z], verbose=true)

# ╔═╡ d98067c4-ff47-4676-9b83-a339be736103
dsep(dag_1, :x, :z, [:v, :w], verbose=true)

# ╔═╡ f284dcae-8d63-4345-9029-2dd16143742e
@time dag_2 = create_dag("dag_2", df, 0.025; g_dot_str, est_func=cmitest);

# ╔═╡ d9324794-cc16-430c-b252-da148070b177
gvplot(dag_2)

# ╔═╡ 45402fba-dd05-43c8-8fa2-088ca050e455
dsep(dag_2, est_g_2, :x, :z, [:v, :w], verbose=true)

# ╔═╡ 5d0f0049-4809-481b-a0b6-457e72e81959
md" ##### By default, use g graph."

# ╔═╡ 0280fa92-1ec8-45dd-b22c-89c1fb6ea29c
backdoor_criterion(dag_1, :x, :v)

# ╔═╡ 372828ee-fecb-45fa-b444-b877ccda9df1
backdoor_criterion(dag_1, :x, :w)

# ╔═╡ 858f7dbb-50c2-413c-bfca-f8094e447634
backdoor_criterion(dag_1, dag_1.g, :x, :w)

# ╔═╡ 63323b41-7660-4157-b1e4-5767a08300ca
md" ##### Or select the est_g graph."

# ╔═╡ 349475a7-f0b1-4e2f-bb46-fc24477fe6fa
backdoor_criterion(dag_1, dag_1.est_g, :x, :w)

# ╔═╡ f8b74d86-d86c-48b7-b267-1bc2faefcc24
md" ##### Use a DAG to use node labels instead of numbers."

# ╔═╡ 786ceba6-ebc8-4cf6-9192-8afb959fefa3
backdoor_criterion(dag_1, g_oracle, :x, :v)

# ╔═╡ 2e9be9c4-53eb-4938-aa8f-f9cc00f32a41
backdoor_criterion(dag_1, g_gauss, :x, :v)

# ╔═╡ f20f6860-5def-4f1a-a1b9-a459342c9de2
dsep(dag_1, g_oracle, :x, :z, [:v, :w], verbose=true)

# ╔═╡ 03fe639a-eb97-4a37-86d7-68d3ec18de5b
dsep(dag_1, dag_1.g, :x, :z, [:v, :w], verbose=true)

# ╔═╡ Cell order:
# ╟─8ed92287-2740-42bf-a13a-591390210e44
# ╠═8be11140-9ffe-4f2f-abc0-494428a2c67a
# ╠═9b058084-14fb-4e0a-b24a-006168f838e9
# ╠═9b769ccb-efef-4b8a-8cc9-4a197d2117ba
# ╠═9e6eb992-d70d-4f51-812a-9e5ccebda718
# ╠═be720ef1-1cde-47b6-b50e-4f74ad377de0
# ╠═90ae6de7-b88e-4560-84ce-cb1cb07ec0fb
# ╠═383f93fd-6aeb-4e1a-962c-e48a93879d53
# ╠═55f9ca6b-1196-4b0f-928f-42c640d09477
# ╠═24160907-515c-4b66-bcdd-7cf6ef4427d1
# ╠═e5841b24-2f45-446f-a271-2fb7ecca7f7f
# ╠═40fa896a-1a8e-4c23-bc73-eb6067aa1f2f
# ╠═cdd1ec94-324e-46e5-8b8a-5579a1ba3375
# ╠═d9324794-cc16-430c-b252-da148070b177
# ╠═e01a8212-3d90-4285-b071-d043c913782f
# ╠═c6d93947-4655-450f-a6b0-b637a37764f3
# ╠═e60b3379-3fb1-424c-9ffd-947ea8333712
# ╠═d98067c4-ff47-4676-9b83-a339be736103
# ╠═f284dcae-8d63-4345-9029-2dd16143742e
# ╠═45402fba-dd05-43c8-8fa2-088ca050e455
# ╟─5d0f0049-4809-481b-a0b6-457e72e81959
# ╠═0280fa92-1ec8-45dd-b22c-89c1fb6ea29c
# ╠═372828ee-fecb-45fa-b444-b877ccda9df1
# ╠═858f7dbb-50c2-413c-bfca-f8094e447634
# ╟─63323b41-7660-4157-b1e4-5767a08300ca
# ╠═349475a7-f0b1-4e2f-bb46-fc24477fe6fa
# ╟─f8b74d86-d86c-48b7-b267-1bc2faefcc24
# ╠═786ceba6-ebc8-4cf6-9192-8afb959fefa3
# ╠═2e9be9c4-53eb-4938-aa8f-f9cc00f32a41
# ╠═f20f6860-5def-4f1a-a1b9-a459342c9de2
# ╠═03fe639a-eb97-4a37-86d7-68d3ec18de5b
