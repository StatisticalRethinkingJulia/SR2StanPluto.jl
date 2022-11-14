### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ f2224d36-7972-4e21-badc-3a401bf6f0bb
pwd()

# ╔═╡ 7d6d3864-3bff-414d-b077-ab59673f6d25
@__DIR__

# ╔═╡ 866f4346-58fa-11ec-2d52-1fe8cc15ffbd
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using Plots, PlutoUI
	using StanSample, StatisticalRethinking
end

# ╔═╡ 0c9c514e-598c-418f-90e5-4a74ffb5bdc0
begin
    import Pkg
    # activate a temporary environment
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="Plots", version="1"),
        Pkg.PackageSpec(name="PlutoUI", version="0.7"),
    ])
    using Plots, PlutoUI, LinearAlgebra
end

# ╔═╡ Cell order:
# ╠═866f4346-58fa-11ec-2d52-1fe8cc15ffbd
# ╠═f2224d36-7972-4e21-badc-3a401bf6f0bb
# ╠═7d6d3864-3bff-414d-b077-ab59673f6d25
# ╠═0c9c514e-598c-418f-90e5-4a74ffb5bdc0
