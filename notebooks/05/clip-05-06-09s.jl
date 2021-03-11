### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9f10e30a-fcec-11ea-1ca8-f1ad8754f845
using Pkg, DrWatson

# ╔═╡ 9f11214e-fcec-11ea-2002-6541f7abc779
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ e2e2c948-fceb-11ea-20e0-f19b598a9e90
md"## Clip-05-06-09s.jl"

# ╔═╡ dc15916e-81d1-11eb-3c67-f76875d8751e
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ 9f11aca4-fcec-11ea-0d60-2549341d0fc8
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

# ╔═╡ 9f1dddee-fcec-11ea-2328-dbd9ddc2be94
begin
	data = (N = size(df, 1), D = df.Divorce_s, A = df.MedianAgeMarriage_s,
		M = df.Marriage_s)
	init = (a=1.0, bA=1.0, bM=1.0, sigma=10.0)
	q5_2s, m5_2s, om5_2 = stan_quap("m5.2s", stan5_2; data, init)
	if !isnothing(q5_2s)
		quap5_2s_df = sample(q5_2s)
		PRECIS(quap5_2s_df)
	end
end

# ╔═╡ 9f27c84a-fcec-11ea-005e-97c59812d16e
# Rethinking results

rethinking_results = "
	  mean   sd  5.5% 94.5%
a     0.00 0.11 -0.17  0.17
bM    0.35 0.13  0.15  0.55
sigma 0.91 0.09  0.77  1.05
";

# ╔═╡ 9f284e50-fcec-11ea-3eec-4160f696255c
if !isnothing(q5_2s)
	begin
		title = "Divorce rate vs. Marriage rate" * "\nshowing sample and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			quap5_2s_df, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey]
		)
	end
end

# ╔═╡ 9f329860-fcec-11ea-012b-b59bc79f7336
md"## End of clip-05-06-10s.jl"

# ╔═╡ Cell order:
# ╟─e2e2c948-fceb-11ea-20e0-f19b598a9e90
# ╠═9f10e30a-fcec-11ea-1ca8-f1ad8754f845
# ╠═9f11214e-fcec-11ea-2002-6541f7abc779
# ╠═dc15916e-81d1-11eb-3c67-f76875d8751e
# ╠═9f11aca4-fcec-11ea-0d60-2549341d0fc8
# ╠═9f1dddee-fcec-11ea-2328-dbd9ddc2be94
# ╠═9f27c84a-fcec-11ea-005e-97c59812d16e
# ╠═9f284e50-fcec-11ea-3eec-4160f696255c
# ╟─9f329860-fcec-11ea-012b-b59bc79f7336
