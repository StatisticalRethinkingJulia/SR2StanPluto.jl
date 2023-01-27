### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 4ade4692-fc0b-11ea-0b14-6b6cb2435655
using Pkg

# ╔═╡ 4ade84b6-fc0b-11ea-06ff-9517579c812c
begin
	# Script specific
    using BSplines

	# Graphics related
	using GLMakie
	
	# Stan related
	using StanSample, StanQuap

	# Project related
	using StatisticalRethinking: sr_datadir, scale!
	using RegressionAndOtherStories
end

# ╔═╡ 48df2a12-f043-426d-b06b-ed013365df02
md" ## 4.5 - Curves from lines."

# ╔═╡ 38a1cbef-a70e-4bd4-ab96-6b86f93113e3
md"##### Set page layout for notebook."

# ╔═╡ 5f30641d-2c85-4712-a853-2992071ddbbc
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

# ╔═╡ 5433c67d-6294-4984-9490-04e4a0edeb7a
md" ### Julia code snippet 4.64"

# ╔═╡ 4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
begin
    howell1 = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
    scale!(howell1, [:height, :weight])
    howell1.weight_s2 = howell1.weight_s.^2
    howell1.weight_s3 = howell1.weight_s.^3
	howell1
end

# ╔═╡ 4af06c94-fc0b-11ea-128c-89bea7c3af63
md"##### Define the Stan language model."

# ╔═╡ 4afd2eb8-fc0b-11ea-2f26-7329e44823a5
stan4_5 = "
data{
    int N;
    vector[N] height;
    vector[N] weight_s;
    vector[N] weight_s2;
    vector[N] weight_s3;
}
parameters{
    real alpha;
    real beta1;
    real beta2;
	real beta3;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta1 ~ lognormal( 0 , 1 );
    beta2 ~ normal( 0 , 10 );
    beta3 ~ normal( 0 , 10 );
    alpha ~ normal( 178 , 20 );
    mu = alpha + beta1 * weight_s + beta2 * weight_s2 + beta3 * weight_s3;
    height ~ normal( mu , sigma );
}
";

# ╔═╡ f2e57abf-36d2-4aae-9176-23ff30630d7b
md" ### Julia code snippet 4.65"

# ╔═╡ 4afec1ea-fc0b-11ea-1674-b59e51b9f027
md"##### Define the SampleModel, etc,"

# ╔═╡ c0c5b9c9-9ead-4a73-a42c-cb0761e27355
let
    data = Dict(
        :N => size(howell1, 1), 
        :height => howell1.height, 
        :weight_s => howell1.weight_s,
        :weight_s2 => repeat([0.0], length(howell1.weight)),
        :weight_s3 => repeat([0.0], length(howell1.weight))
    )
    init = Dict(:alpha => 140.0, :beta1 => 15.0, :beta2 => -5.0, :sigma => 10.0)
    global q4_5s_1, m4_5s_1, _ = stan_quap("m4.5s", stan4_5; data, init)
    global quap4_5s_1_df = sample(q4_5s_1)
	describe(m4_5s_1, [:alpha, :beta1, :beta2, :sigma])
end

# ╔═╡ 67c95124-c98c-425d-b809-aaefdde83385
md" ### Julia code snippet 4.66"

# ╔═╡ 4b0b60fa-fc0b-11ea-3929-0f0077415fc7
let
    data = Dict(
        :N => size(howell1, 1), 
        :height => howell1.height, 
        :weight_s => howell1.weight_s,
        :weight_s2 => howell1.weight_s2,
        :weight_s3 => repeat([0.0], length(howell1.weight))

    )
    init = Dict(:alpha => 140.0, :beta1 => 15.0, :beta2 => -5.0, :sigma => 10.0)
    global q4_5s_2, m4_5s_2, _ = stan_quap("m4.5s", stan4_5; data, init)
    global quap4_5s_2_df = sample(q4_5s_2)
	describe(m4_5s_2, [:alpha, :beta1, :beta2, :sigma])
end

# ╔═╡ 017a4e0a-cee7-4425-b321-363e02a7ee09
md" ### Julia code snippet 4.67"

