### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ a20974be-c658-11ec-3a53-a185aa9085cb
using Pkg

# ╔═╡ da347ede-475d-47f0-bd9a-47f7a74edb6f
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 3626cf55-ee2b-4363-95ee-75f2444a1542
begin
    using CairoMakie
	using RegressionAndOtherStories
end

# ╔═╡ 4a6f12f9-3b83-42b5-9fed-0296a5a603c6
md" ### 9.2-Metropolis algorithm"

# ╔═╡ 2409c72b-cbcc-467f-9e81-23d83d2b703a
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 3500px;
        padding-left: max(10px, 5%);
        padding-right: max(10px, 37%);
    }
</style>
"""

# ╔═╡ df8d2c37-f2a8-4fea-9a83-c7d37339f870
let
    Random.seed!(123)
    rad_dist(y) = √sum(y.^2)
    
    f = Figure()
    
    n = 10
    m = rand(MvNormal(zeros(n), Diagonal(ones(n))), Int(1e3))
    ax = Axis(f[1, 1]; title="First 20 points of lines", xlabel="Point", ylabel="Value")
    for i in 1:2
        lines!(m[i, 1:20])
    end

    colors = [:darkblue, :darkgreen, :grey, :darkred]
    # Or use KDE.jl to compute positions and heights!
    positions = [-0.1, 2, 8, 29]
    heights = [0.77, 0.59, 0.57, 0.59]
    
    ax = Axis(f[1, 2]; title="Density at radial distance",
		xlabel="Radial distance from mode", ylabel="Density")
    for (ind, n) in enumerate([1, 10, 100, 1000])
        m = rand(MvNormal(zeros(n), Diagonal(ones(n))), Int(1e3))
        rd = rad_dist.([m[:, i] for i in 1:1000])
        density!(rad_dist.(rd), color=colors[ind])
        annotations!("$n", position = (positions[ind], heights[ind]), fontsize=15)
    end
    annotations!("Dimensions: [1, 10, 100, 1000]", position = (3, 0.8), fontsize=15)
    f
end

# ╔═╡ Cell order:
# ╟─4a6f12f9-3b83-42b5-9fed-0296a5a603c6
# ╠═2409c72b-cbcc-467f-9e81-23d83d2b703a
# ╠═da347ede-475d-47f0-bd9a-47f7a74edb6f
# ╠═a20974be-c658-11ec-3a53-a185aa9085cb
# ╠═3626cf55-ee2b-4363-95ee-75f2444a1542
# ╠═df8d2c37-f2a8-4fea-9a83-c7d37339f870
