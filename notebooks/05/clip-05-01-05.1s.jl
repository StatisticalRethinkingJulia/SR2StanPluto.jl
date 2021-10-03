### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ a9bbd3ea-fc34-11ea-282a-43f4fc159d39
using Pkg, DrWatson

# ╔═╡ a9e16b46-fc34-11ea-36de-ef647e4e4f6f
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
end

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
stan5_1_priors = "
	data {
	 int N; // Sample size
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

# ╔═╡ db59a030-423e-11eb-3eb2-5d1f7d3dd0f5
begin
	m5_1s_priors = SampleModel("m5.1.priors", stan5_1_priors)
	rc5_1s_priors = stan_sample(m5_1s_priors;
		data = Dict("N" => 0, "D" => [], "A" => []))
	success(rc5_1s_priors) && 
		(part5_1s_priors = read_samples(m5_1s_priors, :particles))
end

# ╔═╡ 55ef3d46-423f-11eb-1d83-55276a40b702
if success(rc5_1s_priors)
	priors5_1s_df = read_samples(m5_1s_priors, :dataframe)
	xi = -3.0:0.1:3.0
	plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
		title="Showing 50 regression lines")
	for i in 1:50
		local yi = mean(priors5_1s_df[i, :a]) .+ priors5_1s_df[i, :bA] .* xi
		plot!(xi, yi, color=:lightgrey, leg=false)
	end
	scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)
end

# ╔═╡ fad134cc-423f-11eb-3398-b7d0e22aad9c
stan5_1 = "
	data {
	 int N; // Sample size
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

# ╔═╡ aa241f5e-fc34-11ea-21d5-1b03dfafd34f
md"##### Result rethinking:"

# ╔═╡ aa2a005e-fc34-11ea-09ab-290a8d6b6a9a
rethinking = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bA    -0.57 0.11 -0.74 -0.39
sigma  0.79 0.08  0.66  0.91
";

# ╔═╡ cbd5fe10-01af-11eb-055b-bd009d0dca55
begin
	data = (N = size(df, 1), D = df.Divorce_s, A = df.MedianAgeMarriage_s,
		M = df.Marriage_s)
	init = (a=1.0, bA=1.0, bM=1.0, sigma=10.0)
	q5_1s, m5_1s, om5_1s = stan_quap("m5.1s", stan5_1; data, init)
	if !isnothing(q5_1s)
		quap5_1s_df = sample(q5_1s)
		PRECIS(quap5_1s_df)
	end
end

# ╔═╡ 9547a2a0-01c4-11eb-169c-17d6dbace4d9
md"##### Compare below figure with the corresponding figure in clip-05-01-05s.jl."

# ╔═╡ 07cfcaec-01c4-11eb-38b7-31dca6cafefb
if !isnothing(m5_1s)
	post5_1s_df = read_samples(m5_1s, :dataframe)
	plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
		title="Showing 50 regression lines")
	for i in 1:50
		local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
		plot!(xi, yi, color=:lightgrey, leg=false)
	end
	scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)
end

# ╔═╡ aa064588-fc34-11ea-2153-59bc6c7f18a8
md"### snippet 5.2"

# ╔═╡ aa36edc8-fc34-11ea-3701-434917b6f7a3
if !isnothing(q5_1s)

	# Plot regression line D on A

	title1 = "Divorce rate vs. median age at marriage" *
		"\nshowing predicted and quantile range"
	fig1 = plotbounds(
		df, :MedianAgeMarriage, :Divorce,
		quap5_1s_df, [:a, :bA, :sigma];
		title=title1,
		colors=[:lightblue, :darkgrey]
	)
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

# ╔═╡ 864e52fc-fc39-11ea-2c30-43e6b888bf60
stan5_2 = "
data {
  int N;
  vector[N] D;
  vector[N] M;
}
parameters {
  real a;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bM * M;
  a ~ normal( 0 , 0.2 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ 4a4b1284-80f7-11eb-01a4-452b4e2597e7
begin
	q5_2s, m5_2s, om = stan_quap("m5.2s", stan5_2; data)
	if !isnothing(q5_2s)
		quap5_2s_df = sample(q5_2s)
	end
	PRECIS(quap5_2s_df)
end

# ╔═╡ c206cdc6-fc55-11ea-2835-71c3067485f8
if !isnothing(m5_2s)
	post5_2s_df = read_samples(m5_2s, :dataframe)
	PRECIS(post5_2s_df)
end

# ╔═╡ 279006d8-fc56-11ea-2792-d1c2678a1e08
if !isnothing(q5_2s)

	# Plot regression line D on M

	title2 = "Divorce rate vs. marriage rate" * "\nshowing predicted and hpdi range"
	fig2 = plotbounds(
		df, :Marriage, :Divorce,
		quap5_2s_df, [:a, :bM, :sigma];
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
# ╠═db59a030-423e-11eb-3eb2-5d1f7d3dd0f5
# ╠═55ef3d46-423f-11eb-1d83-55276a40b702
# ╠═fad134cc-423f-11eb-3398-b7d0e22aad9c
# ╟─aa241f5e-fc34-11ea-21d5-1b03dfafd34f
# ╠═aa2a005e-fc34-11ea-09ab-290a8d6b6a9a
# ╠═cbd5fe10-01af-11eb-055b-bd009d0dca55
# ╟─9547a2a0-01c4-11eb-169c-17d6dbace4d9
# ╠═07cfcaec-01c4-11eb-38b7-31dca6cafefb
# ╟─aa064588-fc34-11ea-2153-59bc6c7f18a8
# ╠═aa36edc8-fc34-11ea-3701-434917b6f7a3
# ╟─683093dc-fc54-11ea-3be9-fdad0a8812f6
# ╟─77cb9670-fc54-11ea-38fe-3b8c48e2ce09
# ╟─3c3888ec-fc55-11ea-3542-c7df3ecc74b4
# ╠═864e52fc-fc39-11ea-2c30-43e6b888bf60
# ╠═4a4b1284-80f7-11eb-01a4-452b4e2597e7
# ╠═c206cdc6-fc55-11ea-2835-71c3067485f8
# ╠═279006d8-fc56-11ea-2792-d1c2678a1e08
# ╠═41bc0716-fc56-11ea-1cfe-3db82349a2d2
# ╟─aa37b78a-fc34-11ea-11e5-7d1ef7bdf603