# ╔═╡ bd0521fc-4967-490d-842e-9660215c4949
let
    data = Dict(
        :N => size(howell1, 1), 
        :height => howell1.height, 
        :weight_s => howell1.weight_s,
        :weight_s2 => howell1.weight_s2,
        :weight_s3 => howell1.weight_s3
    )
    init = Dict(:alpha => 140.0, :beta1 => 15.0, :beta2 => -5.0, :sigma => 10.0)
    global q4_5s_3, m4_5s_3, _ = stan_quap("m4.5s", stan4_5; data, init)
    global quap4_5s_3_df = sample(q4_5s_3)
	describe(m4_5s_3, [:alpha, :beta1, :beta2, :beta3, :sigma])
end

# ╔═╡ 4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
rethinking = "
        mean   sd   5.5%  94.5%
a     146.06 0.37 145.47 146.65
b1     21.73 0.29  21.27  22.19
b2     -7.80 0.27  -8.24  -7.36
sigma   5.77 0.18   5.49   6.06
";

# ╔═╡ 5ed82af0-ff8b-4314-9619-2b072bb46d72
md" ### Julia code snippet 4.68"

# ╔═╡ 66c18c7c-0bfc-4299-92cc-052819b1aea9
model_summary(quap4_5s_1_df, [:alpha, :beta1, :sigma])

# ╔═╡ de75748c-e107-45ad-9f76-3a492669d9ab
model_summary(quap4_5s_2_df, [:alpha, :beta1, :beta2, :sigma])

# ╔═╡ 35da8b12-97df-4308-801d-2185249682c8
model_summary(quap4_5s_3_df, [:alpha, :beta1, :beta2, :beta3, :sigma])

# ╔═╡ 4b2109c8-fc0b-11ea-0aed-2b80f6b14188
md"### Julia code snippets 4.69"

# ╔═╡ 869225aa-b050-48fe-aa5e-7e6f7450f0ea
let
	mu_range = -2:0.1:2
	res1 = link(quap4_5s_1_df, (r, x) -> r.alpha + r.beta1 * x, mu_range)
	res1 = hcat(res1...)
	m1, l1, u1 = estimparam(res1)
	
	res2 = link(quap4_5s_2_df, (r, x) -> r.alpha + r.beta1 * x + r.beta2 * x^2, mu_range)
	res2 = hcat(res2...)
	m2, l2, u2 = estimparam(res2)
	
	res3 = link(quap4_5s_3_df, (r, x) -> r.alpha + r.beta1 * x +r.beta2 * x^2 + r.beta3 * x^3, mu_range)
	res3 = hcat(res3...)
	m3, l3, u3 = estimparam(res3)

	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="weight_s", ylabel="height", title="....")
	Makie.lines!(mu_range, m1)
	Makie.band!(mu_range, l1, u1; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)

	ax = Axis(f[1, 2]; xlabel="weight_s", ylabel="height", title="....")
	Makie.lines!(mu_range, m2)
	Makie.band!(mu_range, l2, u2; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)

	ax = Axis(f[1, 3]; xlabel="weight_s", ylabel="height", title="....")
	Makie.lines!(mu_range, m3)
	Makie.band!(mu_range, l3, u3; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)
	
	f
end

# ╔═╡ 02467ecb-1d9a-4daf-92ba-bdd827352f7a
md" ### Julia code snippet 4.71"

# ╔═╡ 8d2760a0-7fb4-4c59-bc31-dd095221a3ad
let
	(mu_range) = -2:0.1:2
	res1 = link(quap4_5s_1_df, (r, x) -> r.alpha + r.beta1 * x, mu_range)
	res1 = hcat(res1...)
	m1, l1, u1 = estimparam(res1)
	
	res2 = link(quap4_5s_2_df, (r, x) -> r.alpha + r.beta1 * x + r.beta2 * x^2, mu_range)
	res2 = hcat(res2...)
	m2, l2, u2 = estimparam(res2)
	
	res3 = link(quap4_5s_3_df, (r, x) -> r.alpha + r.beta1 * x +r.beta2 * x^2 + r.beta3 * x^3, mu_range)
	res3 = hcat(res3...)
	m3, l3, u3 = estimparam(res3)

	scale_factor = std(howell1.weight) + mean(howell1.weight)
	xtick_labels = [string(round(mu .* scale_factor, digits=2)) for mu in -2:1:2]
	
	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="weight_s", ylabel="height", title="....",
		xticks=(-2:1:2, xtick_labels),)
	Makie.lines!(mu_range, m1)
	Makie.band!(mu_range, l1, u1; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)

	ax = Axis(f[1, 2]; xlabel="weight_s", ylabel="height", title="....",
		xticks=(-2:1:2, xtick_labels),)
	Makie.lines!(mu_range, m2)
	Makie.band!(mu_range, l2, u2; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)

	ax = Axis(f[1, 3]; xlabel="weight_s", ylabel="height", title="....",
		xticks=(-2:1:2, xtick_labels),)
	Makie.lines!(mu_range, m3)
	Makie.band!(mu_range, l3, u3; color=:lightblue)
	Makie.scatter!(howell1.weight_s, howell1.height, color=:darkred, markersize=5)
	
	f
