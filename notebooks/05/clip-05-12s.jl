### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ ce85691e-fc77-11ea-0aee-df1ba52cecd7
using Pkg, DrWatson

# ╔═╡ ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 9741f266-fc76-11ea-0689-cd04b7b16135
md"## Clip-05-12s.jl"

# ╔═╡ 801cac68-6c7c-11eb-311d-83e238b758db
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
end

# ╔═╡ 971ee062-6c7b-11eb-2d51-450ed07075d3
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
  a ~ normal(0, 0.2);         //Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A;
  D ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ e6c4408a-6c7b-11eb-1fe4-4fcd55165777
begin
	m5_1s = SampleModel("m5.1s", stan5_1)
	rc5_1s = stan_sample(m5_1s; data);
end;

# ╔═╡ 2bfba814-6c7c-11eb-1263-a15856f0b3ca
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

# ╔═╡ d4dc01a4-6c7c-11eb-1a08-319bd06eac78
begin
	m5_2s = SampleModel("m5.2", stan5_2);
	rc5_2s = stan_sample(m5_2s; data);
end;

# ╔═╡ 9a044bca-6c7c-11eb-29f0-837204a47e3b
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

# ╔═╡ 331b4950-6c7d-11eb-2103-09042938f193
begin
	m5_3s = SampleModel("m5.3", stan5_3);
	rc5_3s = stan_sample(m5_3s; data)
end;

# ╔═╡ 47566d90-fcda-11ea-0662-8fa0dd0583c4
md"##### Normal estimates:"

# ╔═╡ ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
if success(rc5_1s) && success(rc5_2s) && success(rc5_3s)
	(s1, p1) = plot_model_coef([m5_1s, m5_2s, m5_3s], [:bA, :bM]; 
		title="Coefficient estimates")
	p1
end

# ╔═╡ b04e701c-fcd9-11ea-38ce-414484022e20
s1

# ╔═╡ cea73280-fc77-11ea-348f-8973a4e7a5d3
md"## End of clip-05-12s.jl"

# ╔═╡ Cell order:
# ╟─9741f266-fc76-11ea-0689-cd04b7b16135
# ╠═ce85691e-fc77-11ea-0aee-df1ba52cecd7
# ╠═ce85a7b2-fc77-11ea-2bec-0d7f0af3c59b
# ╠═801cac68-6c7c-11eb-311d-83e238b758db
# ╠═971ee062-6c7b-11eb-2d51-450ed07075d3
# ╠═e6c4408a-6c7b-11eb-1fe4-4fcd55165777
# ╠═2bfba814-6c7c-11eb-1263-a15856f0b3ca
# ╠═d4dc01a4-6c7c-11eb-1a08-319bd06eac78
# ╠═9a044bca-6c7c-11eb-29f0-837204a47e3b
# ╠═331b4950-6c7d-11eb-2103-09042938f193
# ╟─47566d90-fcda-11ea-0662-8fa0dd0583c4
# ╠═ce8e68c0-fc77-11ea-30eb-3fcbdd292d2c
# ╠═b04e701c-fcd9-11ea-38ce-414484022e20
# ╟─cea73280-fc77-11ea-348f-8973a4e7a5d3
