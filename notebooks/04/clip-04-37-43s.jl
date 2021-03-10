### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 92d425a2-fb7f-11ea-0c47-03f8eec55862
using Pkg, DrWatson

# ╔═╡ 92d465d0-fb7f-11ea-09ac-dba2e8262027
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ 5aa8f26c-fb7e-11ea-0477-59c1da17fc15
md"## Clip-04-37-43s.jl"

# ╔═╡ 14eb9ca2-40ac-11eb-1f2d-250474bbb686
md"### snippet 4.37"

# ╔═╡ 92d50a6c-fb7f-11ea-05fd-0533613f0978
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight);
	df.weight_c = df.weight .- mean_weight;
end;

# ╔═╡ 2e14841e-40ac-11eb-0dbb-fdcae9c63042
md"### snippet 4.38"

# ╔═╡ 92e3b63e-fb7f-11ea-309a-5b6db7cdab70
md"##### Define the Stan language models."

# ╔═╡ 92e4747c-fb7f-11ea-0b2a-578127070b2c
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

# ╔═╡ 46b81502-409c-11eb-1119-75eb74b6c0f4
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

# ╔═╡ 930a2c6a-fb7f-11ea-0637-9f9a4f99cbae
md"##### Compute quadratic approximations."

# ╔═╡ 933be70a-fb7f-11ea-085b-1f1e155132e1
begin
	init = Dict(:alpha => 170.0, :beta => 2.0)
	q4_3as, _, _ = stan_quap("m4.4as", stan4_3a; init)
	quap4_3as_df = sample(q4_3as)
	q4_3bs, _, _ = stan_quap("m4.3bs", stan4_3b; init)
	quap4_3bs_df = sample(q4_3bs)
end;|

# ╔═╡ ce3ae1be-40ab-11eb-2711-919ea63fd7a6
PRECIS(quap4_3as_df)

# ╔═╡ cdb969b8-40ab-11eb-2211-8511c31eb1f0
PRECIS(quap4_3bs_df)

# ╔═╡ dce29dee-40b8-11eb-236b-d92c8c5bed27
md"## snippet 4.40"

# ╔═╡ 81805f0e-40b8-11eb-2267-09cf44b3ac24
begin
	density(rand(LogNormal(0, 1), 4000))
end

# ╔═╡ 656476f4-40ac-11eb-39fc-79b01948e0bd
md"### snippets 4.39 & 4.41"

# ╔═╡ 932c24fa-fb7f-11ea-1f58-8d2518905066
if !isnothing(q4_3as) && !isnothing(q4_3bs)
	x = range(30.0, stop=70.0, length=50)
	xbar = mean(x)
	fig1 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400),
		leg=false, title="beta ~ Normal(0, 10)")
	for i in 1:100
		fig1 = plot!(x, quap4_3as_df.alpha[i] .+ quap4_3as_df.beta[i] .* (x .- xbar), color=:grey)
	end
	fig2 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
		leg=false, title="beta ~ LogNormal(0, 1)")
	for i in 1:100
		fig2 = plot!(x, quap4_3bs_df.alpha[i] .+ quap4_3bs_df.beta[i] .* (x .- xbar), color=:grey)
	end
	hline!(fig1, [0.0, 272.0], width=3)
	annotate!(fig1, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig1, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	hline!(fig2, [0.0, 272.0], width=3)
	annotate!(fig2, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig2, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	plot(fig1, fig2, layout=(1, 2))
end

# ╔═╡ 89a13cc8-40bd-11eb-1c01-15fafba40b0c
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

# ╔═╡ afc73d92-40bd-11eb-0cc7-6f4a94bdab5c
begin
	q4_3cs, sm, om = stan_quap("m4.3cs", stan4_3c; init)
	quap4_3cs_df = sample(q4_3cs)
	PRECIS(quap4_3cs_df)
end

# ╔═╡ 12a22c24-40be-11eb-2284-afea7d7996df
if !isnothing(q4_3cs) && !isnothing(q4_3bs)
	fig3 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
		leg=false, title="log_beta ~ Normal(0, 1)")
	for i in 1:100
		fig3 = plot!(x, quap4_3cs_df.alpha[i] .+ 
			exp(quap4_3cs_df.log_beta[i]) .* (x .- xbar), color=:grey)
	end

	hline!(fig3, [0.0, 272.0], width=3)
	annotate!(fig3, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig3, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	plot(fig2, fig3, layout=(1, 2))
end

# ╔═╡ 934badd4-fb7f-11ea-24b7-1d2740deb647
md"# End of clip-04-37-43s.jl"

# ╔═╡ Cell order:
# ╟─5aa8f26c-fb7e-11ea-0477-59c1da17fc15
# ╠═92d425a2-fb7f-11ea-0c47-03f8eec55862
# ╠═92d465d0-fb7f-11ea-09ac-dba2e8262027
# ╟─14eb9ca2-40ac-11eb-1f2d-250474bbb686
# ╠═92d50a6c-fb7f-11ea-05fd-0533613f0978
# ╟─2e14841e-40ac-11eb-0dbb-fdcae9c63042
# ╟─92e3b63e-fb7f-11ea-309a-5b6db7cdab70
# ╠═92e4747c-fb7f-11ea-0b2a-578127070b2c
# ╠═46b81502-409c-11eb-1119-75eb74b6c0f4
# ╟─930a2c6a-fb7f-11ea-0637-9f9a4f99cbae
# ╠═933be70a-fb7f-11ea-085b-1f1e155132e1
# ╠═ce3ae1be-40ab-11eb-2711-919ea63fd7a6
# ╠═cdb969b8-40ab-11eb-2211-8511c31eb1f0
# ╟─dce29dee-40b8-11eb-236b-d92c8c5bed27
# ╠═81805f0e-40b8-11eb-2267-09cf44b3ac24
# ╟─656476f4-40ac-11eb-39fc-79b01948e0bd
# ╠═932c24fa-fb7f-11ea-1f58-8d2518905066
# ╠═89a13cc8-40bd-11eb-1c01-15fafba40b0c
# ╠═afc73d92-40bd-11eb-0cc7-6f4a94bdab5c
# ╠═12a22c24-40be-11eb-2284-afea7d7996df
# ╟─934badd4-fb7f-11ea-24b7-1d2740deb647
