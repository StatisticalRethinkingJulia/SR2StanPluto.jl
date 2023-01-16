### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 4ade4692-fc0b-11ea-0b14-6b6cb2435655
using Pkg

# ╔═╡ 4ade84b6-fc0b-11ea-06ff-9517579c812c
begin
    using BSplines
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
    using StatisticalRethinkingPlots
    using PlutoUI
end

# ╔═╡ 181f0620-fc0a-11ea-1c2d-ff1a89cf0660
md"# Clip-04-64-74s.jl"

# ╔═╡ 4adf1662-fc0b-11ea-18b7-2f80e0a2d4f4
md"### Preliminary snippets."

# ╔═╡ 4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
begin
    howell1 = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
    scale!(howell1, [:height, :weight])
    howell1.weight_sq_s = howell1.weight_s.^2
    #scale!(df, [:weight_sq])
end;

# ╔═╡ 43155bf0-ddf9-4ccb-88ea-b158d38e715d
howell1

# ╔═╡ 4af06c94-fc0b-11ea-128c-89bea7c3af63
md"##### Define the Stan language model."

# ╔═╡ 4afd2eb8-fc0b-11ea-2f26-7329e44823a5
stan4_5 = "
data{
    int N;
    vector[N] height;
    vector[N] weight;
    vector[N] weight_sq;
}
parameters{
    real alpha;
    real beta1;
    real beta2;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta1 ~ lognormal( 0 , 1 );
    beta2 ~ normal( 0 , 1 );
    alpha ~ normal( 178 , 20 );
    mu = alpha + beta1 * weight + beta2 * weight_sq;
    height ~ normal( mu , sigma );
}
";

# ╔═╡ 4afec1ea-fc0b-11ea-1674-b59e51b9f027
md"##### Define the SampleModel, etc,"

# ╔═╡ 4b0b60fa-fc0b-11ea-3929-0f0077415fc7
begin
    data = Dict(
        :N => size(howell1, 1), 
        :height => howell1.height, 
        :weight => howell1.weight_s,
        :weight_sq => howell1.weight_sq_s
    )
    init = Dict(:alpha => 140.0, :beta1 => 15.0, :beta2 => -5.0, :sigma => 10.0)
    q4_5s, m4_5s, _ = stan_quap("m4.5s", stan4_5; data, init)
    quap4_5s_df = sample(q4_5s)
    PRECIS(quap4_5s_df)
end

# ╔═╡ 4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
rethinking = "
        mean   sd   5.5%  94.5%
a     146.06 0.37 145.47 146.65
b1     21.73 0.29  21.27  22.19
b2     -7.80 0.27  -8.24  -7.36
sigma   5.77 0.18   5.49   6.06
";

# ╔═╡ 4b2030de-fc0b-11ea-3bce-0b80a6338b7e
if !isnothing(m4_5s)
  sdf4_5s = read_summary(m4_5s)
end

# ╔═╡ 4b2109c8-fc0b-11ea-0aed-2b80f6b14188
md"### Julia code snippet 4.64 - 4.67"

# ╔═╡ 4b30dc0e-fc0b-11ea-30c4-05c83cf73fda
if !isnothing(q4_5s)
    begin
        function link_poly(dfa::DataFrame, xrange)
            vars = Symbol.(names(dfa))
            [dfa[:, vars[1]] + dfa[:, vars[2]] * x +  dfa[:, vars[3]] * x^2 
                for x in xrange]
        end

        mu_range = -2:0.1:2

        xbar = mean(howell1[:, :weight])
        mu = link_poly(quap4_5s_df, mu_range);

        plot(xlab="weight_s", ylab="height")
        for (indx, mu_val) in enumerate(mu_range)
        for j in 1:length(mu_range)
            scatter!([mu_val], [mu[indx][j]], leg=false, color=:darkblue)
        end
        end
        scatter!(howell1.weight_s, howell1.height, color=:lightblue)
    end
end

