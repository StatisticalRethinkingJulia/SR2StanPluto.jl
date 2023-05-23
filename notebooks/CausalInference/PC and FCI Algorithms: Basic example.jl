### A Pluto.jl notebook ###
# v0.19.26

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

	# DAG support
	using CausalInference
	using GraphViz

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
dag_fci = create_fci_dag("dag_fci", df, g_dot_str);

# ╔═╡ ac3c7049-051c-49a8-b46b-454995fe5b7b
gvplot(dag_fci)

# ╔═╡ 55f9ca6b-1196-4b0f-928f-42c640d09477
dag_pc = create_pc_dag("dag_pc", df, g_dot_str);

# ╔═╡ 4acdd821-3172-43a1-9f71-f862e74bea38
gvplot(dag_pc)

# ╔═╡ e01a8212-3d90-4285-b071-d043c913782f
dsep(dag_fci, :x, :v)

# ╔═╡ c6d93947-4655-450f-a6b0-b637a37764f3
dsep(dag_fci, :x, :s, [:w], verbose=true)

# ╔═╡ e60b3379-3fb1-424c-9ffd-947ea8333712
dsep(dag_fci, :x, :s, [:z], verbose=true)

# ╔═╡ d98067c4-ff47-4676-9b83-a339be736103
dsep(dag_fci, :x, :z, [:v, :w], verbose=true)

# ╔═╡ 45402fba-dd05-43c8-8fa2-088ca050e455
dsep(dag_pc, :x, :z, [:v, :w], verbose=true)

# ╔═╡ 5d0f0049-4809-481b-a0b6-457e72e81959
md" ##### By default, use g graph."

# ╔═╡ 0280fa92-1ec8-45dd-b22c-89c1fb6ea29c
backdoor_criterion(dag_fci, :x, :v)

# ╔═╡ 3abe1405-2f5b-4db3-b106-6805ede186fc
all_paths(dag_fci, :x, :v)

# ╔═╡ 372828ee-fecb-45fa-b444-b877ccda9df1
backdoor_criterion(dag_fci, :x, :w)

# ╔═╡ 858f7dbb-50c2-413c-bfca-f8094e447634
backdoor_criterion(dag_fci, dag_fci.g, :x, :w)

# ╔═╡ 2e9be9c4-53eb-4938-aa8f-f9cc00f32a41
backdoor_criterion(dag_pc, :x, :v)

# ╔═╡ Cell order:
# ╟─8ed92287-2740-42bf-a13a-591390210e44
# ╠═8be11140-9ffe-4f2f-abc0-494428a2c67a
# ╠═9b058084-14fb-4e0a-b24a-006168f838e9
# ╠═9b769ccb-efef-4b8a-8cc9-4a197d2117ba
# ╠═9e6eb992-d70d-4f51-812a-9e5ccebda718
# ╠═be720ef1-1cde-47b6-b50e-4f74ad377de0
# ╠═90ae6de7-b88e-4560-84ce-cb1cb07ec0fb
# ╠═383f93fd-6aeb-4e1a-962c-e48a93879d53
# ╠═ac3c7049-051c-49a8-b46b-454995fe5b7b
# ╠═55f9ca6b-1196-4b0f-928f-42c640d09477
# ╠═4acdd821-3172-43a1-9f71-f862e74bea38
# ╠═e01a8212-3d90-4285-b071-d043c913782f
# ╠═c6d93947-4655-450f-a6b0-b637a37764f3
# ╠═e60b3379-3fb1-424c-9ffd-947ea8333712
# ╠═d98067c4-ff47-4676-9b83-a339be736103
# ╠═45402fba-dd05-43c8-8fa2-088ca050e455
# ╟─5d0f0049-4809-481b-a0b6-457e72e81959
# ╠═0280fa92-1ec8-45dd-b22c-89c1fb6ea29c
# ╠═3abe1405-2f5b-4db3-b106-6805ede186fc
# ╠═372828ee-fecb-45fa-b444-b877ccda9df1
# ╠═858f7dbb-50c2-413c-bfca-f8094e447634
# ╠═2e9be9c4-53eb-4938-aa8f-f9cc00f32a41
