### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ bf85a1c2-fb7d-11ea-11af-5b4f36a01cce
using Pkg, DrWatson

# ╔═╡ bf85db88-fb7d-11ea-0372-67375f0b8d43
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 0f7e4956-fb7c-11ea-04ac-47bc7bab44cf
md"## Clip-04-44-46s.jl"

# ╔═╡ bf865754-fb7d-11ea-0a35-8db33296670d
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df)
	mean_weight = mean(df.weight)
	df.weight_c = df.weight .- mean_weight
end

# ╔═╡ bf92904e-fb7d-11ea-3945-0768960719f4
PRECIS(df)

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

# ╔═╡ 1b7ee764-40ba-11eb-1a0d-5baaa48e2a1e
md"## snippet 4.44"

# ╔═╡ bf9fb904-fb7d-11ea-143a-3db8cf435c2c
md"##### Quadratic approximation."

# ╔═╡ 6a0f1080-408c-11eb-2fd8-e79d7c6c6d54
begin
	data = Dict(:N => length(df.height), :height => df.height, :weight => df.weight_c)
	init = Dict(:alpha => 170.0, :beta => 2.0, :sigma => 10.0)
	q4_3s, m4_3s, _ = quap("m4.3s", stan4_3; data, init)
end;

# ╔═╡ bfe69b8a-fb7d-11ea-10e6-150a3c3ef3eb
if !isnothing(q4_3s)
	quap4_3s_df = sample(q4_3s)
	PRECIS(quap4_3s_df)
end

# ╔═╡ bfc025d6-fb7d-11ea-124f-61d3a0d25e8a
md"##### Read the Stan samples."

# ╔═╡ bfc7a900-fb7d-11ea-088f-1f908ced09d8
if !isnothing(m4_3s)
	post4_3s = read_samples(m4_3s; output_format=:dataframe)
	part4_3s = Particles(post4_3s)
end

# ╔═╡ cf81c9e4-408c-11eb-3660-9dc540b1fe16
PRECIS(post4_3s)

# ╔═╡ 2a6816ce-40ba-11eb-0055-594078cf6eff
md"## snippet 4.45"

# ╔═╡ c2c711b4-40b9-11eb-20b3-8b316696df09
begin
	nms = [string(k) for k in keys(q4_3s.coef)]
	covm = NamedArray(Matrix(q4_3s.vcov), (nms, nms), ("Rows", "Cols"))
	covm
end

# ╔═╡ bfd4d4c2-fb7d-11ea-0995-8fcce3233153
md"### snippet 4.46"

# ╔═╡ bfd622b4-fb7d-11ea-2907-fd345097b670
if !isnothing(m4_3s)

	# Plot regression line using means and observations

	scatter(df.weight_c, df.height, lab="Observations",
	  ylab="height [cm]", xlab="weight[kg]", leg=:topleft)
	xi = -16.0:0.1:18.0
	yi = mean(post4_3s.alpha) .+ mean(post4_3s.beta)*xi;
	plot!(xi, yi, lab="Regression line")
end

# ╔═╡ bff6b6d2-fb7d-11ea-3ea8-e5d61fa1ebf7
md"## End of clip-04-44-46s.jl"

# ╔═╡ Cell order:
# ╟─0f7e4956-fb7c-11ea-04ac-47bc7bab44cf
# ╠═bf85a1c2-fb7d-11ea-11af-5b4f36a01cce
# ╠═bf85db88-fb7d-11ea-0372-67375f0b8d43
# ╠═bf865754-fb7d-11ea-0a35-8db33296670d
# ╠═bf92904e-fb7d-11ea-3945-0768960719f4
# ╟─bf932126-fb7d-11ea-3b65-5b36bcc7ac03
# ╠═bf9f151c-fb7d-11ea-3857-0f812f0b3ced
# ╟─1b7ee764-40ba-11eb-1a0d-5baaa48e2a1e
# ╟─bf9fb904-fb7d-11ea-143a-3db8cf435c2c
# ╠═6a0f1080-408c-11eb-2fd8-e79d7c6c6d54
# ╠═bfe69b8a-fb7d-11ea-10e6-150a3c3ef3eb
# ╟─bfc025d6-fb7d-11ea-124f-61d3a0d25e8a
# ╠═bfc7a900-fb7d-11ea-088f-1f908ced09d8
# ╠═cf81c9e4-408c-11eb-3660-9dc540b1fe16
# ╟─2a6816ce-40ba-11eb-0055-594078cf6eff
# ╠═c2c711b4-40b9-11eb-20b3-8b316696df09
# ╟─bfd4d4c2-fb7d-11ea-0995-8fcce3233153
# ╠═bfd622b4-fb7d-11ea-2907-fd345097b670
# ╟─bff6b6d2-fb7d-11ea-3ea8-e5d61fa1ebf7
