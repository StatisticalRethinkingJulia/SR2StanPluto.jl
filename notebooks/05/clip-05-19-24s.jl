### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 55da2efe-fd40-11ea-1fb2-237b206602b5
using Pkg, DrWatson

# ╔═╡ 55da724c-fd40-11ea-3868-3baa56009723
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ c46bb522-fd3b-11ea-1165-63af86a6f974
md"## Clip-05-19-24s.jl"

# ╔═╡ 788c3970-833b-11eb-3e93-93e43770b0fd
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame)
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end

# ╔═╡ 55e74cfe-fd40-11ea-20b3-1519e2e34159
md"##### Include snippets 5.19-5.21."

# ╔═╡ 55e7d3f6-fd40-11ea-14c5-21a0ef390e6d
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

# ╔═╡ f6fe6174-82a1-11eb-04bb-3be618429897
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
	  post5_3_As_df = read_samples(m5_3_As, :dataframe)
	  PRECIS(post5_3_As_df)
	end
end

# ╔═╡ 55f30276-fd40-11ea-3e70-d1600cb0f556
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

# ╔═╡ d02e57a0-82a1-11eb-0305-e71ad0138683
	if !isnothing(q5_3_As)
		PRECIS(quap5_3_As_df)
	end

# ╔═╡ 55fefeaa-fd40-11ea-2c88-a910f049dcf0
md"## Snippet 5.22"

# ╔═╡ 55fff1b6-fd40-11ea-38e0-3b694162f66e
a_seq = range(-2, stop=2, length=100);

# ╔═╡ 560a4aa6-fd40-11ea-1103-7191fff677fb
md"## Snippet 5.23"

# ╔═╡ 560dcb42-fd40-11ea-0b2e-f14e70a7425a
begin
	m_sim, d_sim = simulate(post5_3_As_df, [:aM, :bAM, :sigma_M],
		a_seq, [:bM, :sigma])
end;

# ╔═╡ 5618ec0c-fd40-11ea-3a0f-85fb3e33f1b1
md"## Snippet 5.24"

# ╔═╡ 5621e8fc-fd40-11ea-2f52-095b7196c40c
begin
	fig1 = plot(xlab="Manipulated A", ylab="Counterfactual D",
		title="Total counterfactual effect of A on D")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

# ╔═╡ 56236592-fd40-11ea-2be2-b9b04f0ce30c
begin
	fig2 = plot(xlab="Manipulated A", ylab="Counterfactual M",
		title="Counterfactual effect of A on M")
	plot!(a_seq, mean(m_sim, dims=1)[1, :], leg=false)
	hpdi_array1 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array1[i, :] =  hpdi(m_sim[i, :])
	end
	plot!(a_seq, mean(m_sim, dims=1)[1, :]; ribbon=(hpdi_array1[:, 1], -hpdi_array1[:, 2]))
end

# ╔═╡ 5631855a-fd40-11ea-173a-a187c5976832
md"##### M -> D"

# ╔═╡ 56339584-fd40-11ea-3c75-4f679d500b1c
begin
	m_seq = range(-2, stop=2, length=100)
	md_sim = zeros(size(post5_3_As_df, 1), length(m_seq))
	for j in 1:size(post5_3_As_df, 1)
		for i in 1:length(m_seq)
			d = Normal(post5_3_As_df[j, :a] + post5_3_As_df[j, :bM] * m_seq[i], post5_3_As_df[j, :sigma])
			md_sim[j, i] = rand(d, 1)[1]
		end
	end
	fig3 = plot(xlab="Manipulated M", ylab="Counterfactual D",
		title="Counterfactual effect of M on D")
	plot!(m_seq, mean(md_sim, dims=1)[1, :], leg=false)
	hpdi_array2 = zeros(length(m_seq), 2)
	for i in 1:length(m_seq)
		hpdi_array2[i, :] =  hpdi(md_sim[i, :])
	end
	plot!(m_seq, mean(md_sim, dims=1)[1, :]; ribbon=(hpdi_array2[:, 1], -hpdi_array2[:, 2]))
end

# ╔═╡ 563b3f8c-fd40-11ea-1d4b-3fc4eec893fa
plot(fig1, fig2, fig3, layout=(3, 1))

# ╔═╡ 56426262-fd40-11ea-22a7-5bbc6089cb07
md"## End of clip-05-19-24s.jl"

# ╔═╡ Cell order:
# ╟─c46bb522-fd3b-11ea-1165-63af86a6f974
# ╠═55da2efe-fd40-11ea-1fb2-237b206602b5
# ╠═55da724c-fd40-11ea-3868-3baa56009723
# ╠═788c3970-833b-11eb-3e93-93e43770b0fd
# ╟─55e74cfe-fd40-11ea-20b3-1519e2e34159
# ╠═55e7d3f6-fd40-11ea-14c5-21a0ef390e6d
# ╠═f6fe6174-82a1-11eb-04bb-3be618429897
# ╠═55f30276-fd40-11ea-3e70-d1600cb0f556
# ╠═d02e57a0-82a1-11eb-0305-e71ad0138683
# ╟─55fefeaa-fd40-11ea-2c88-a910f049dcf0
# ╠═55fff1b6-fd40-11ea-38e0-3b694162f66e
# ╟─560a4aa6-fd40-11ea-1103-7191fff677fb
# ╠═560dcb42-fd40-11ea-0b2e-f14e70a7425a
# ╟─5618ec0c-fd40-11ea-3a0f-85fb3e33f1b1
# ╠═5621e8fc-fd40-11ea-2f52-095b7196c40c
# ╠═56236592-fd40-11ea-2be2-b9b04f0ce30c
# ╟─5631855a-fd40-11ea-173a-a187c5976832
# ╠═56339584-fd40-11ea-3c75-4f679d500b1c
# ╠═563b3f8c-fd40-11ea-1d4b-3fc4eec893fa
# ╟─56426262-fd40-11ea-22a7-5bbc6089cb07
