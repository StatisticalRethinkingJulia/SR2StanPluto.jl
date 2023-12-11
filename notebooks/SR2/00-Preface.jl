### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 5325ee1d-d8ae-4e9b-a885-b9ce88d22573
using Pkg

# ╔═╡ c111bf72-e608-4724-ba62-849fec752987
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ af7e9280-a940-45e8-a2b7-37c7eba21302
begin
	# General packages
	using GLM
	
	# Specific to Stan
	using StanSample
	
    # Graphics related
    using CairoMakie
	
    # Include "project" support packages
	using StatisticalRethinking: sr_datadir
 	using RegressionAndOtherStories
end

# ╔═╡ 8d89b043-42d4-4724-b1b5-613bb218c435
md" ## Chapter 0 - Preface of Statistical Rethinking."

# ╔═╡ ea75686e-d3d5-4c55-a8ac-7b0cc7798834
md"##### Set page layout for notebook."

# ╔═╡ 11c5ae87-0890-4099-afc1-51c035196727
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(10px, 3%);
    	padding-right: max(10px, 38%);
	}
</style>
"""


# ╔═╡ d00abc27-537d-4e8d-8fc5-c7f6c7fb3710
md" ### Julia code snippet 0.5"

# ╔═╡ 475d7028-47e9-4784-be47-23ca89d7821f
md"### Julia code snippet 0.1"

# ╔═╡ 892ca0ca-ad34-4d20-85a5-01b1f8c7a277
println("All models are wrong, but some are useful!")

# ╔═╡ ef74b60c-f5da-4e35-849e-7282364820d4
md"### Julia code snippet 0.2"

# ╔═╡ aa4453ae-d34a-406b-be01-0dcb96d6de84
begin
	x = range(1, 2, length=2)
	x = x .* 10 .|> log |> sum |> exp
end

# ╔═╡ 3f4c0789-a978-4ce5-bc18-038d4cc4b339
md"### Julia code snippet 0.3"

# ╔═╡ 35782da0-bad0-4ede-9e62-1527cf4f94ef
let
	p₁ = log(0.01^200)
	p₂ = 200 * log(0.01)
	[p₁, p₂]
end

# ╔═╡ e99023ce-738c-4277-a3de-278e1fdcc651
md"### Julia code snippet 0.4"

# ╔═╡ d5f57114-326f-4ee8-b634-77ff05de354a
cars = CSV.read(sr_datadir("cars.csv"), DataFrame)

# ╔═╡ ee0e953d-80f5-49f9-8e89-f93b957cb421
md" #### Use GLM."

# ╔═╡ 1578c482-eac6-4449-89ce-ed2372afe8d2
cars_lm = lm(@formula(dist ~ speed), cars)

# ╔═╡ f91514f0-217f-4a0d-b8ba-425705b984e0
residuals(cars_lm)

# ╔═╡ dc30aaf5-7f67-4353-966f-533a847f7f5b
mad(residuals(cars_lm))

# ╔═╡ 266a3df6-3406-4b32-86cb-b83badbca7a8
std(residuals(cars_lm))

# ╔═╡ 0234a159-6410-4c08-858f-1191e56e1607
coef(cars_lm)

# ╔═╡ 90f8174e-4ea8-45b4-9e88-38c3bd19b5e8
let
	fig = Figure(;size=default_figure_resolution)
	xlabel = "Speed"
	ylabel = "Distance"
	let
		title = "Scatterplot of dist on speed."
		ax = Axis(fig[1, 1]; title, xlabel, ylabel)
		for (ind, dist) in enumerate(cars.dist)
			annotations!("$(dist)"; position=(cars.speed[ind], cars.dist[ind]), fontsize=10)
		end
	end
	let
		x = LinRange(4, 25, 100)
		title = "Linear regression line"
		ax = Axis(fig[1, 2]; title, xlabel, ylabel)
		scatter!(cars.speed, cars.dist)
		lines!(x, coef(cars_lm)[1] .+ coef(cars_lm)[2] .* x; color=:darkred)
		annotations!("dist = -17.6 + 3.9 * speed"; position=(5, 100))
	end

	fig
end

# ╔═╡ cd7e70e8-7858-4192-b78d-82020611b875
md" #### Use Stan."

# ╔═╡ 9206a33f-4c8a-4237-8408-cfab69908a8a
stan0_0 = "
data {
	int N;
	vector[N] dist;
	vector[N] speed;
}
parameters {
	real a;
	real b;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	// Priors
	a ~ uniform(-20, 20);
	b ~ uniform(1, 10);
	sigma ~ exponential(1);
	// Compute mu
	mu = a + b * speed;
	// LogLikelihood
	dist ~ normal(mu, sigma);
}";

# ╔═╡ d54e4bb7-6370-4d3a-ac0c-62d78bb60744
begin
	data = (N = length(cars.speed), speed = cars.speed, dist = cars.dist)
	m0_0s = SampleModel("m0_0s", stan0_0)
	rc0_0s= stan_sample(m0_0s; data)
	success(rc0_0s) && describe(m0_0s, [:a, :b, :sigma])
end

# ╔═╡ 83a35831-4097-44d6-bb0a-a2e969683a6a
if success(rc0_0s)
	post0_0s = read_samples(m0_0s, :dataframe)
	ms0_0s = model_summary(post0_0s, [:a, :b, :sigma])
end

# ╔═╡ fef3388e-3ea7-4b1c-8d65-d1ae1aed2ab1
post0_0s

# ╔═╡ ebb198b7-21b0-4c5d-81c4-e4c6e5ae3880
md" ##### Quantiles and compatibility range."

# ╔═╡ 95a68c56-cb44-4cb9-a3d8-88b7cd3ab97d
quantile(post0_0s.b, [0.05, 0.25, 0.50, 0.75, 0.95])

# ╔═╡ 4db453be-21e4-4dd3-ba52-ec11bb4fca2b
quantile(post0_0s.b, [0.055, 0.945])

# ╔═╡ 8253d342-cde8-47ec-9499-029333184a7a
hpdi(post0_0s.b)

# ╔═╡ 62a9b89b-1f61-44f5-9387-8b882214209a
md"##### Extract mean a and b params."

# ╔═╡ 31653011-fdec-473c-b2bc-c897540f4e3a
mean_a, mean_b, mean_sigma = ms0_0s[:, :mean]

# ╔═╡ bf595f34-f2f5-4852-81a5-d77cf76644cf
md" ##### Plot residuals."

# ╔═╡ d26b5c9a-5912-40fc-9ee4-12c75dd97150
let
	f = Figure(;size = default_figure_resolution)
	ax = Axis(f[1, 1]; title = "Speed vs residual of predicted distance", xlabel = "Speed", ylabel = "Model residual")
	resid = cars.dist - (mean_a .+ mean_b * cars.speed)
	scatter!(cars.speed, resid; color=:darkblue)
	hlines!([0.0]; color=:darkred)
	for (ind, dist) in enumerate(cars.dist)
		annotations!("$(dist)"; position=(cars.speed[ind] + 0.1, resid[ind]), fontsize=12)
	end
	f
end

# ╔═╡ 4362e509-66a3-476f-a69f-10f312315c14
md" #### Below a number of ways to check the sampling process of a Stan Language program."

# ╔═╡ 517ddb5a-51c9-4c6a-aeb0-721c1b5b1280
read_summary(m0_0s)

# ╔═╡ abb45d1c-a896-48d9-93c1-022022a842c7
plot_chains(post0_0s, [:a, :b, :sigma])

# ╔═╡ 57a27592-7880-4876-8bf1-31cb97868f3f
trankplot(post0_0s, "b")

# ╔═╡ f00a4384-c4ea-4372-839a-2bcc5763ab4b
let
	fig = Figure(;size = default_figure_resolution)
	xlabel = "Speed"
	ylabel = "Distance"
	let
		title = "Scatterplot of dist and speed."
		ax = Axis(fig[1, 1]; title, xlabel, ylabel)
		for (ind, dist) in enumerate(cars.dist)
			annotations!("$(dist)"; position=(cars.speed[ind], cars.dist[ind]), fontsize=10)
		end
	end
	x = LinRange(4, 25, 100)
	title = "Regression line of distance on speed\nStan (red), GLM (darkblue)\nand sample regression lines (grey)"
	ax = Axis(fig[1, 2]; title, xlabel, ylabel)
	for i in 1:100
		lines!(x, post0_0s.a[i] .+ post0_0s.b[i] .* x; color=:lightgrey)
	end
	stan = lines!(x, ms0_0s[:a, :median] .+ ms0_0s[:b, :median] .* x; color=:darkred)
	glm = lines!(x, coef(cars_lm)[1] .+ coef(cars_lm)[2] .* x; color=:darkblue)
	scatter!(cars.speed, cars.dist)
	annotations!("Stan: dist = $(ms0_0s[:a, :median]) + $(ms0_0s[:b, :median]) * speed"; position=(5, 100))
	annotations!("GLM: dist = $(round(coef(cars_lm)[1]; digits=1)) + $(round(coef(cars_lm)[2]; digits=1)) * speed"; position=(5, 105))
	fig
end

# ╔═╡ e3efb80b-34e1-430f-b037-53cc51edf7fc
md"### Julia code snippet 0.5 - See top of notebook"

# ╔═╡ Cell order:
# ╟─8d89b043-42d4-4724-b1b5-613bb218c435
# ╟─ea75686e-d3d5-4c55-a8ac-7b0cc7798834
# ╠═11c5ae87-0890-4099-afc1-51c035196727
# ╟─d00abc27-537d-4e8d-8fc5-c7f6c7fb3710
# ╠═5325ee1d-d8ae-4e9b-a885-b9ce88d22573
# ╠═c111bf72-e608-4724-ba62-849fec752987
# ╠═af7e9280-a940-45e8-a2b7-37c7eba21302
# ╟─475d7028-47e9-4784-be47-23ca89d7821f
# ╠═892ca0ca-ad34-4d20-85a5-01b1f8c7a277
# ╟─ef74b60c-f5da-4e35-849e-7282364820d4
# ╠═aa4453ae-d34a-406b-be01-0dcb96d6de84
# ╟─3f4c0789-a978-4ce5-bc18-038d4cc4b339
# ╠═35782da0-bad0-4ede-9e62-1527cf4f94ef
# ╟─e99023ce-738c-4277-a3de-278e1fdcc651
# ╠═d5f57114-326f-4ee8-b634-77ff05de354a
# ╟─ee0e953d-80f5-49f9-8e89-f93b957cb421
# ╠═1578c482-eac6-4449-89ce-ed2372afe8d2
# ╠═f91514f0-217f-4a0d-b8ba-425705b984e0
# ╠═dc30aaf5-7f67-4353-966f-533a847f7f5b
# ╠═266a3df6-3406-4b32-86cb-b83badbca7a8
# ╠═0234a159-6410-4c08-858f-1191e56e1607
# ╠═90f8174e-4ea8-45b4-9e88-38c3bd19b5e8
# ╟─cd7e70e8-7858-4192-b78d-82020611b875
# ╠═9206a33f-4c8a-4237-8408-cfab69908a8a
# ╠═d54e4bb7-6370-4d3a-ac0c-62d78bb60744
# ╠═83a35831-4097-44d6-bb0a-a2e969683a6a
# ╠═fef3388e-3ea7-4b1c-8d65-d1ae1aed2ab1
# ╟─ebb198b7-21b0-4c5d-81c4-e4c6e5ae3880
# ╠═95a68c56-cb44-4cb9-a3d8-88b7cd3ab97d
# ╠═4db453be-21e4-4dd3-ba52-ec11bb4fca2b
# ╠═8253d342-cde8-47ec-9499-029333184a7a
# ╟─62a9b89b-1f61-44f5-9387-8b882214209a
# ╠═31653011-fdec-473c-b2bc-c897540f4e3a
# ╟─bf595f34-f2f5-4852-81a5-d77cf76644cf
# ╠═d26b5c9a-5912-40fc-9ee4-12c75dd97150
# ╟─4362e509-66a3-476f-a69f-10f312315c14
# ╠═517ddb5a-51c9-4c6a-aeb0-721c1b5b1280
# ╠═abb45d1c-a896-48d9-93c1-022022a842c7
# ╠═57a27592-7880-4876-8bf1-31cb97868f3f
# ╠═f00a4384-c4ea-4372-839a-2bcc5763ab4b
# ╟─e3efb80b-34e1-430f-b037-53cc51edf7fc
