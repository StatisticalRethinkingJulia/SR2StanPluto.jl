### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 6a0e1509-a003-4b92-a244-f96a9dd7dd3e
using Pkg

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
	# General packages
    using Distributions
    using CSV
    using DataFrames

	# Graphics
	using GLMakie
    
	# Project support functions
	using RegressionAndOtherStories
end

# ╔═╡ c77d49eb-cbd9-4c2b-88cf-339b31f3cddb
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 30%);
	}
</style>
"""

# ╔═╡ d703cce4-da8d-4391-8fc3-f3373c0a4643
md"#### 4.1 Why normal distributions are normal."

# ╔═╡ ca213187-aedf-49b7-9393-607bf6a4f08e
md"### Julia code snippet 4.1"

# ╔═╡ 497d10d9-2553-4d04-b79a-f5281c500bb6
md"#### Fig4.2."

# ╔═╡ 142d846a-610f-4308-8622-be0f589374ba
begin
	noofsteps = 20
	noofwalks = 15
	pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks))
	pos[1, :] = zeros(noofwalks)
	csum = cumsum(pos, dims=1)
end;

# ╔═╡ 1918943f-11ca-47f0-8ec8-6723656dcaad
md"##### Plot and annotate the random walks."

# ╔═╡ 2198aa92-300a-4503-a3cf-52eaa6f99b61
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="$(size(csum, 2)) random walks of $(size(csum, 1)) steps", xticks = ([4, 8, 16], ["step 4", "step 8", "step 16"]))
	for i in 1:size(csum, 2)
		lines!(csum[:, i])
	end
	vlines!([4, 8, 16]; color=:darkblue)
	f
end
	

# ╔═╡ 6e397b9c-f0e8-4146-925b-e281d8a2c040
md"##### Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)."

# ╔═╡ f235bad6-2a1e-49cd-8c6c-876209bc6373
let
	f = Figure(resolution=default_figure_resolution)
	for (indx, step) in enumerate([4, 8, 16])
		ax = Axis(f[1, indx]; title = "Density after $(step) steps")
		fitl = fit_mle(Normal, csum[step+1, :])
		lx = (fitl.μ-4*fitl.σ):0.01:(fitl.μ+4*fitl.σ)
		density!(rand(Normal(fitl.μ, fitl.σ), 10000); color=(:orange, 0.3),strokecolor=:orange, strokewidth=3)
		density!(f[1, indx], csum[step+1, :]; color=(:lightblue, 0.3),strokecolor=:blue, strokewidth=3)
		xlims!(-10, 10)
		ylims!(0, 0.5)
	end
	f
end

# ╔═╡ 6edc4101-78b3-434b-a03b-2c5915742661
md"### Julia code snippet 4.2"

# ╔═╡ c5806d51-9be6-49e1-9b95-bca5be15a33b
prod(1 .+ rand(Uniform(0, .1), 12))

# ╔═╡ bc7b4b29-3fb5-4b05-9701-45c0631c92ae
md"### Julia code snippet 4.3"

# ╔═╡ 56163c82-7652-4449-9204-b062c3853167
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
    u = Uniform(0, .1)
    growth = prod.(eachrow(1 .+ rand(u, 10000, 12)));
    density!(growth; color=(:blue, 0.2),strokecolor=:blue, strokewidth=3)
    # overlay normal distribution
    μ = mean(growth)
    σ = std(growth)
    density!(rand(Normal(μ, σ), 10000); color=(:orange, 0.1),strokecolor=:orange, strokewidth=3)
	f
end

# ╔═╡ 713faf3d-2a06-4683-b6fd-b161b920a21e
md"### Julia code snippet 4.4 and 4.5"

# ╔═╡ 025c8b62-eaff-41ad-8bb6-6b575b8a2445
let
	f = Figure(resolution=default_figure_resolution)
	
    global big = prod.(eachrow(1 .+ rand(Uniform(0, 0.5), 10000, 12)));
    small = prod.(eachrow(1 .+ rand(Uniform(0, 0.01), 10000, 12)));
	ax = Axis(f[1, 1]; title="Density `big`")
    density!(big; color=(:blue, 0.2),strokecolor=:blue, strokewidth=3)
	ax = Axis(f[2, 1]; title="Density `small`")
    density!(small; color=(:blue, 0.2),strokecolor=:blue, strokewidth=3)
	ax = Axis(f[3, 1]; title="Density `log(big)`")
	density!(log.(big); color=(:blue, 0.2),strokecolor=:blue, strokewidth=3)
	f
end

# ╔═╡ Cell order:
# ╠═c77d49eb-cbd9-4c2b-88cf-339b31f3cddb
# ╠═6a0e1509-a003-4b92-a244-f96a9dd7dd3e
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─d703cce4-da8d-4391-8fc3-f3373c0a4643
# ╟─ca213187-aedf-49b7-9393-607bf6a4f08e
# ╟─497d10d9-2553-4d04-b79a-f5281c500bb6
# ╠═142d846a-610f-4308-8622-be0f589374ba
# ╟─1918943f-11ca-47f0-8ec8-6723656dcaad
# ╠═2198aa92-300a-4503-a3cf-52eaa6f99b61
# ╟─6e397b9c-f0e8-4146-925b-e281d8a2c040
# ╠═f235bad6-2a1e-49cd-8c6c-876209bc6373
# ╟─6edc4101-78b3-434b-a03b-2c5915742661
# ╠═c5806d51-9be6-49e1-9b95-bca5be15a33b
# ╟─bc7b4b29-3fb5-4b05-9701-45c0631c92ae
# ╠═56163c82-7652-4449-9204-b062c3853167
# ╟─713faf3d-2a06-4683-b6fd-b161b920a21e
# ╠═025c8b62-eaff-41ad-8bb6-6b575b8a2445