end

# ╔═╡ 6c667a30-967b-47a1-8a6f-37dfefeafb3f
scale_factor = std(howell1.weight) + mean(howell1.weight)

# ╔═╡ dd03d579-c392-4aea-9962-daf56f34d953
let
	mu_range = -2:1:2
	xtick_values = [string(round(mu .* scale_factor, digits=2)) for mu in mu_range]
end

# ╔═╡ 7a1666f9-1f5e-419f-b472-5643a0f3ce20
md" ### Julia code snippet 4.72"

# ╔═╡ 553c775e-d249-4d9c-a83c-10c21c970110
begin
	df = CSV.read(sr_datadir("cherry_blossoms.csv"), DataFrame; missingstring = "NA")
	df = dropmissing(df, :doy)
end;

# ╔═╡ 66a6647d-5361-4934-93d6-d1f4b657a761
let
	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="year", ylabel="doy", title="Cherry blossom")
	Makie.scatter!(df.year, df.doy, leg=false)
	f
end

# ╔═╡ 90115e51-c2e1-4b0f-888c-ec2e57650a3c
describe(df)

# ╔═╡ cad0a3e7-f0cc-4657-a5c6-cc42fc153253
begin
	num_knots = 15
	knot_list = quantile(df.year, range(0, 1, length = num_knots))
	basis = BSplineBasis(4, knot_list)
	B = basismatrix(basis, df.year)
end;

# ╔═╡ 7a6094d9-8480-4171-8c9f-d1a0011ad93c
let
	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="year", ylabel="basis value", title="....")
	for y in eachcol(B)
		Makie.lines!(df.year, y)
	end
	f
end

# ╔═╡ 53e977f8-a245-4101-9395-c9cacb1a5ca7
md"## snippet 4.76"

# ╔═╡ 6175ab8f-8d70-4e11-950a-210796ee62fe
stan4_7 = "
data {
    int n;
    int k;
    int doy[n];
    matrix[n, k] B;
}
parameters {
    real a;
    vector[k] w;
    real<lower=0> sigma;
}
transformed parameters {
    vector[n] mu;
    mu = a + B * w;
}
model {
    for (i in 1:n) {
        doy[i] ~ normal(mu[i], sigma);
    }
    a ~ normal(100, 10);
    w ~ normal(0, 10);
    sigma ~ exponential(1);
}
";

# ╔═╡ 6773c9dc-2bcb-44bc-b261-5bf638bddc80
begin
	m4_7s = SampleModel("m4.7s", stan4_7)
	data1 = Dict(:n => size(B, 1), :k => size(B, 2), :doy => df.doy, :B => B)
	init1 = Dict(:mu => ones(17) * 100, :sigma => 20.0)
	rc4_7s = stan_sample(m4_7s; data=data1)
end;

# ╔═╡ e3371838-b97f-4b9d-8fe5-e48539658487
begin
	w_str = ["w.$i" for i in 1:length(basis)]
	cols = ["a", "sigma", w_str...]
end

# ╔═╡ 508af79e-4933-49e8-aaa4-060ba70ae495
begin
	if success(rc4_7s)
		post4_7s_df = read_samples(m4_7s, :dataframe)
		model_summary(post4_7s_df, names(post4_7s_df))
	end
end

# ╔═╡ d50b4ff5-f472-48aa-8dd7-27d14930bcae
md"### snippet 4.77"

