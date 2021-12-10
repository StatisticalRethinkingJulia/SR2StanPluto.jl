### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 0c9c514e-598c-418f-90e5-4a74ffb5bdc0
begin
    import Pkg
    # activate a temporary environment
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="Plots", version="1"),
        Pkg.PackageSpec(name="PlutoUI", version="0.7"),
        Pkg.PackageSpec(name="Distributions"),
        Pkg.PackageSpec(name="DataFrames", version="1"),
        Pkg.PackageSpec(name="StanSample", version="5.2"),
        Pkg.PackageSpec(name="StatisticalRethinking", version="4.4"),
    ])
    using Plots, PlutoUI
	using Distributions, DataFrames
	using StanSample, StatisticalRethinking
end

# ╔═╡ f2224d36-7972-4e21-badc-3a401bf6f0bb
pwd()

# ╔═╡ 7d6d3864-3bff-414d-b077-ab59673f6d25
@__DIR__

# ╔═╡ eb07b03c-4617-4e07-b68a-476b903460e0
Pkg.pkg"status"

# ╔═╡ ed6fe9e3-df1d-4c60-b3f0-9cab2c81eb78
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

# ╔═╡ a022fd36-61aa-4e85-92e0-0ab55339468b
data = (N=1000, D=rand(Normal(0,1), 1000));

# ╔═╡ 3104104b-b90b-4279-a79e-a94502869172
begin
	m0_0s = SampleModel("m0_0s", stan0_0)
	rc0_0s = stan_sample(m0_0s; data)
end;

# ╔═╡ 3dab9dbd-2955-4a11-816f-d986ce0529bd
if success(rc0_0s)
	df0_0s = read_samples(m0_0s, :dataframe)
	PRECIS(df0_0s)
end

# ╔═╡ Cell order:
# ╠═f2224d36-7972-4e21-badc-3a401bf6f0bb
# ╠═7d6d3864-3bff-414d-b077-ab59673f6d25
# ╠═0c9c514e-598c-418f-90e5-4a74ffb5bdc0
# ╠═eb07b03c-4617-4e07-b68a-476b903460e0
# ╠═ed6fe9e3-df1d-4c60-b3f0-9cab2c81eb78
# ╠═a022fd36-61aa-4e85-92e0-0ab55339468b
# ╠═3104104b-b90b-4279-a79e-a94502869172
# ╠═3dab9dbd-2955-4a11-816f-d986ce0529bd
