### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 6fbe488b-f265-49a9-89c8-f5d11c45a907
using Pkg

# ╔═╡ 9dbace63-a018-4d16-96e2-c9a8ce35c14f
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
	# Graphics specific
	using CairoMakie
    using LaTeXStrings
	
	# Stan specific
	using StanSample
	using StanQuap

	# Project support packages
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 4e70810c-ff28-41f3-a8e5-44ba1856f58c
md"## Chapter 4.4 Linear predictions"

# ╔═╡ 10b69453-56ac-48bb-b780-1176c6a38e7e
md"##### Set page layout for notebooks."

# ╔═╡ a6d75e53-c7d7-4888-a46b-87b3f0321ec7
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


# ╔═╡ 2f5c0721-d7ee-4073-a026-2d8febf0f400
md" ##### Used packages in this notebook."

# ╔═╡ 6e93c98d-55d7-4a30-b9cf-1b411ad7ef3c
md"### Julia code snippet 4.37"

# ╔═╡ 5e32911e-2aa3-43b1-9741-db17042bf344
begin
    d = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
    d2 = d[d.age .>= 18,:]
end

# ╔═╡ 90dc4bbc-8574-40ab-bdd1-a8999391c09b
let

	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Weight", ylabel="Height", title="Scatter plot of Howell1 data")
	Makie.scatter!(d2.weight, d2.height)
	f
end

# ╔═╡ b17401c9-c278-4525-8ffd-36b2274115dc
md"### Julia code snippet 4.38"

# ╔═╡ a23d3abd-3376-4122-b210-a71f1dbbf444
begin
    Random.seed!(2971)
    N = 100
    a = rand(Normal(178, 20), N)
    b = rand(Normal(0, 10), N);
end;

# ╔═╡ 3233d3f9-768a-4197-8b67-ef59e298d133
md"### Julia code snippet 4.39"

# ╔═╡ 00bc00c5-981c-4158-aeb4-17437ac48fe4
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Weight [kg]", ylabel="Height [cm]", title="Possible prior regression lines")
	hlow = Makie.hlines!([0, 272]; color=:darkred)
	Makie.xlims!(extrema(d2.weight)...)
	
    x_mean = mean(d2.weight)

	lin = lines!(d2.weight, a[1] .+ b[1] .* (d2.weight .- x_mean); color=:grey)
    for (α, β) ∈ zip(a, b)
        lines!(d2.weight, α .+ β .* (d2.weight .- x_mean); color=(:grey, 0.3), linewidth=0.1)
    end
	sca = scatter!(d2.weight, d2.height)
	Legend(f[1, 2], [lin, sca, hlow], ["Possible prior lines", "Howell1 data", "Actual height range"])

	f
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
# ╠═╡ show_logs = false
begin
    init = Dict(:alpha => 170.0, :beta => 2.0)
    q4_3as, m4_3as, map4_3as = stan_quap("m4.4as", stan4_3a; init)
    quap4_3as_df = sample(q4_3as)
	post4_3as_df = read_samples(m4_3as, :dataframe)
    q4_3bs, m4_3bs, map4_3bs = stan_quap("m4.3bs", stan4_3b; init)
    quap4_3bs_df = sample(q4_3bs)
	post4_3bs_df = read_samples(m4_3bs, :dataframe)
end;

# ╔═╡ d1794441-ecd9-46c7-930e-c9249506746b
md" ###### MAP estimate for model stan4_3a"

# ╔═╡ d4aef9a6-55d3-4c24-88da-449f12635a65
model_summary(quap4_3as_df, [:alpha, :beta])

# ╔═╡ ac96511d-4844-42de-a701-812eaac8bac7
md" ###### Stan estimate for model stan4_3a"

# ╔═╡ af7a1862-d0f5-4c00-8690-f78c07b603a5
model_summary(post4_3as_df, [:alpha, :beta])

# ╔═╡ 808ef1b2-dec2-4c7e-937e-8b467b085d95
md" ###### MAP estimate for model stan4_3b"

# ╔═╡ 772910c7-aae5-4af3-bd85-a095f6f7243f
model_summary(quap4_3bs_df, [:alpha, :beta])

# ╔═╡ b9865650-eca2-45cb-864f-7d6b13630b4c
md" ###### Stan estimate for model stan4_34"

# ╔═╡ 334866d3-6e28-469b-beb9-3db79cc413a9
model_summary(post4_3bs_df, [:alpha, :beta])

# ╔═╡ 7fb1a1a1-7b74-43dd-8c1b-bd8af4a5ec43
md" ###### Output of StanOptimize.jl (4 chains)"

# ╔═╡ d96e4240-d65f-4e4e-9632-4573d0edfeb3
map4_3as

# ╔═╡ dc05de5c-17fb-4d39-a165-ca1b4b05f760
map4_3bs

# ╔═╡ f5dfab0a-fd89-4d6d-b1a7-da23721458ad
md"## snippet 4.40"

# ╔═╡ 6071f58d-29cc-4acc-83ee-5cc79f8bd230
density(rand(LogNormal(0, 1), 4000))

# ╔═╡ 2880d9f6-b2d4-4314-9009-92b61a030c32
md"### snippets 4.39 & 4.41"

