### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 62c80a26-975a-11ed-2e09-2dce0e33bb70
using Pkg

# ╔═╡ 58ece6dd-a20f-4624-898a-40cae4b471e4
begin
	# General packages for this script
	using Test
	
	# Graphics related packages
	using GLMakie
	using GraphMakie
	using Graphs

	# DAG support
	using CausalInference
	using StructuralCausalModels

	# Stan specific
	using StanSample

	# Project support functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 14b9e2fc-b61c-4e4a-bed0-766fa4916194
using GraphMakie.NetworkLayout

# ╔═╡ e4552c81-d0db-4434-b81a-c86f1af515e5
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 30%);
	}
</style>
"""

# ╔═╡ 3f7d7f07-1e9a-4721-b3b0-a066409bd5b5
letters = ('A':'Z')

# ╔═╡ d872845c-0c3e-451d-b706-9ff4cec439d9
numbers = (1:26)

# ╔═╡ b5bfe191-d62c-4fb4-9b13-c81b0d2cd14e
let
	global f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="DiGraph(7)")
	
	global g1 = DiGraph(7)
	
	colors = [:black for i in 1:nv(g1)]
	colors[2] = :red
	
	for (i, j) in [(1, 2), (2, 3), (2, 4), (4, 5), (3, 5), (5, 6), (7, 5)]
		add_edge!(g1, i, j)
	end
	
	arrow_size = [20+i for i in 1:ne(g1)]
	arrow_shift = range(0.1, 0.8, length=ne(g1))

	p = graphplot!(g1;
		#layout=Shell(),
		node_color=:blue,
		edge_color=:grey,
		nlabels=repr.(numbers[1:nv(g1)]),
		nlabels_colors=colors,
		arrow_size=arrow_size)
	offsets = [Point2f(0.2, -0.125) for i in 1:nv(g1)]
	p.nlabels_offset[] = offsets
	autolimits!(ax)

	hidedecorations!(ax)
	hidespines!(ax)
	ax.aspect = DataAspect()
	f
end

# ╔═╡ c4730f9a-3a94-4031-a264-fe5c847f5986


# ╔═╡ e32ab50e-c126-4446-b3cf-a69f2f332693
f

# ╔═╡ a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
dsep(g1, 1, 2, [], verbose=true)

# ╔═╡ 00ad74d9-62d8-4ced-8bf1-eace47470272
dsep(g1, 1, 5, [3], verbose=true)

# ╔═╡ 5533711c-6cbb-4407-8081-1ab44a09a8b9
dsep(g1, 1, 5, [4], verbose=true)

# ╔═╡ 6d999053-3612-4e8d-b2f2-2ddf3eae5630
dsep(g1, 1, 5, [3, 4], verbose=true)

# ╔═╡ 261cca70-a6dd-4bed-b2f2-8667534d0ceb
let
	Random.seed!(123)
	N = 1000
	global p = 0.01
	x = rand(N)
	v = x + rand(N) * 0.25
	w = x + rand(N) * 0.25
	z = v + w + rand(N) * 0.25
	s = z + rand(N) * 0.25

	global X = [x v w z s]
	global df = DataFrame(x=x, v=v, w=w, z=z, s=s)
end

# ╔═╡ 6d78ef06-037f-450a-ac96-26dc22e73af2
cov(X)

# ╔═╡ d94d4717-7ca8-4db9-ae54-fc481aa63c3c
@time est_g = pcalg(df, p, gausscitest)

# ╔═╡ 6996310f-921d-4158-b9d0-addf9472e268
est_g

# ╔═╡ bd4dde3e-797d-43e5-9853-7606828f6b58
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="DiGraph(7)")
	
	colors = [:black for i in 1:nv(est_g)]
	colors[2] = :red
		
	arrow_size = [20+i for i in 1:ne(est_g)]
	arrow_shift = range(0.1, 0.8, length=ne(est_g))

	p = graphplot!(est_g;
		#layout=Shell(),
		node_color=:blue,
		edge_color=:grey,
		nlabels=repr.(numbers[1:nv(est_g)]),
		nlabels_colors=colors,
		arrow_size=arrow_size)
	offsets = [Point2f(0.2, -0.125) for i in 1:nv(est_g)]
	p.nlabels_offset[] = offsets
	autolimits!(ax)

	hidedecorations!(ax)
	hidespines!(ax)
	ax.aspect = DataAspect()
	f
end

# ╔═╡ a7ef9b7a-b825-41ee-836b-7a09456abf54
let
	g = DiGraph(5)
	d = nv(g)
	for (i, j) in [(1, 2), (1, 3), (2, 4), (3, 4), (4, 5)]
		add_edge!(g, i, j)
	end

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="DiGraph(7)")
	
	colors = [:black for i in 1:nv(g)]
	colors[2] = :red
		
	arrow_size = [20+i for i in 1:ne(g)]
	arrow_shift = range(0.1, 0.8, length=ne(g))

	p = graphplot!(g;
		#layout=Shell(),
		node_color=:blue,
		edge_color=:grey,
		nlabels=repr.(numbers[1:nv(g)]),
		nlabels_colors=colors,
		arrow_size=arrow_size)
	offsets = [Point2f(0.2, -0.125) for i in 1:nv(g)]
	p.nlabels_offset[] = offsets
	autolimits!(ax)

	hidedecorations!(ax)
	hidespines!(ax)
	ax.aspect = DataAspect()
	f
end

# ╔═╡ 64dca3ba-0ebc-42d6-924e-2375620a3917
let
	g = DiGraph(5)
	d = nv(g)
	for (i, j) in [(1, 2), (1, 3), (2, 4), (3, 4), (4, 5)]
		add_edge!(g, i, j)
	end
	
	global dg = pcalg(d, dseporacle, g)
	
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="DiGraph(7)")
	
	colors = [:black for i in 1:nv(dg)]
	colors[2] = :red
		
	arrow_size = [20+i for i in 1:ne(dg)]
	arrow_shift = range(0.1, 0.8, length=ne(dg))

	p = graphplot!(dg;
		#layout=Shell(),
		node_color=:blue,
		edge_color=:grey,
		nlabels=repr.(numbers[1:nv(dg)]),
		nlabels_colors=colors,
		arrow_size=arrow_size)
	offsets = [Point2f(0.2, -0.125) for i in 1:nv(dg)]
	p.nlabels_offset[] = offsets
	autolimits!(ax)

	hidedecorations!(ax)
	hidespines!(ax)
	ax.aspect = DataAspect()
	f
end

# ╔═╡ d3272957-6548-4a90-bfdc-1df302f07ddb
@test collect(Graphs.edges(est_g)) == collect(Graphs.edges(dg))

# ╔═╡ Cell order:
# ╠═e4552c81-d0db-4434-b81a-c86f1af515e5
# ╠═62c80a26-975a-11ed-2e09-2dce0e33bb70
# ╠═58ece6dd-a20f-4624-898a-40cae4b471e4
# ╠═14b9e2fc-b61c-4e4a-bed0-766fa4916194
# ╠═3f7d7f07-1e9a-4721-b3b0-a066409bd5b5
# ╠═d872845c-0c3e-451d-b706-9ff4cec439d9
# ╠═b5bfe191-d62c-4fb4-9b13-c81b0d2cd14e
# ╠═c4730f9a-3a94-4031-a264-fe5c847f5986
# ╠═e32ab50e-c126-4446-b3cf-a69f2f332693
# ╠═a0cc8175-4f83-45f8-8bba-3e0679ff4ccb
# ╠═00ad74d9-62d8-4ced-8bf1-eace47470272
# ╠═5533711c-6cbb-4407-8081-1ab44a09a8b9
# ╠═6d999053-3612-4e8d-b2f2-2ddf3eae5630
# ╠═261cca70-a6dd-4bed-b2f2-8667534d0ceb
# ╠═6d78ef06-037f-450a-ac96-26dc22e73af2
# ╠═d94d4717-7ca8-4db9-ae54-fc481aa63c3c
# ╠═6996310f-921d-4158-b9d0-addf9472e268
# ╠═bd4dde3e-797d-43e5-9853-7606828f6b58
# ╠═a7ef9b7a-b825-41ee-836b-7a09456abf54
# ╠═64dca3ba-0ebc-42d6-924e-2375620a3917
# ╠═d3272957-6548-4a90-bfdc-1df302f07ddb
