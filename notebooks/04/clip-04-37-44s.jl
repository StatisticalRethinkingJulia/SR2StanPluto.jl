### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ bf85a1c2-fb7d-11ea-11af-5b4f36a01cce
using Pkg, DrWatson

# ╔═╡ bf85db88-fb7d-11ea-0372-67375f0b8d43
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 0f7e4956-fb7c-11ea-04ac-47bc7bab44cf
md"## Clip-04-37-44s.jl"

# ╔═╡ bf865754-fb7d-11ea-0a35-8db33296670d
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df)
	mean_weight = mean(df.weight)
	df.weight_c = df.weight .- mean_weight
end

# ╔═╡ bf92904e-fb7d-11ea-3945-0768960719f4
Text(precis(df; io=String))

# ╔═╡ bf932126-fb7d-11ea-3b65-5b36bcc7ac03
md"##### Define the Stan language model."

# ╔═╡ bf9f151c-fb7d-11ea-3857-0f812f0b3ced
stan4_3 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] height; // Predictor
 vector[N] weight; // Outcome
}

parameters {
 real alpha; // Intercept
 real beta; // Slope (regression coefficients)
 real < lower = 0 > sigma; // Error SD
}

model {
 height ~ normal(alpha + weight * beta , sigma);
}
";

# ╔═╡ bf9fb904-fb7d-11ea-143a-3db8cf435c2c
md"##### Define the SampleModel."

# ╔═╡ bfab2758-fb7d-11ea-3606-e52aad817697
m4_3s = SampleModel("m4.3s", stan4_3);

# ╔═╡ bfb20fdc-fb7d-11ea-3ae1-57790717c9fb
md"##### Input data."

# ╔═╡ bfb74662-fb7d-11ea-0423-0f1f2c5c5e24
m4_3_data = Dict("N" => length(df.height), "height" => df.height, "weight" => df.weight_c);

# ╔═╡ bfc025d6-fb7d-11ea-124f-61d3a0d25e8a
md"##### Sample using stan_sample."

# ╔═╡ bfc0d1b6-fb7d-11ea-3800-0f8e8e96f509
rc4_3s = stan_sample(m4_3s, data=m4_3_data);

# ╔═╡ bfc7a900-fb7d-11ea-088f-1f908ced09d8
if success(rc4_3s)

	# Describe the draws
	
	post4_3s = read_samples(m4_3s; output_format=:dataframe)
	part4_3s = Particles(post4_3s)
end

# ╔═╡ bfd4d4c2-fb7d-11ea-0995-8fcce3233153
md"### snippet 4.37"

# ╔═╡ bfd622b4-fb7d-11ea-2907-fd345097b670
if success(rc4_3s)

	# Plot regression line using means and observations

	scatter(df.weight_c, df.height, lab="Observations",
	  ylab="height [cm]", xlab="weight[kg]")
	xi = -16.0:0.1:18.0
	yi = mean(post4_3s.alpha) .+ mean(post4_3s.beta)*xi;
	plot!(xi, yi, lab="Regression line")
end

# ╔═╡ bfde88b6-fb7d-11ea-1833-c36f65d47841
md"### snippet 4.44"

# ╔═╡ bfe69b8a-fb7d-11ea-10e6-150a3c3ef3eb
if success(rc4_3s)

	quap4_3s = quap(post4_3s)
end

# ╔═╡ bfee7d82-fb7d-11ea-21a3-651b8574029b
plot(plot(quap4_3s.alpha, lab="alpha"), plot(quap4_3s.beta, lab="beta"), layout=(2, 1))

# ╔═╡ bff6b6d2-fb7d-11ea-3ea8-e5d61fa1ebf7
md"## End of clip-04-37-44s.jl"

# ╔═╡ Cell order:
# ╟─0f7e4956-fb7c-11ea-04ac-47bc7bab44cf
# ╠═bf85a1c2-fb7d-11ea-11af-5b4f36a01cce
# ╠═bf85db88-fb7d-11ea-0372-67375f0b8d43
# ╠═bf865754-fb7d-11ea-0a35-8db33296670d
# ╠═bf92904e-fb7d-11ea-3945-0768960719f4
# ╟─bf932126-fb7d-11ea-3b65-5b36bcc7ac03
# ╠═bf9f151c-fb7d-11ea-3857-0f812f0b3ced
# ╟─bf9fb904-fb7d-11ea-143a-3db8cf435c2c
# ╠═bfab2758-fb7d-11ea-3606-e52aad817697
# ╟─bfb20fdc-fb7d-11ea-3ae1-57790717c9fb
# ╠═bfb74662-fb7d-11ea-0423-0f1f2c5c5e24
# ╟─bfc025d6-fb7d-11ea-124f-61d3a0d25e8a
# ╠═bfc0d1b6-fb7d-11ea-3800-0f8e8e96f509
# ╠═bfc7a900-fb7d-11ea-088f-1f908ced09d8
# ╟─bfd4d4c2-fb7d-11ea-0995-8fcce3233153
# ╠═bfd622b4-fb7d-11ea-2907-fd345097b670
# ╟─bfde88b6-fb7d-11ea-1833-c36f65d47841
# ╠═bfe69b8a-fb7d-11ea-10e6-150a3c3ef3eb
# ╠═bfee7d82-fb7d-11ea-21a3-651b8574029b
# ╟─bff6b6d2-fb7d-11ea-3ea8-e5d61fa1ebf7