# ╔═╡ 4b39d052-fc0b-11ea-2d21-755ffb969e42
if !isnothing(q4_5s)
    plot(xlab="weight_s", ylab="height", leg=:bottomright)
    fheight(weight, a, b1, b2) = a + weight * b1 + weight^2 * b2
    testweights = -2:0.01:2
    arr = [fheight.(w, quap4_5s_df.alpha, quap4_5s_df.beta1, quap4_5s_df.beta2) 
        for w in testweights]
    m = [mean(v) for v in arr]
    quantiles = [quantile(v, [0.055, 0.945]) for v in arr]
    lower = [q[1] - m for (q, m) in zip(quantiles, m)]
    upper = [q[2] - m for (q, m) in zip(quantiles, m)]
    scatter!(howell1[:, :weight_s], howell1[:, :height], lab="Observations")
    plot!(testweights, m, ribbon = [lower, upper], 
        lab="(0.055, 0.945) quantiles of mean")
end

# ╔═╡ 7aefb03c-8ff7-4b7f-8ae5-663e78f216c9
md"### snippet 4.73"

# ╔═╡ 553c775e-d249-4d9c-a83c-10c21c970110
begin
	df = CSV.read(sr_datadir("cherry_blossoms.csv"), DataFrame; 
		missingstring = "NA")
	df = dropmissing(df, :doy)
end;

# ╔═╡ 66a6647d-5361-4934-93d6-d1f4b657a761
scatter(df.year, df.doy, leg=false)

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
begin
	plot(legend = false, xlabel = "year", ylabel = "basis value")
	for y in eachcol(B)
		plot!(df.year, y)
	end
	plot!()
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
		PRECIS(post4_7s_df[:, cols])
	end
end

# ╔═╡ d50b4ff5-f472-48aa-8dd7-27d14930bcae
md"### snippet 4.77"

# ╔═╡ e4154abf-3510-478b-b006-a3cd1139519c
begin
	post_3 = post4_7s_df[:, ["a"; w_str; "sigma"]]
	w_3 = mean.(eachcol(post_3[:, w_str]))              # either
	w_3 = [mean(post_3[:, col]) for col in w_str]       # or
	plot(legend = false, xlabel = "year", ylabel = "basis * weight")
	for y in eachcol(B .* w_3')
		plot!(df.year, y)
	end
	plot!()
end

# ╔═╡ d506d2cd-628e-464e-b510-b8c51b37cb40
md"### snippet 4.78"

# ╔═╡ e0d8eac2-327a-4bfd-9a63-a3e28cd076dd
begin
	mu_3 = post_3.a' .+ B * Array(post_3[!, w_str])'
	mu_3 = meanlowerupper(mu_3)
	plot(xlab="year", ylab="day in year", leg=:topleft)
	scatter!(df.year, df.doy, alpha = 0.3, lab="Observations")
	plot!(df.year, mu_3.mean, 
		ribbon = (mu_3.mean .- mu_3.lower, mu_3.upper .- mu_3.mean),
		lab="Regression")
end

# ╔═╡ 75ecc407-8451-4c33-b681-c50bc00c1546
md"## End of clip-04-72-79s.jl"

# ╔═╡ Cell order:
# ╟─181f0620-fc0a-11ea-1c2d-ff1a89cf0660
# ╠═4ade4692-fc0b-11ea-0b14-6b6cb2435655
# ╠═4ade84b6-fc0b-11ea-06ff-9517579c812c
# ╟─4adf1662-fc0b-11ea-18b7-2f80e0a2d4f4
# ╠═4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
# ╠═43155bf0-ddf9-4ccb-88ea-b158d38e715d
# ╟─4af06c94-fc0b-11ea-128c-89bea7c3af63
# ╠═4afd2eb8-fc0b-11ea-2f26-7329e44823a5
# ╟─4afec1ea-fc0b-11ea-1674-b59e51b9f027
# ╠═4b0b60fa-fc0b-11ea-3929-0f0077415fc7
# ╠═4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
# ╠═4b2030de-fc0b-11ea-3bce-0b80a6338b7e
# ╟─4b2109c8-fc0b-11ea-0aed-2b80f6b14188
# ╠═4b30dc0e-fc0b-11ea-30c4-05c83cf73fda
# ╠═4b39d052-fc0b-11ea-2d21-755ffb969e42
# ╠═7aefb03c-8ff7-4b7f-8ae5-663e78f216c9
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
# ╠═e0d8eac2-327a-4bfd-9a63-a3e28cd076dd
# ╟─75ecc407-8451-4c33-b681-c50bc00c1546