# ╔═╡ e4154abf-3510-478b-b006-a3cd1139519c
begin
	post_3 = post4_7s_df[:, ["a"; w_str; "sigma"]]
	w_3 = mean.(eachcol(post_3[:, w_str]))              # either
	w_3 = [mean(post_3[:, col]) for col in w_str]       # or
	
	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="year", ylabel="basis * weight", title="....")
	for y in eachcol(B .* w_3')
		Makie.lines!(df.year, y)
	end
	f
end

# ╔═╡ d506d2cd-628e-464e-b510-b8c51b37cb40
md"### snippet 4.78"

# ╔═╡ 2f44287f-790c-4141-a406-bb24bef30879
let
	mu_3 = post_3.a' .+ B * Array(post_3[!, w_str])'
	m, l, u = meanlowerupper(mu_3)

	f = Figure(resolution= default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Observations", ylabel="day in year")
	Makie.scatter!(df.year, df.doy)
	Makie.lines!(df.year, m)
	Makie.band!(Int.(df.year), l, u; color=(:orange, 0.3))
	f
end

# ╔═╡ 75ecc407-8451-4c33-b681-c50bc00c1546
md"## End of clip-04-72-79s.jl"

# ╔═╡ Cell order:
# ╟─48df2a12-f043-426d-b06b-ed013365df02
# ╟─38a1cbef-a70e-4bd4-ab96-6b86f93113e3
# ╠═5f30641d-2c85-4712-a853-2992071ddbbc
# ╟─5433c67d-6294-4984-9490-04e4a0edeb7a
# ╠═4ade4692-fc0b-11ea-0b14-6b6cb2435655
# ╠═4ade84b6-fc0b-11ea-06ff-9517579c812c
# ╠═4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
# ╟─4af06c94-fc0b-11ea-128c-89bea7c3af63
# ╠═4afd2eb8-fc0b-11ea-2f26-7329e44823a5
# ╟─f2e57abf-36d2-4aae-9176-23ff30630d7b
# ╟─4afec1ea-fc0b-11ea-1674-b59e51b9f027
# ╠═c0c5b9c9-9ead-4a73-a42c-cb0761e27355
# ╟─67c95124-c98c-425d-b809-aaefdde83385
# ╠═4b0b60fa-fc0b-11ea-3929-0f0077415fc7
# ╟─017a4e0a-cee7-4425-b321-363e02a7ee09
# ╠═bd0521fc-4967-490d-842e-9660215c4949
# ╠═4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
# ╟─5ed82af0-ff8b-4314-9619-2b072bb46d72
# ╠═66c18c7c-0bfc-4299-92cc-052819b1aea9
# ╠═de75748c-e107-45ad-9f76-3a492669d9ab
# ╠═35da8b12-97df-4308-801d-2185249682c8
# ╟─4b2109c8-fc0b-11ea-0aed-2b80f6b14188
# ╠═869225aa-b050-48fe-aa5e-7e6f7450f0ea
# ╟─02467ecb-1d9a-4daf-92ba-bdd827352f7a
# ╠═8d2760a0-7fb4-4c59-bc31-dd095221a3ad
# ╠═6c667a30-967b-47a1-8a6f-37dfefeafb3f
# ╠═dd03d579-c392-4aea-9962-daf56f34d953
# ╟─7a1666f9-1f5e-419f-b472-5643a0f3ce20
# ╠═553c775e-d249-4d9c-a83c-10c21c970110
# ╠═66a6647d-5361-4934-93d6-d1f4b657a761
# ╠═90115e51-c2e1-4b0f-888c-ec2e57650a3c
# ╠═cad0a3e7-f0cc-4657-a5c6-cc42fc153253
# ╠═7a6094d9-8480-4171-8c9f-d1a0011ad93c
# ╟─53e977f8-a245-4101-9395-c9cacb1a5ca7
# ╠═6175ab8f-8d70-4e11-950a-210796ee62fe
# ╠═6773c9dc-2bcb-44bc-b261-5bf638bddc80
# ╠═e3371838-b97f-4b9d-8fe5-e48539658487
# ╠═508af79e-4933-49e8-aaa4-060ba70ae495
# ╟─d50b4ff5-f472-48aa-8dd7-27d14930bcae
# ╠═e4154abf-3510-478b-b006-a3cd1139519c
# ╟─d506d2cd-628e-464e-b510-b8c51b37cb40
# ╠═2f44287f-790c-4141-a406-bb24bef30879
# ╟─75ecc407-8451-4c33-b681-c50bc00c1546
