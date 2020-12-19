### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 81cdc1aa-04fd-11eb-3235-bff0e3f52535
using Pkg, DrWatson

# ╔═╡ 81cdee8c-04fd-11eb-29f5-85927396b6dc
begin
	@quickactivate "StatisticalRethinkingTuring"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 5e06a11c-04f6-11eb-0116-1fd51d614f99
md"## clip-04-72-79s"

# ╔═╡ 82a6656e-04fd-11eb-08c9-3bd9d2d8af20
md"### snippet 4.72"

# ╔═╡ 82ba1b72-04fd-11eb-33ed-0db4307c66fc
md"### snippet 4.73"

# ╔═╡ d9b4a9fa-0529-11eb-21b5-2da845b95fe9
begin
	df = CSV.read(sr_datadir("cherry_blossoms.csv"), DataFrame; missingstring = "NA")
	df = dropmissing(df, :doy)
end;

# ╔═╡ af9e141e-0529-11eb-3c28-b986f5939349
scatter(df.year, df.doy, leg=false)

# ╔═╡ 3f480052-4170-11eb-24ec-8984d7747c61
describe(df)

# ╔═╡ 34b5949e-4171-11eb-1570-2b928b2853a9
begin
	num_knots = 15
	knot_list = quantile(df.year, range(0, 1, length = num_knots))
	basis = BSplineBasis(4, knot_list)
	B = basismatrix(basis, df.year)
end;

# ╔═╡ b0b1e776-0575-11eb-093b-f1cb2d9c4b2e
begin
	plot(legend = false, xlabel = "year", ylabel = "basis value")
	for y in eachcol(B)
		plot!(df.year, y)
	end
	plot!()
end

# ╔═╡ 832a285e-04fd-11eb-061b-49a40155abe1
md"## snippet 4.76"

# ╔═╡ cdb02de2-0575-11eb-121e-df6ecd57ba7c
stan4_9 = "
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

# ╔═╡ 10d6cb88-4187-11eb-15bd-2729d9d69dc9
begin
	m4_9s = SampleModel("m4.9s", stan4_9)
	data = Dict(:n => size(B, 1), :k => size(B, 2), :doy => df.doy, :B => B)
	init = Dict(:mu => ones(17) * 100, :sigma => 20.0)
	rc4_9s = stan_sample(m4_9s; data)
	if success(rc4_9s)
		post4_9s_df = read_samples(m4_9s; output_format=:dataframe)
		PRECIS(post4_9s_df)
	end
end

# ╔═╡ 8343fe0a-04fd-11eb-2a3e-79daed2e6b98
md"### snippet 4.77"

# ╔═╡ 833793e0-04fd-11eb-0706-7567eada0aed
begin
	w_str = ["w.$i" for i in 1:length(basis)]
	post_3 = post4_9s_df[:, ["a"; w_str; "sigma"]]
	w_3 = mean.(eachcol(post_3[:, w_str]))              # either
	w_3 = [mean(post_3[:, col]) for col in w_str]       # or
	plot(legend = false, xlabel = "year", ylabel = "basis * weight")
	for y in eachcol(B .* w_3')
		plot!(df.year, y)
	end
	plot!()
end	

# ╔═╡ 83b54bb4-04fd-11eb-3208-4162cb3eabc7
md"### snippet 4.78"

# ╔═╡ d9fbed6e-0572-11eb-29bd-1d30ae286045
begin
	mu_3 = post_3.a' .+ B * Array(post_3[!, w_str])'
	mu_3 = meanlowerupper(mu_3)
	scatter(df.year, df.doy, alpha = 0.3)
	plot!(df.year, mu_3.mean, ribbon = (mu_3.mean .- mu_3.lower, mu_3.upper .- mu_3.mean))
end

# ╔═╡ 4f386d5c-0573-11eb-084c-1758217d06f9
md"## End of clip-04-72-79s.jl"

# ╔═╡ Cell order:
# ╟─5e06a11c-04f6-11eb-0116-1fd51d614f99
# ╠═81cdc1aa-04fd-11eb-3235-bff0e3f52535
# ╠═81cdee8c-04fd-11eb-29f5-85927396b6dc
# ╟─82a6656e-04fd-11eb-08c9-3bd9d2d8af20
# ╟─82ba1b72-04fd-11eb-33ed-0db4307c66fc
# ╠═d9b4a9fa-0529-11eb-21b5-2da845b95fe9
# ╠═af9e141e-0529-11eb-3c28-b986f5939349
# ╠═3f480052-4170-11eb-24ec-8984d7747c61
# ╠═34b5949e-4171-11eb-1570-2b928b2853a9
# ╠═b0b1e776-0575-11eb-093b-f1cb2d9c4b2e
# ╟─832a285e-04fd-11eb-061b-49a40155abe1
# ╠═cdb02de2-0575-11eb-121e-df6ecd57ba7c
# ╠═10d6cb88-4187-11eb-15bd-2729d9d69dc9
# ╟─8343fe0a-04fd-11eb-2a3e-79daed2e6b98
# ╠═833793e0-04fd-11eb-0706-7567eada0aed
# ╟─83b54bb4-04fd-11eb-3208-4162cb3eabc7
# ╠═d9fbed6e-0572-11eb-29bd-1d30ae286045
# ╟─4f386d5c-0573-11eb-084c-1758217d06f9
