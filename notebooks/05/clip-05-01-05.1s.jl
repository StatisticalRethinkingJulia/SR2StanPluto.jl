### A Pluto.jl notebook ###
# v0.12.13

using Markdown
using InteractiveUtils

# ╔═╡ a9bbd3ea-fc34-11ea-282a-43f4fc159d39
using Pkg, DrWatson

# ╔═╡ a9e16b46-fc34-11ea-36de-ef647e4e4f6f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 864e52fc-fc39-11ea-2c30-43e6b888bf60
include(projectdir("models", "05", "m5.2s.jl"))

# ╔═╡ feebbe4e-fc33-11ea-2ee7-d14f977c6497
md"## Clip-05-01-02s.jl"

# ╔═╡ a9e54766-fc34-11ea-1246-93a25f748d1d
md"### snippet 5.1"

# ╔═╡ 10471c94-fc55-11ea-0fec-656bd563d513
md"##### D (Divorce rate), A (MediumAgeMarriage) and M (Marriage rate) are all standardized."

# ╔═╡ a9f32456-fc34-11ea-3af8-c7e0de78a85d
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Divorce, :MedianAgeMarriage, :Marriage])
end;

# ╔═╡ 4d0ca900-fc53-11ea-0f6c-e7d09d775387
md"##### The model m5.1s represents a regression of Divorce on MedianAgeMarriage and is defined as:"

# ╔═╡ 25c70d5a-fc54-11ea-3910-a9276dc7b696
md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

# ╔═╡ b8ae47cc-01af-11eb-3cbd-a749b6e3d327
md"##### The Stan language model."

# ╔═╡ b5431248-01af-11eb-03ac-ed6a17e17e39
stan5_1 = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] D; // Outcome
	 vector[N] A; // Predictor
	}

	parameters {
	 real a; // Intercept
	 real bA; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  a ~ normal(0, 0.2);         // Priors
	  bA ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	  mu = a + bA * A;
	  D ~ normal(mu , sigma);   // Likelihood
	}
";

# ╔═╡ cbd5fe10-01af-11eb-055b-bd009d0dca55
begin
	m5_1s = SampleModel("m5.1s", stan5_1)
	m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s)
	rc5_1s = stan_sample(m5_1s, data=m5_1_data)
	success(rc5_1s) && (part5_1s = read_samples(m5_1s; output_format=:particles))
end

# ╔═╡ 9547a2a0-01c4-11eb-169c-17d6dbace4d9
md"##### Compare below figure with the corresponding figure in clip-05-01-05s.jl."

# ╔═╡ 07cfcaec-01c4-11eb-38b7-31dca6cafefb
if success(rc5_1s)
	begin

		# Plot regression line using means and observations

		post5_1s_df = read_samples(m5_1s; output_format=:dataframe)
		xi = -3.0:0.1:3.0
		plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
			title="Showing 50 regression lines")
		for i in 1:50
			local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
			plot!(xi, yi, color=:lightgrey, leg=false)
		end

		scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)

	end

end

# ╔═╡ 683093dc-fc54-11ea-3be9-fdad0a8812f6
md"##### The model m5.2s represents a regression of Divorce on Marriage and is defined as:"

# ╔═╡ 77cb9670-fc54-11ea-38fe-3b8c48e2ce09
md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

# ╔═╡ 3c3888ec-fc55-11ea-3542-c7df3ecc74b4
md"##### Both D (Divorce rate) and A (Marriage rate) are standardized."

# ╔═╡ aa064588-fc34-11ea-2153-59bc6c7f18a8
md"### snippet 5.2"

# ╔═╡ aa1005e6-fc34-11ea-08b5-635958beb6d7
std(df.MedianAgeMarriage)

# ╔═╡ aa1901d2-fc34-11ea-1d5b-df9e9eb109ec
if success(rc5_2s)

	# Compute quap approximation.

	quap5_1s_df = quap(post5_1s_df)
end

