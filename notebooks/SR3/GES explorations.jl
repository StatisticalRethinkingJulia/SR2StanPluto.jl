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
md"## GES explorations."

# ╔═╡ bd8e4305-bb79-409b-9930-e11e579b8cd0
md"##### Set page layout for notebook."

# ╔═╡ da00c7fe-43ff-4e3a-ab43-0dfd9444f779
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 25%);
	}
</style>
"""

# ╔═╡ be65de6f-35f5-43e9-8004-30dd3f189456
let
	N = 2000 # number of data points

	# define simple linear model with added noise

	x = randn(N)
	v = x + randn(N)*0.25
	w = x + randn(N)*0.25
	z = v + w + randn(N)*0.25
	s = z + randn(N)*0.25
	global df = DataFrame(X=x, V=v, W=w, Z=z, S=s)
end

# ╔═╡ 782475cb-bd3c-469e-89a6-ed8058c770c4
dag_pc = create_pcalg_gauss_dag("pc", df, "Digraph PC {X->V; X->W; V->Z; W->Z; Z->S;}");

# ╔═╡ 3c459abd-d64f-4bc6-99c7-fbc82eb3c280
dag_fci = create_fci_dag("fci", df, "Digraph FCI {X->V; X->W; V->Z; W->Z; Z->S;}");

# ╔═╡ e38a7c67-696a-4a72-8a6b-7cd152cf0216
dag_ges = create_ges_dag("ges", df, "Digraph FCI {X->V; X->W; V->Z; W->Z; Z->S;}"; penalty=1.0);

# ╔═╡ d844ca9f-4302-44e6-b4ac-7758b03c8e68
gvplot(dag_pc)

# ╔═╡ 31f432a6-c439-4766-adb3-0c660397a76c
gvplot(dag_ges)

# ╔═╡ 8c0fc0b3-5ff9-4943-be6a-05cf27208210
gvplot(dag_fci)

# ╔═╡ 67b8af13-d3b0-4e92-be66-18b96d653ec1
dag_ges.score

# ╔═╡ 7fede47f-39d9-41e0-ae3b-b37e32331955
dag_ges.method

# ╔═╡ 6c3f3b01-99f4-4005-a022-f9678df6056a
dag_ges.elapsed

# ╔═╡ f2a1d903-0578-4caf-b1df-e670c7514744
dag_pc.est_g.fadjlist

# ╔═╡ ce129bb7-61ed-4d72-a05a-f1ef3b561464
dag_ges.est_g.fadjlist

# ╔═╡ Cell order:
# ╟─00d5774b-5ef0-4d01-b21d-1749beec466a
# ╟─bd8e4305-bb79-409b-9930-e11e579b8cd0
# ╠═da00c7fe-43ff-4e3a-ab43-0dfd9444f779
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╠═be65de6f-35f5-43e9-8004-30dd3f189456
# ╠═782475cb-bd3c-469e-89a6-ed8058c770c4
# ╠═3c459abd-d64f-4bc6-99c7-fbc82eb3c280
# ╠═e38a7c67-696a-4a72-8a6b-7cd152cf0216
# ╠═d844ca9f-4302-44e6-b4ac-7758b03c8e68
# ╠═31f432a6-c439-4766-adb3-0c660397a76c
# ╠═8c0fc0b3-5ff9-4943-be6a-05cf27208210
# ╠═67b8af13-d3b0-4e92-be66-18b96d653ec1
# ╠═7fede47f-39d9-41e0-ae3b-b37e32331955
# ╠═6c3f3b01-99f4-4005-a022-f9678df6056a
# ╠═f2a1d903-0578-4caf-b1df-e670c7514744
# ╠═ce129bb7-61ed-4d72-a05a-f1ef3b561464
