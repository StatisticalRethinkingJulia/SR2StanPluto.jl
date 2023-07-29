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
md"## GES."

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

# ╔═╡ e24c894d-5aad-4daa-9201-62c4d8bae898
let
	vars = Symbol.(names(df))
	nt = namedtuple(vars, [df[!, k] for k in vars])
	g = pcalg(nt, 0.25, gausscitest)
end

# ╔═╡ 782475cb-bd3c-469e-89a6-ed8058c770c4
dag_pc = create_pc_dag("pc", df, "Digraph PC {X->V; X->W; V->Z; W->Z; Z->S;}");

# ╔═╡ 3c459abd-d64f-4bc6-99c7-fbc82eb3c280
dag_fci = create_fci_dag("fci", df, "Digraph FCI {X->V; X->W; V->Z; W->Z; Z->S;}");

# ╔═╡ d844ca9f-4302-44e6-b4ac-7758b03c8e68
gvplot(dag_pc)

# ╔═╡ 8c0fc0b3-5ff9-4943-be6a-05cf27208210
gvplot(dag_fci)

# ╔═╡ 23a7409a-80da-471a-8032-7b6f0abb7766
est_g, score = ges(df; penalty=1.0, parallel=true)

# ╔═╡ c38348b9-ad76-4a9d-8909-38ce265dfc51
fieldnames(typeof(est_g))

# ╔═╡ f2a1d903-0578-4caf-b1df-e670c7514744
est_g.fadjlist

# ╔═╡ Cell order:
# ╠═00d5774b-5ef0-4d01-b21d-1749beec466a
# ╟─bd8e4305-bb79-409b-9930-e11e579b8cd0
# ╠═da00c7fe-43ff-4e3a-ab43-0dfd9444f779
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╠═be65de6f-35f5-43e9-8004-30dd3f189456
# ╠═e24c894d-5aad-4daa-9201-62c4d8bae898
# ╠═782475cb-bd3c-469e-89a6-ed8058c770c4
# ╠═3c459abd-d64f-4bc6-99c7-fbc82eb3c280
# ╠═d844ca9f-4302-44e6-b4ac-7758b03c8e68
# ╠═8c0fc0b3-5ff9-4943-be6a-05cf27208210
# ╠═23a7409a-80da-471a-8032-7b6f0abb7766
# ╠═c38348b9-ad76-4a9d-8909-38ce265dfc51
# ╠═f2a1d903-0578-4caf-b1df-e670c7514744