# ╔═╡ a3c00d6d-f96e-424a-85cb-5dd17d07c4e1
let
	if !isnothing(q4_3as) && !isnothing(q4_3bs)
	    x = range(30.0, stop=70.0, length=50)
	    xbar = mean(x)

		f = Figure(resolution=default_figure_resolution)
		ax = Axis(f[1, 1]; ylabel="height [cm]", xlabel="weight [kg]", title="beta ~ Normal(0, 10)")
	    ylims!(ax, -100, 400)
	    for i in 1:30
	        lines!(x, quap4_3as_df.alpha[i] .+ quap4_3as_df.beta[i] .* (x .- xbar), color=:grey)
	    end
	    hlines!([0.0, 272.0]; color=:darkred)
	    annotations!("Embryo", position=(30.0, 1), color=:darkblue)
	    annotations!("World's largest person (272 cm)", position=(30.0, 273.0), color=:darkblue)
		
	    ax = Axis(f[1, 2]; ylabel="height [cm]", xlabel="weight [kg]", title="beta ~ LogNormal(0, 1)")
		ylims!(ax, -100, 400)
	    for i in 1:30
	        lines!(x, quap4_3bs_df.alpha[i] .+ quap4_3bs_df.beta[i] .* (x .- xbar), color=:grey)
	    end
	    hlines!([0.0, 272.0]; color=:darkred)
	    annotations!("Embryo", position=(30.0, 1), color=:darkblue)
	    annotations!("World's largest person (272 cm)", position=(30.0, 273.0), color=:darkblue)
	
	    f
	end
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
    model_summary(quap4_3cs_df, [:alpha, :log_beta])
end

# ╔═╡ 096d9aab-be97-471f-99b4-cd678f4dc05b
let
	if !isnothing(q4_3cs) && !isnothing(q4_3bs)
	    x = range(30.0, stop=70.0, length=50)
	    xbar = mean(x)

		f = Figure(resolution=default_figure_resolution)
	    ax = Axis(f[1, 1]; ylabel="height [cm]", xlabel="weight [kg]", title="beta ~ LogNormal(0, 1)")
		ylims!(ax, -100, 400)
	    for i in 1:30
	        lines!(x, quap4_3bs_df.alpha[i] .+ quap4_3bs_df.beta[i] .* (x .- xbar), color=:grey)
	    end
	    hlines!([0.0, 272.0], color=:darkred)
	    annotations!("Embryo", position=(30.0, 1), color=:darkblue)
	    annotations!("World's largest person (272 cm)", position=(30.0, 273.0), color=:darkblue)
	
		ax = Axis(f[1, 2]; ylabel="height [cm]", xlabel="weight [kg]", title="log_beta ~ Normal(0, 10)")
	    ylims!(ax, -100, 400)
	    for i in 1:30
	        lines!(x, quap4_3cs_df.alpha[i] .+ quap4_3cs_df.log_beta[i] .* (x .- xbar), color=:grey)
	    end
	    hlines!([0.0, 272.0], color=:darkred)
	    annotations!("Embryo", position=(30.0, 1.0), color=:darkblue)
	    annotations!("World's largest person (272 cm)", position=(30.0, 273.0), color=:darkblue)
		
	    f
	end
end

# ╔═╡ Cell order:
# ╟─4e70810c-ff28-41f3-a8e5-44ba1856f58c
# ╟─10b69453-56ac-48bb-b780-1176c6a38e7e
# ╠═a6d75e53-c7d7-4888-a46b-87b3f0321ec7
# ╟─2f5c0721-d7ee-4073-a026-2d8febf0f400
# ╠═6fbe488b-f265-49a9-89c8-f5d11c45a907
# ╠═9dbace63-a018-4d16-96e2-c9a8ce35c14f
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─6e93c98d-55d7-4a30-b9cf-1b411ad7ef3c
# ╠═5e32911e-2aa3-43b1-9741-db17042bf344
# ╠═90dc4bbc-8574-40ab-bdd1-a8999391c09b
# ╟─b17401c9-c278-4525-8ffd-36b2274115dc
# ╠═a23d3abd-3376-4122-b210-a71f1dbbf444
# ╟─3233d3f9-768a-4197-8b67-ef59e298d133
# ╠═00bc00c5-981c-4158-aeb4-17437ac48fe4
# ╠═c8a99130-4fef-469b-a661-43ebc9396d72
# ╠═10b52ae1-b8e2-4cf7-95e1-85e92b1b0b47
# ╟─021527e0-2917-47bf-87c0-865e25881fef
# ╠═3961ff19-fa00-4268-9d80-f7ee22eee3b7
# ╟─d1794441-ecd9-46c7-930e-c9249506746b
# ╠═d4aef9a6-55d3-4c24-88da-449f12635a65
# ╟─ac96511d-4844-42de-a701-812eaac8bac7
# ╠═af7a1862-d0f5-4c00-8690-f78c07b603a5
# ╟─808ef1b2-dec2-4c7e-937e-8b467b085d95
# ╠═772910c7-aae5-4af3-bd85-a095f6f7243f
# ╟─b9865650-eca2-45cb-864f-7d6b13630b4c
# ╠═334866d3-6e28-469b-beb9-3db79cc413a9
# ╟─7fb1a1a1-7b74-43dd-8c1b-bd8af4a5ec43
# ╠═d96e4240-d65f-4e4e-9632-4573d0edfeb3
# ╠═dc05de5c-17fb-4d39-a165-ca1b4b05f760
# ╟─f5dfab0a-fd89-4d6d-b1a7-da23721458ad
# ╠═6071f58d-29cc-4acc-83ee-5cc79f8bd230
# ╟─2880d9f6-b2d4-4314-9009-92b61a030c32
# ╠═a3c00d6d-f96e-424a-85cb-5dd17d07c4e1
# ╠═ba589d82-dc1f-4f22-b7de-2e62e8792e9a
# ╠═c0d81a89-2f17-40c7-b17f-8d3e2b82161d
# ╠═096d9aab-be97-471f-99b4-cd678f4dc05b
