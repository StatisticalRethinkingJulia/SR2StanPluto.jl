### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 98601dc8-fd46-11ea-2560-e762bfd97ed7
using Pkg, DrWatson

# ╔═╡ 986050d6-fd46-11ea-26b6-7f618638f1ab
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ f7be0558-fd45-11ea-2cb4-c9f411d2e55e
md"## Clip-05-25-27s.jl"

# ╔═╡ 986d9d7c-fd46-11ea-305a-915f690d446a
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame)
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ 946d9a5a-833e-11eb-2c8e-452d18e7c2db
stan5_3_A = "
data {
  int N;
  vector[N] divorce_s;
  vector[N] marriage_s;
  vector[N] medianagemarriage_s;
}
parameters {
  real a;
  real bA;
  real bM;
  real aM;
  real bAM;
  real<lower=0> sigma;
  real<lower=0> sigma_M;
}
model {
  // A -> D <- M
  vector[N] mu = a + bA * medianagemarriage_s + bM * marriage_s;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  divorce_s ~ normal( mu , sigma );
  // A -> M
  vector[N] mu_M = aM + bAM * medianagemarriage_s;
  aM ~ normal( 0 , 0.2 );
  bAM ~ normal( 0 , 0.5 );
  sigma_M ~ exponential( 1 );
  marriage_s ~ normal( mu_M , sigma_M );
}
";

# ╔═╡ 946dcbb0-833e-11eb-25c9-af83df7acab1
begin
	data = (N = size(df, 1), divorce_s = df.Divorce_s,
	  marriage_s = df.Marriage_s, medianagemarriage_s = df.MedianAgeMarriage_s)
	init = (a = 0.0, bM = 0.0, bA = -1.0, sigma = 1.0,
		aM = 0.0, bAM = -1.0, sigma_m = 1.0)
	q5_3_As, m5_3_As, o5_3_As = stan_quap("m5.3_A", stan5_3_A; data, init)
	if !isnothing(q5_3_As)
		quap5_3_As_df = sample(q5_3_As)
	end
	if !isnothing(m5_3_As)
	  post5_3_As_df = read_samples(m5_3_As; output_format=:dataframe)
	  PRECIS(post5_3_As_df)
	end
end

# ╔═╡ 946eb598-833e-11eb-2df5-5f66fa9a18d7
# Rethinking results
rethinking_results = "
           mean   sd  5.5% 94.5%
  a        0.00 0.10 -0.16  0.16
  bM      -0.07 0.15 -0.31  0.18
  bA      -0.61 0.15 -0.85 -0.37
  sigma    0.79 0.08  0.66  0.91
  aM       0.00 0.09 -0.14  0.14
  bAM     -0.69 0.10 -0.85 -0.54
  sigma_M  0.68 0.07  0.57  0.79
";

# ╔═╡ 948f1e3c-833e-11eb-391d-6b4ec346d46c
if !isnothing(q5_3_As)
		PRECIS(quap5_3_As_df)
	end

# ╔═╡ 9877c52c-fd46-11ea-293f-3d07c0cd6734
md"##### Rethinking results"

# ╔═╡ b9af5a04-fd49-11ea-07ba-fb61574aed90
part5_3_As = read_samples(m5_3_As; output_format=:particles)

# ╔═╡ 988ca05a-fd46-11ea-2ae3-910f7baa2b3f
md"## Snippet 5.25"

# ╔═╡ c79668d4-fd48-11ea-0cea-838eb6be744c
a_seq = range(-2, stop=2, length=100)

# ╔═╡ 988d33a8-fd46-11ea-27e5-7ba54e7b04fa
md"## Snippet 5.26"

# ╔═╡ e46cd1dc-fd48-11ea-0802-4d13a4981a23
begin
	m_sim = zeros(size(post5_3_As_df, 1), length(a_seq))
end;

# ╔═╡ 9899e134-fd46-11ea-0499-b94859cad8d1
for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.aM[j] + part5_3_As.bAM[j]*a_seq[i], part5_3_As.sigma_M[j])
    m_sim[j, i] = rand(d, 1)[1]
  end
end

# ╔═╡ 98a1fc3e-fd46-11ea-12f3-81a21baa6353
md"## Snippet 5.27"

# ╔═╡ eee2e318-fd48-11ea-2433-e1f6e65a082a
d_sim = zeros(size(post5_3_As_df, 1), length(a_seq));

# ╔═╡ 98a9de04-fd46-11ea-1a1b-b7512b456dc6
for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.a[j] + part5_3_As.bA[j]*a_seq[i] + part5_3_As.bM[j]*m_sim[j, i], part5_3_As.sigma[j])
    d_sim[j, i] = rand(d, 1)[1]
  end
end

# ╔═╡ 98ac248e-fd46-11ea-37ca-fbce7e1a8203
begin
	plot(xlab="Manipulated A", ylab="Counterfactual D",
		title="Total counterfactual effect of A on D")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

# ╔═╡ 98d0d7e8-fd46-11ea-02d8-191f0f81da25
md"## End of clip-05-25-27s.jl"

# ╔═╡ Cell order:
# ╟─f7be0558-fd45-11ea-2cb4-c9f411d2e55e
# ╠═98601dc8-fd46-11ea-2560-e762bfd97ed7
# ╠═986050d6-fd46-11ea-26b6-7f618638f1ab
# ╠═986d9d7c-fd46-11ea-305a-915f690d446a
# ╠═946d9a5a-833e-11eb-2c8e-452d18e7c2db
# ╠═946dcbb0-833e-11eb-25c9-af83df7acab1
# ╠═946eb598-833e-11eb-2df5-5f66fa9a18d7
# ╠═948f1e3c-833e-11eb-391d-6b4ec346d46c
# ╟─9877c52c-fd46-11ea-293f-3d07c0cd6734
# ╠═b9af5a04-fd49-11ea-07ba-fb61574aed90
# ╟─988ca05a-fd46-11ea-2ae3-910f7baa2b3f
# ╠═c79668d4-fd48-11ea-0cea-838eb6be744c
# ╠═988d33a8-fd46-11ea-27e5-7ba54e7b04fa
# ╠═e46cd1dc-fd48-11ea-0802-4d13a4981a23
# ╠═9899e134-fd46-11ea-0499-b94859cad8d1
# ╟─98a1fc3e-fd46-11ea-12f3-81a21baa6353
# ╠═eee2e318-fd48-11ea-2433-e1f6e65a082a
# ╠═98a9de04-fd46-11ea-1a1b-b7512b456dc6
# ╠═98ac248e-fd46-11ea-37ca-fbce7e1a8203
# ╟─98d0d7e8-fd46-11ea-02d8-191f0f81da25
