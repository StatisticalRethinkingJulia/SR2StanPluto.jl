### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 866f4346-58fa-11ec-2d52-1fe8cc15ffbd
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using Plots, PlutoUI
	using Distributions, DataFrames
	using StanSample, StatisticalRethinking
end

# ╔═╡ f2224d36-7972-4e21-badc-3a401bf6f0bb
pwd()

# ╔═╡ 7d6d3864-3bff-414d-b077-ab59673f6d25
@__DIR__

# ╔═╡ 19f434b6-7f8c-40ff-a7ca-81dd0d6da884
md"##### Output will go to Terminal."

# ╔═╡ 19067711-ea26-47e7-901d-73df2640473b
Pkg.pkg"status"

# ╔═╡ 387e6736-a14f-46a9-accf-d21b046c0018
stan0_0 = "
data {
	int N;
	vector[N] D;
}
parameters {
	real a;
	real sigma;
}
model {
	a ~ normal(0, 2);
	sigma ~ exponential(1);
	D ~ normal(a, sigma);
}";

# ╔═╡ 6fe593b5-ac1e-484b-8ac5-779ff9499a1b
md"##### Slider variable `n` can go from 1:4"

# ╔═╡ bf6f4061-3ed4-4ab1-a315-38f2162ec74a
@bind k Slider(0:5, default=2)

# ╔═╡ 0b98128b-4826-4ac0-857e-a344be5218dc
data = (N=10^k, D=rand(Normal(0,1), 10^k));

# ╔═╡ 47d35d33-353c-443e-b24f-98eab9a0ca44
data.N

# ╔═╡ d943cc63-e0c1-4699-a4a1-ebf5320113a5
begin
	m0_0s = SampleModel("m0_0s", stan0_0)
	rc0_0s = stan_sample(m0_0s; data)
end;

# ╔═╡ 30e22695-bad8-4452-8f41-bd95e8792c87
if success(rc0_0s)
	df0_0s = read_samples(m0_0s, :dataframe)
	PRECIS(df0_0s)
end

# ╔═╡ Cell order:
# ╠═f2224d36-7972-4e21-badc-3a401bf6f0bb
# ╠═7d6d3864-3bff-414d-b077-ab59673f6d25
# ╠═866f4346-58fa-11ec-2d52-1fe8cc15ffbd
# ╟─19f434b6-7f8c-40ff-a7ca-81dd0d6da884
# ╠═19067711-ea26-47e7-901d-73df2640473b
# ╠═387e6736-a14f-46a9-accf-d21b046c0018
# ╟─6fe593b5-ac1e-484b-8ac5-779ff9499a1b
# ╠═bf6f4061-3ed4-4ab1-a315-38f2162ec74a
# ╠═0b98128b-4826-4ac0-857e-a344be5218dc
# ╠═47d35d33-353c-443e-b24f-98eab9a0ca44
# ╠═d943cc63-e0c1-4699-a4a1-ebf5320113a5
# ╠═30e22695-bad8-4452-8f41-bd95e8792c87
