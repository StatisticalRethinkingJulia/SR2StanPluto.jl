### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 6a0e1509-a003-4b92-a244-f96a9dd7dd3e
using Pkg

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
    using Distributions
    using StatsPlots
    using StatsBase
    using LaTeXStrings
    using CSV
    using DataFrames
    using LinearAlgebra
    using Random
	using StanSample, StanQuap
    using StatisticalRethinking
end

# ╔═╡ 10b69453-56ac-48bb-b780-1176c6a38e7e
md"##### Setting default attributes for plots."

# ╔═╡ 002242f8-4ad9-4383-8e0e-27a0b8fda241
default(label=false)

# ╔═╡ 4e70810c-ff28-41f3-a8e5-44ba1856f58c
md"## 4.4 Linear predictions"

# ╔═╡ 6e93c98d-55d7-4a30-b9cf-1b411ad7ef3c
md"### Julia code snippet 4.37"

# ╔═╡ 274e4aa4-6b25-44bc-8d65-5d8716ffdfd0
begin
    d = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
    d2 = d[d.age .>= 18,:]

    # fancy way of doing scatter(d2.weight, d2.height)
    @df d2 scatter(:weight, :height)
end

# ╔═╡ b17401c9-c278-4525-8ffd-36b2274115dc
md"### Julia code snippet 4.38"

# ╔═╡ a23d3abd-3376-4122-b210-a71f1dbbf444
begin
    Random.seed!(2971)
    N = 100
    a = rand(Normal(178, 20), N)
    b = rand(Normal(0, 10), N);
end

# ╔═╡ 3233d3f9-768a-4197-8b67-ef59e298d133
md"### Julia code snippet 4.39"

# ╔═╡ 1d3d908f-f5ab-477f-bb83-0ca4b04fcc1c
begin
    p = hline([0, 272]; ylims=(-100, 400), xlabel="weight", ylabel="hegiht")
    title!(L"\beta \sim \mathcal{N}(\mu=0,\sigma=10)")

    x_mean = mean(d2.weight)
    xlims = extrema(d2.weight)  # getting min and max in one pass

    for (α, β) ∈ zip(a, b)
        plot!(x -> α + β * (x - x_mean); xlims=xlims, c=:black, alpha=0.3)
    end
    p
end

# ╔═╡ c8a99130-4fef-469b-a661-43ebc9396d72
stan4_3a = "
parameters {
 real alpha;                       // Intercept
 real beta;                        // Slope (regression coefficients)
}

model {
    alpha ~ normal(178, 20);
    beta ~ normal(0, 10);
}
";

# ╔═╡ 10b52ae1-b8e2-4cf7-95e1-85e92b1b0b47
stan4_3b = "
parameters {
 real alpha;                       // Intercept
 real beta;                        // Slope (regression coefficients)
}

model {
    alpha ~ normal(178, 20);
    beta ~ lognormal(0, 1);
}
";

# ╔═╡ 021527e0-2917-47bf-87c0-865e25881fef
md"##### Compute quadratic approximations."

# ╔═╡ 3961ff19-fa00-4268-9d80-f7ee22eee3b7
begin
    init = Dict(:alpha => 170.0, :beta => 2.0)
    q4_3as, _, _ = stan_quap("m4.4as", stan4_3a; init)
    quap4_3as_df = sample(q4_3as)
    q4_3bs, _, _ = stan_quap("m4.3bs", stan4_3b; init)
    quap4_3bs_df = sample(q4_3bs)
end;|

# ╔═╡ d4aef9a6-55d3-4c24-88da-449f12635a65
PRECIS(quap4_3as_df)

# ╔═╡ 772910c7-aae5-4af3-bd85-a095f6f7243f
PRECIS(quap4_3bs_df)

# ╔═╡ f5dfab0a-fd89-4d6d-b1a7-da23721458ad
md"## snippet 4.40"

# ╔═╡ 6071f58d-29cc-4acc-83ee-5cc79f8bd230
begin
    density(rand(LogNormal(0, 1), 4000))
end

# ╔═╡ 2880d9f6-b2d4-4314-9009-92b61a030c32
md"### snippets 4.39 & 4.41"

