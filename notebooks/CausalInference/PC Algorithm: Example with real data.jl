### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 7d47667f-b0ea-43a1-8a20-6b2d512119eb
using Pkg

# ╔═╡ 374cd6e5-1179-4edd-bf4d-917bb288582a
begin
	using HTTP, CSV, DataFrames
	using CausalInference
	using CairoMakie
	using GraphViz
	using StanSample
	using RegressionAndOtherStories
end

# ╔═╡ 94e13475-839a-4034-b7ce-5562eef89b97
md" ### PC Algorithm: Example with real data"

# ╔═╡ 19e075c6-4f62-4d31-be28-142dc7300060
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 5%);
    	padding-right: max(5px, 5%);
	}
</style>
"""


# ╔═╡ 8f5be6ca-2178-4b18-9ad5-eb254a32d189
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ e67600f8-9038-4ae0-b5e6-a9bc3733d1c0
url = "https://www.ccd.pitt.edu/wp-content/uploads/files/Retention.txt";

# ╔═╡ 68acd782-c4ae-4c84-ab78-a2dcdbf84898
begin
	dfi = DataFrame(CSV.File(HTTP.get(url).body))
	dfi[1:3, :]
end

# ╔═╡ 8a705939-bb5c-4ddf-990d-f2cc251216f1
begin
	df = DataFrame(ss=dfi[:, 1], gr=dfi[:, 2], scs=dfi[:, 3], rr=dfi[:, 4], ts=dfi[:, 5],
		sar=dfi[:, 6], str=dfi[:, 7], fs=dfi[:, 8])
	df[1:3, :]
end

# ╔═╡ d21e246a-c503-11ed-357e-eb369f06d0bf
begin
	vars = names(df)
	tups = [(1, 3), (3, 6), (2, 5), (5, 8), (6, 7), (7, 8), (1, 4), (2, 4), (4, 6), (4, 8)]
	
	d1_str = "DiGraph d1 {"
	for t in tups
		d1_str = d1_str * "$(vars[t[1]])->$(vars[t[2]]);"
	end
	d1_str = d1_str * "}"
end 

# ╔═╡ f39b4739-7b63-43dc-bc2b-b65a173be1d5
d1 = create_dag("d1", df; g_dot_str=d1_str);

# ╔═╡ bb626a9b-4d1c-44d1-8c6a-6581bca4e28e
names(df)

# ╔═╡ 6f457c4f-dbc5-4ac3-89d0-2a9c4c912fe4
gvplot(d1)

# ╔═╡ 778b51fd-7b62-4111-98e6-c71793e7258d
g = pcalg(df, 0.25, gausscitest)

# ╔═╡ 9911fe47-b61c-4ffc-a5d3-caa09d201911
g_oracle = fcialg(8, dseporacle, d1.g)

# ╔═╡ 0ee6e245-1afe-48c2-b3ca-09e27bb98118
g_gauss = fcialg(df, 0.05, gausscitest)

# ╔═╡ 25abc967-483c-4716-836d-9a3dae7e13a1
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
# ╟─94e13475-839a-4034-b7ce-5562eef89b97
# ╠═19e075c6-4f62-4d31-be28-142dc7300060
# ╠═7d47667f-b0ea-43a1-8a20-6b2d512119eb
# ╠═8f5be6ca-2178-4b18-9ad5-eb254a32d189
# ╠═374cd6e5-1179-4edd-bf4d-917bb288582a
# ╠═e67600f8-9038-4ae0-b5e6-a9bc3733d1c0
# ╠═68acd782-c4ae-4c84-ab78-a2dcdbf84898
# ╠═8a705939-bb5c-4ddf-990d-f2cc251216f1
# ╠═d21e246a-c503-11ed-357e-eb369f06d0bf
# ╠═f39b4739-7b63-43dc-bc2b-b65a173be1d5
# ╠═bb626a9b-4d1c-44d1-8c6a-6581bca4e28e
# ╠═6f457c4f-dbc5-4ac3-89d0-2a9c4c912fe4
# ╠═778b51fd-7b62-4111-98e6-c71793e7258d
# ╠═9911fe47-b61c-4ffc-a5d3-caa09d201911
# ╠═0ee6e245-1afe-48c2-b3ca-09e27bb98118
# ╠═25abc967-483c-4716-836d-9a3dae7e13a1
