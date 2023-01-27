### A Pluto.jl notebook ###
# v0.19.20

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

# ╔═╡ ef416733-2e9a-4a20-ad54-ad2fb1a50eb5
using Pkg

# ╔═╡ 8be42366-9118-426b-9407-f5eb17ff80f0
begin
	# General packages
	using Distributions
	using LaTeXStrings

	# Grphics related
	using PlutoUI
	using GLMakie
	
	# Specific for SR2StanPluto
	using StanSample
	using StanQuap
	
	# Projects
	using RegressionAndOtherStories
end

# ╔═╡ f700b150-8382-44af-893e-1cbd7d97610d
md" ## Chapter 2 - Small Worlds and Large World."

# ╔═╡ 18b85845-f1ca-4a19-afb0-6e4282e9228f
md"##### Set page layout for notebook."

# ╔═╡ bda8c10f-eef0-4f0a-a8ee-219792ac4b34
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(80px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ 4fdc6ba2-f1fb-4525-87c8-0aa5800fa4b5
md"### Julia code snippet 2.1"

# ╔═╡ 4ef0e151-9fc4-4ab3-81a2-efb29c7a3bb3
begin
    ways = [0, 3, 8, 9, 0]
    ways = ways ./ sum(ways)
end

# ╔═╡ c2b719c4-7ff8-434c-af3c-52431016efe2
md"### Julia code snippet 2.2"

# ╔═╡ 5d237149-f37a-4cac-b730-78f309f93b31
let
    b = Binomial(9, 0.5)
    pdf(b, 6)
end

# ╔═╡ 3de688bc-9383-42db-b0b3-6f0bef53c373
md"### Julia code snippet 2.3"

# ╔═╡ 58d16e75-43c2-4328-bc67-82ac40c1de31
md"##### Size of the grid."

# ╔═╡ 3235bfbf-2b53-4762-9842-105608343660
size = 20

# ╔═╡ 663b0e04-d4de-4d36-b688-c4acdabf8179
md"##### Grid and prior."

# ╔═╡ 83a06085-b389-4aa3-aefc-451511c36dc5
p_grid = range(0, 1; length=size)

# ╔═╡ 7fae1866-e076-4eea-aeee-e4758823fc2e
prior = repeat([1.0], size)

# ╔═╡ b2495576-c63d-4eda-8e62-bb7dd517ecd4
md"##### Compute likelihood at each value in grid."

# ╔═╡ a2d4e3d2-a42c-4e42-8889-f63a2fb0b2c0
likelihood = [pdf(Binomial(9, p), 6) for p in p_grid];

# ╔═╡ ef3b5609-c9e9-4a22-a0a1-15a3d03205a7
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Distribution of likelihood on the grid")
	lines!(p_grid, likelihood)
	f
end

# ╔═╡ 6a658e52-e842-47e1-a3c1-d0f2dab1c979
md"##### Compute the product of likelihood and prior."

# ╔═╡ 268cb94b-4f87-406b-a5fd-934f1327d99a
unstd_posterior = likelihood .* prior;

# ╔═╡ fe661a68-78ae-4dc8-a5ad-aaf9dae88bb6
md"##### Standardize the posterior, so it sums to 1."

# ╔═╡ 7bf57734-82ad-44a5-8b1e-8ddc826b2e40
posterior = unstd_posterior / sum(unstd_posterior);

# ╔═╡ 09aa2045-6d1b-460a-b6d5-a45de36d0be9
md"### Julia code snippet 2.4"

# ╔═╡ 8e3d0ba3-dfb7-49d2-8b9b-afec7337f514
@bind N PlutoUI.Slider(5:1:1000, default=20)

# ╔═╡ 4124aed5-9b68-460c-af5b-155e8ec5cc53
let
	p_grid = range(0, 1; length=N)
	prior = repeat([1.0], N)
	likelihood = [pdf(Binomial(9, p), 6) for p in p_grid]
	unstd_posterior = likelihood .* prior
	posterior = unstd_posterior / sum(unstd_posterior)
	
	f = Figure(resolution = default_figure_resolution)
	ax = Axis(f[1, 1]; title="Posterior distribution of probability of water ($N points)",
	    xlabel="probability of water", 
	    ylabel="posterior probability")
	lines!(p_grid, posterior)
	scatter!(p_grid, posterior)
	f
end

# ╔═╡ 30f5e835-c43b-42f5-b56a-6bac186d11e5
md"### Julia code snippet 2.5"

# ╔═╡ 1e556e16-37b0-4de0-a3f1-e9defde82f05
let
    size = 100
    p_grid = range(0, 1; length=size)

    # prior is different - 0 if p < 0.5, 1 if >= 0.5
    prior = convert(Vector{AbstractFloat}, p_grid .>= 0.5)

    # another prior to try (uncomment the line below)
    # prior = exp.(-5*abs.(p_grid .- 0.5))

    # the rest is the same
    likelyhood = [pdf(Binomial(9, p), 6) for p in p_grid]
    unstd_posterior = likelyhood .* prior
    posterior = unstd_posterior / sum(unstd_posterior)

	f = Figure(resolution = default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="probability of water", ylabel="posterior probability", title="$size points")
	lines!(p_grid, posterior)
	scatter!(p_grid, posterior)
	f

end

# ╔═╡ d50cd0f1-0d5a-4f7c-8242-72388f0e6565
md"### Julia code snippet 2.6"

# ╔═╡ 8440c903-5fee-4399-9fd9-c2b491e83949
m2_1 = "
data{
    int W;
    int L;
}
parameters {
    real<lower=0, upper=1> p;
}
model {
    p ~ uniform(0, 1);
    W ~ binomial(W + L, p);
}";

# ╔═╡ 8e0e6cae-838c-473d-a222-6f6eac13d989
begin
    m2_1s = SampleModel("m2_1s", m2_1)
    rc2_1s = stan_sample(m2_1s; data = (W=6, L=3))
	success(rc2_1s) && describe(m2_1s, [:p])
end

# ╔═╡ 451c3c98-255c-4623-b0fa-19917f5573f7
if success(rc2_1s)
    post2_1s = read_samples(m2_1s, :dataframe)
	ms2_1s = model_summary(post2_1s, [:p])
end

# ╔═╡ 16dfa2a7-be8f-46ea-964d-0b2b0697c1e5
begin
	qm, sm, om = stan_quap("m2_1s", m2_1; data = (W=6, L=3), init = (p = 0.5,))
	om.optim |> display
	qm
end

# ╔═╡ 8d0aaa63-8ca8-4f6d-b829-5985c0ce5ec7
md"### Julia code snippet 2.7"

# ╔═╡ 3eaca463-2743-456f-a6aa-705799f99592
let
    x = range(0, 1; length=101)
	
	f = Figure(resolution = default_figure_resolution)
	ax = Axis(f[1, 1]; title="W=6. L=3")
    W = 6; L = 3
	qm, sm, om = stan_quap("m2_1s", m2_1; data = (W=6, L=3), init = (p = 0.5,))
    b = Beta(W+1, L+1)
    lines!(x, pdf.(b, x))
	lines!(x, pdf.(qm.distr, x))
	
	ax = Axis(f[1, 2]; title="W=12. L=6")
    W = 12; L = 6
	qm, sm, om = stan_quap("m2_1s", m2_1; data = (W=12, L=6), init = (p = 0.5,))
    b = Beta(W+1, L+1)
    lines!(x, pdf.(b, x))
	lines!(x, pdf.(qm.distr, x))
	
	ax = Axis(f[1, 3]; title="W=24. L=12")
	qm, sm, om = stan_quap("m2_1s", m2_1; data = (W=24, L=12), init = (p = 0.5,))
	W = 24; L = 12
    b = Beta(W+1, L+1)
    lines!(x, pdf.(b, x))
	lines!(x, pdf.(qm.distr, x))
	f
end

# ╔═╡ ae452813-f237-4568-aea6-82f3723622b5
md"##### Quadratic approximation."

# ╔═╡ 81b47785-3f4d-4a0c-b35e-85b0de760029
md"### Julia code snippet 2.8"

# ╔═╡ d19b9ff8-cbdf-45cf-878b-9edc630d9c69
begin
    n_samples = 1000
    p = Vector{Float64}(undef, n_samples)
    p[1] = 0.5
    W, L = 6, 3

    for i ∈ 2:n_samples
        p_old = p[i-1]
        p_new = rand(Normal(p_old, 0.1))
        if p_new < 0
            p_new = abs(p_new)
        elseif p_new > 1
            p_new = 2-p_new
        end

        q0 = pdf(Binomial(W+L, p_old), W)
        q1 = pdf(Binomial(W+L, p_new), W)
        u = rand(Uniform())
        p[i] = (u < q1 / q0) ? p_new : p_old
    end
end

# ╔═╡ 57985c29-eb61-40bc-9478-f092650ad68d
md"### Julia code snippet 2.9"

# ╔═╡ 3c227bff-f7db-49f5-aaad-f2a58fcf4151
let
	x = range(0, 1; length=101)
	f = Figure(resolution = default_figure_resolution)
	ax = Axis(f[1, 1]; title = "Posterior sample density (blue) and Beta analytical density (darkred)")
    density!(p; color = (:lightblue, 0.3), strokecolor = :blue, strokewidth = 3)
    b = Beta(W+1, L+1)
    lines!(x, pdf.(b, x); color=:darkred, linewidth = 3)
	f
end

# ╔═╡ Cell order:
# ╟─f700b150-8382-44af-893e-1cbd7d97610d
# ╠═18b85845-f1ca-4a19-afb0-6e4282e9228f
# ╠═bda8c10f-eef0-4f0a-a8ee-219792ac4b34
# ╠═ef416733-2e9a-4a20-ad54-ad2fb1a50eb5
# ╠═8be42366-9118-426b-9407-f5eb17ff80f0
# ╟─4fdc6ba2-f1fb-4525-87c8-0aa5800fa4b5
# ╠═4ef0e151-9fc4-4ab3-81a2-efb29c7a3bb3
# ╟─c2b719c4-7ff8-434c-af3c-52431016efe2
# ╠═5d237149-f37a-4cac-b730-78f309f93b31
# ╟─3de688bc-9383-42db-b0b3-6f0bef53c373
# ╟─58d16e75-43c2-4328-bc67-82ac40c1de31
# ╟─3235bfbf-2b53-4762-9842-105608343660
# ╟─663b0e04-d4de-4d36-b688-c4acdabf8179
# ╠═83a06085-b389-4aa3-aefc-451511c36dc5
# ╠═7fae1866-e076-4eea-aeee-e4758823fc2e
# ╟─b2495576-c63d-4eda-8e62-bb7dd517ecd4
# ╠═a2d4e3d2-a42c-4e42-8889-f63a2fb0b2c0
# ╠═ef3b5609-c9e9-4a22-a0a1-15a3d03205a7
# ╟─6a658e52-e842-47e1-a3c1-d0f2dab1c979
# ╠═268cb94b-4f87-406b-a5fd-934f1327d99a
# ╟─fe661a68-78ae-4dc8-a5ad-aaf9dae88bb6
# ╠═7bf57734-82ad-44a5-8b1e-8ddc826b2e40
# ╟─09aa2045-6d1b-460a-b6d5-a45de36d0be9
# ╠═8e3d0ba3-dfb7-49d2-8b9b-afec7337f514
# ╠═4124aed5-9b68-460c-af5b-155e8ec5cc53
# ╟─30f5e835-c43b-42f5-b56a-6bac186d11e5
# ╠═1e556e16-37b0-4de0-a3f1-e9defde82f05
# ╟─d50cd0f1-0d5a-4f7c-8242-72388f0e6565
# ╠═8440c903-5fee-4399-9fd9-c2b491e83949
# ╠═8e0e6cae-838c-473d-a222-6f6eac13d989
# ╠═451c3c98-255c-4623-b0fa-19917f5573f7
# ╠═16dfa2a7-be8f-46ea-964d-0b2b0697c1e5
# ╟─8d0aaa63-8ca8-4f6d-b829-5985c0ce5ec7
# ╠═3eaca463-2743-456f-a6aa-705799f99592
# ╟─ae452813-f237-4568-aea6-82f3723622b5
# ╟─81b47785-3f4d-4a0c-b35e-85b0de760029
# ╠═d19b9ff8-cbdf-45cf-878b-9edc630d9c69
# ╟─57985c29-eb61-40bc-9478-f092650ad68d
# ╠═3c227bff-f7db-49f5-aaad-f2a58fcf4151
