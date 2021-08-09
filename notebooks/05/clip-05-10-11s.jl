### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ ce85691e-fc77-11ea-0aee-df1ba52cecd7
using Pkg, DrWatson

# ╔═╡ ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ 9741f266-fc76-11ea-0689-cd04b7b16135
md"## Clip-05-10-11s.jl"

# ╔═╡ b9c3f450-fcdb-11ea-2ca9-27f5dbb73a98
md"##### The model m5.3s represents a regression of Divorce on both Marriage rate and MedianAgeMarriage and is defined as:"

# ╔═╡ aba487fe-fcdb-11ea-25e1-67c6f9596a16
md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bA ~ normal(0, 0.5);
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A + bM * M;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

# ╔═╡ c62fab76-fcdb-11ea-1b75-e71f5c77eccf
md"##### D (Divorce rate), M (Marriage rate) and A (MediumAgeMarriage) are all standardized."

# ╔═╡ ce861b20-fc77-11ea-0b79-8dd922420260
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
end

# ╔═╡ ce8df1ec-fc77-11ea-1c7d-ad620c19fbbd
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

# ╔═╡ 8a7c3e5c-8116-11eb-1911-b940b352dfc9
md"##### Result rethinking:"

# ╔═╡ 8a7c7662-8116-11eb-3540-1dea64d7eec6
rethinking = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bA    -0.57 0.11 -0.74 -0.39
sigma  0.79 0.08  0.66  0.91
";

# ╔═╡ 8a7d461c-8116-11eb-043e-ffb6bf7d0737
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

# ╔═╡ b7c70164-8116-11eb-0f7e-754d76c430ec
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

# ╔═╡ bdc8090a-8116-11eb-07c8-d343006e2d79
begin
	q5_2s, m5_2s, om = stan_quap("m5.2s", stan5_2; data)
	if !isnothing(q5_2s)
		quap5_2s_df = sample(q5_2s)
	end
	PRECIS(quap5_2s_df)
end

# ╔═╡ ce79d490-8116-11eb-0f1d-8d1719cf1e5b
stan5_3 = "
data {
  int N;
  vector[N] D;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + + bA * A + bM * M;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ e4731414-8116-11eb-1340-0f2a41529348
begin
	q5_3s, m5_3s, om5_3 = stan_quap("m5.3s", stan5_3; data, init)
	if !isnothing(q5_3s)
		quap5_3s_df = sample(q5_3s)
	end
	PRECIS(quap5_3s_df)
end

# ╔═╡ 47566d90-fcda-11ea-0662-8fa0dd0583c4
md"##### Normal estimates:"

# ╔═╡ ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
if !isnothing(m5_1s) &&!isnothing(m5_2s) && !isnothing(m5_3s) 
	(s1, p1) = plot_model_coef([m5_1s, m5_2s, m5_3s], [:bA, :bM]; 
		title="Particles (Normal) estimates")
	p1
end

# ╔═╡ cea73280-fc77-11ea-348f-8973a4e7a5d3
md"## End of clip-05-10-11s.jl"

# ╔═╡ Cell order:
# ╟─9741f266-fc76-11ea-0689-cd04b7b16135
# ╠═ce85691e-fc77-11ea-0aee-df1ba52cecd7
# ╠═ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
# ╟─b9c3f450-fcdb-11ea-2ca9-27f5dbb73a98
# ╟─aba487fe-fcdb-11ea-25e1-67c6f9596a16
# ╟─c62fab76-fcdb-11ea-1b75-e71f5c77eccf
# ╟─ce861b20-fc77-11ea-0b79-8dd922420260
# ╠═ce8df1ec-fc77-11ea-1c7d-ad620c19fbbd
# ╟─8a7c3e5c-8116-11eb-1911-b940b352dfc9
# ╠═8a7c7662-8116-11eb-3540-1dea64d7eec6
# ╠═8a7d461c-8116-11eb-043e-ffb6bf7d0737
# ╠═b7c70164-8116-11eb-0f7e-754d76c430ec
# ╠═bdc8090a-8116-11eb-07c8-d343006e2d79
# ╠═ce79d490-8116-11eb-0f1d-8d1719cf1e5b
# ╠═e4731414-8116-11eb-1340-0f2a41529348
# ╟─47566d90-fcda-11ea-0662-8fa0dd0583c4
# ╠═ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
# ╟─cea73280-fc77-11ea-348f-8973a4e7a5d3