# ╔═╡ aa241f5e-fc34-11ea-21d5-1b03dfafd34f
md"##### Result rethinking:"

# ╔═╡ aa2a005e-fc34-11ea-09ab-290a8d6b6a9a
rethinking = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bA    -0.57 0.11 -0.74 -0.39
sigma  0.79 0.08  0.66  0.91
";

# ╔═╡ aa36edc8-fc34-11ea-3701-434917b6f7a3
if success(rc5_1s)

	# Plot regression line D on A

	title1 = "Divorce rate vs. median age at marriage" * "\nshowing predicted and quantile range"
	fig1 = plotbounds(
		df, :MedianAgeMarriage, :Divorce,
		post5_1s_df, [:a, :bA, :sigma];
		title=title1,
		colors=[:lightblue, :darkgrey]
	)
end

# ╔═╡ c206cdc6-fc55-11ea-2835-71c3067485f8
if success(rc5_2s)

	# Compute quap approximation.

	post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
	quap5_2s = quap(post5_2s_df)
end

# ╔═╡ 279006d8-fc56-11ea-2792-d1c2678a1e08
if success(rc5_2s)

	# Plot regression line D on M


	title2 = "Divorce rate vs. marriage rate" * "\nshowing predicted and hpdi range"
	fig2 = plotbounds(
		df, :Marriage, :Divorce,
		post5_2s_df, [:a, :bM, :sigma];
		title=title2,
		colors=[:lightblue, :darkgrey]
	)

end

# ╔═╡ 41bc0716-fc56-11ea-1cfe-3db82349a2d2
	plot(fig2, fig1, layout=(1,2), title="")

# ╔═╡ aa37b78a-fc34-11ea-11e5-7d1ef7bdf603
md"## End of clip-05-01-02s.jl"

# ╔═╡ Cell order:
# ╟─feebbe4e-fc33-11ea-2ee7-d14f977c6497
# ╠═a9bbd3ea-fc34-11ea-282a-43f4fc159d39
# ╠═a9e16b46-fc34-11ea-36de-ef647e4e4f6f
# ╟─a9e54766-fc34-11ea-1246-93a25f748d1d
# ╟─10471c94-fc55-11ea-0fec-656bd563d513
# ╠═a9f32456-fc34-11ea-3af8-c7e0de78a85d
# ╟─4d0ca900-fc53-11ea-0f6c-e7d09d775387
# ╟─25c70d5a-fc54-11ea-3910-a9276dc7b696
# ╟─b8ae47cc-01af-11eb-3cbd-a749b6e3d327
# ╠═b5431248-01af-11eb-03ac-ed6a17e17e39
# ╠═cbd5fe10-01af-11eb-055b-bd009d0dca55
# ╟─9547a2a0-01c4-11eb-169c-17d6dbace4d9
# ╠═07cfcaec-01c4-11eb-38b7-31dca6cafefb
# ╟─683093dc-fc54-11ea-3be9-fdad0a8812f6
# ╟─77cb9670-fc54-11ea-38fe-3b8c48e2ce09
# ╟─3c3888ec-fc55-11ea-3542-c7df3ecc74b4
# ╠═864e52fc-fc39-11ea-2c30-43e6b888bf60
# ╟─aa064588-fc34-11ea-2153-59bc6c7f18a8
# ╠═aa1005e6-fc34-11ea-08b5-635958beb6d7
# ╠═aa1901d2-fc34-11ea-1d5b-df9e9eb109ec
# ╟─aa241f5e-fc34-11ea-21d5-1b03dfafd34f
# ╠═aa2a005e-fc34-11ea-09ab-290a8d6b6a9a
# ╠═aa36edc8-fc34-11ea-3701-434917b6f7a3
# ╠═c206cdc6-fc55-11ea-2835-71c3067485f8
# ╠═279006d8-fc56-11ea-2792-d1c2678a1e08
# ╠═41bc0716-fc56-11ea-1cfe-3db82349a2d2
# ╟─aa37b78a-fc34-11ea-11e5-7d1ef7bdf603