# ╔═╡ f928cc2e-a65a-4dbc-98f0-620dbd26d1f2
if !isnothing(q4_3as) && !isnothing(q4_3bs)
    x = range(30.0, stop=70.0, length=50)
    xbar = mean(x)
    fig1 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400),
        leg=false, title="beta ~ Normal(0, 10)")
    for i in 1:30
        fig1 = plot!(x, 
			quap4_3as_df.alpha[i] .+ quap4_3as_df.beta[i] .* (x .- xbar), 
			color=:grey)
    end
    fig2 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
        leg=false, title="beta ~ LogNormal(0, 1)")
    for i in 1:30
        fig2 = plot!(x, 
			quap4_3bs_df.alpha[i] .+ quap4_3bs_df.beta[i] .* (x .- xbar), 
			color=:grey)
    end
    hline!(fig1, [0.0, 272.0], width=3)
    annotate!(fig1, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
    annotate!(fig1, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 
		6, :red, :left))])

    hline!(fig2, [0.0, 272.0], width=3)
    annotate!(fig2, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
    annotate!(fig2, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 
		6, :red, :left))])

    plot(fig1, fig2, layout=(1, 2))
end

# ╔═╡ ba589d82-dc1f-4f22-b7de-2e62e8792e9a
stan4_3c = "
parameters {
 real alpha;                       // Intercept
 real log_beta;                    // Slope (regression coefficients)
}

model {
    alpha ~ normal(178, 40);
    log_beta ~ normal(0, 1);
}
";

# ╔═╡ c0d81a89-2f17-40c7-b17f-8d3e2b82161d
begin
    q4_3cs, sm, om = stan_quap("m4.3cs", stan4_3c; init)
    quap4_3cs_df = sample(q4_3cs)
    PRECIS(quap4_3cs_df)
end

# ╔═╡ 096d9aab-be97-471f-99b4-cd678f4dc05b
if !isnothing(q4_3cs) && !isnothing(q4_3bs)
    fig3 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
        leg=false, title="log_beta ~ Normal(0, 1)")
    for i in 1:30
        fig3 = plot!(x, quap4_3cs_df.alpha[i] .+ 
            exp(quap4_3cs_df.log_beta[i]) .* (x .- xbar), color=:grey)
    end

    hline!(fig3, [0.0, 272.0], width=3)
    annotate!(fig3, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
    annotate!(fig3, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 
		6, :red, :left))])

    plot(fig2, fig3, layout=(1, 2))
end

# ╔═╡ Cell order:
# ╠═6a0e1509-a003-4b92-a244-f96a9dd7dd3e
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─10b69453-56ac-48bb-b780-1176c6a38e7e
# ╠═002242f8-4ad9-4383-8e0e-27a0b8fda241
# ╠═4e70810c-ff28-41f3-a8e5-44ba1856f58c
# ╠═6e93c98d-55d7-4a30-b9cf-1b411ad7ef3c
# ╠═274e4aa4-6b25-44bc-8d65-5d8716ffdfd0
# ╠═b17401c9-c278-4525-8ffd-36b2274115dc
# ╠═a23d3abd-3376-4122-b210-a71f1dbbf444
# ╟─3233d3f9-768a-4197-8b67-ef59e298d133
# ╠═1d3d908f-f5ab-477f-bb83-0ca4b04fcc1c
# ╠═c8a99130-4fef-469b-a661-43ebc9396d72
# ╠═10b52ae1-b8e2-4cf7-95e1-85e92b1b0b47
# ╟─021527e0-2917-47bf-87c0-865e25881fef
# ╠═3961ff19-fa00-4268-9d80-f7ee22eee3b7
# ╠═d4aef9a6-55d3-4c24-88da-449f12635a65
# ╠═772910c7-aae5-4af3-bd85-a095f6f7243f
# ╟─f5dfab0a-fd89-4d6d-b1a7-da23721458ad
# ╠═6071f58d-29cc-4acc-83ee-5cc79f8bd230
# ╟─2880d9f6-b2d4-4314-9009-92b61a030c32
# ╠═f928cc2e-a65a-4dbc-98f0-620dbd26d1f2
# ╠═ba589d82-dc1f-4f22-b7de-2e62e8792e9a
# ╠═c0d81a89-2f17-40c7-b17f-8d3e2b82161d
# ╠═096d9aab-be97-471f-99b4-cd678f4dc05b
