### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ ea04bbf8-fdbd-11ea-3770-799225f55cf1
using Pkg, DrWatson

# ╔═╡ ea0507fc-fdbd-11ea-2d44-c73b1568b904
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 1e784e16-fdbb-11ea-3452-b39175136470
md"## Clip-05-42-43s.jl"

# ╔═╡ ea058a94-fdbd-11ea-1a0f-4df97a68e6ce
md"### Include snippets 5.42-5.43"

# ╔═╡ ea151e3a-fdbd-11ea-1b30-c9632c67c76d
begin
	n = 100
	df = DataFrame(:M => rand(Normal(), n),)
	df.NC = [rand(Normal(df[i, :M]), 1)[1] for i in 1:n]
	df.K = [rand(Normal(df[i, :NC] - df[i, :M]), 1)[1] for i in 1:n]
	scale!(df, [:K, :M, :NC])
end;

# ╔═╡ a4fb02e2-fdbf-11ea-19ea-494bf4c314f4
# Define the Stan language model

m5_7_A = "
data {
  int N;
  vector[N] K;
  vector[N] M;
  vector[N] NC;
}
parameters {
  real a;
  real bN;
  real bM;
  real aNC;
  real bMNC;
  real<lower=0> sigma;
  real<lower=0> sigma_NC;
}
model {
  // M -> K <- NC
  vector[N] mu = a + bN * NC + bM * M;
  a ~ normal( 0 , 0.2 );
  bN ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  K ~ normal( mu , sigma );
  // M -> NC
  vector[N] mu_NC = aNC + bMNC * M;
  aNC ~ normal( 0 , 0.2 );
  bMNC ~ normal( 0 , 0.5 );
  sigma_NC ~ exponential( 1 );
  NC ~ normal( mu_NC , sigma_NC );
}
";

# ╔═╡ a82dbcf0-fdbf-11ea-20da-d14c9729c1fc
begin
	m5_7_As = SampleModel("m5.7_A", m5_7_A);
	m5_7_A_data = Dict(
	  "N" => size(df, 1), 
	  "K" => df[:, :K_s],
	  "M" => df[:, :M_s],
	  "NC" => df[:, :NC_s] 
	);
	rc = stan_sample(m5_7_As, data=m5_7_A_data);
	dfa = read_samples(m5_7_As,; output_format=:dataframe);
end;

# ╔═╡ ea213eae-fdbd-11ea-17f4-1309b4bd31da
md"### Snippet 5.22"

# ╔═╡ ea21d698-fdbd-11ea-2ed9-cf100ceb1ef1
a_seq = range(-2, stop=2, length=100);

# ╔═╡ ea2cc4fe-fdbd-11ea-159f-3bad3c16d624
md"### Snippet 5.23"

# ╔═╡ ea33f1ac-fdbd-11ea-06e1-e98d93f9fa4b
m_sim, d_sim = simulate(dfa, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma]);

# ╔═╡ ea3ddca0-fdbd-11ea-1c96-2dc2f71a1fd5
md"### Snippet 5.24"

# ╔═╡ ea42399c-fdbd-11ea-3d76-435c05a5b479
begin
	p1 = plot(xlab="Manipulated M", ylab="Counterfactual K",
	  title="Total counterfactual effect of M on K")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array1 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array1[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array1[:, 1], -hpdi_array1[:, 2]))
end

# ╔═╡ ea49dbf2-fdbd-11ea-08a5-eb8b6c521a7b
begin
	p2 = plot(xlab="Manipulated M", ylab="Counterfactual NC",
	  title="Counterfactual effect of M on NC")
	plot!(a_seq, mean(m_sim, dims=1)[1, :], leg=false)
	hpdi_array2 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array2[i, :] =  hpdi(m_sim[i, :])
	end
	plot!(a_seq, mean(m_sim, dims=1)[1, :]; ribbon=(hpdi_array2[:, 1], -hpdi_array2[:, 2]))
end

# ╔═╡ ea51fbac-fdbd-11ea-2976-21fe61762e65
md"##### NC -> K"

# ╔═╡ ea5f64a4-fdbd-11ea-12ea-f5c71ba97e3c
begin
	nc_seq = range(-2, stop=2, length=100)
	nc_k_sim = zeros(size(dfa, 1), length(nc_seq))
	for j in 1:size(dfa, 1)
	  for i in 1:length(nc_seq)
		d = Normal(dfa[j, :a] + dfa[j, :bN] * nc_seq[i], dfa[j, :sigma])
		nc_k_sim[j, i] = rand(d, 1)[1]
	  end
	end
	p3 = plot(xlab="Manipulated NC", ylab="Counterfactual K",
	  title="Counterfactual effect of NC on K")
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :], leg=false)
	hpdi_array3 = zeros(length(nc_seq), 2)
	for i in 1:length(nc_seq)
	  hpdi_array3[i, :] =  hpdi(nc_k_sim[i, :])
	end
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :]; ribbon=(hpdi_array3[:, 1], -hpdi_array3[:, 2]))
end

# ╔═╡ ea617c6c-fdbd-11ea-210d-61484d081bd5
plot(p1, p2, p3, layout=(3, 1))

# ╔═╡ ea6d1c7a-fdbd-11ea-3998-91787bc3c0d9
md"## End of clip-05-42-43s.jl"

# ╔═╡ Cell order:
# ╟─1e784e16-fdbb-11ea-3452-b39175136470
# ╠═ea04bbf8-fdbd-11ea-3770-799225f55cf1
# ╠═ea0507fc-fdbd-11ea-2d44-c73b1568b904
# ╟─ea058a94-fdbd-11ea-1a0f-4df97a68e6ce
# ╠═ea151e3a-fdbd-11ea-1b30-c9632c67c76d
# ╠═a4fb02e2-fdbf-11ea-19ea-494bf4c314f4
# ╠═a82dbcf0-fdbf-11ea-20da-d14c9729c1fc
# ╟─ea213eae-fdbd-11ea-17f4-1309b4bd31da
# ╠═ea21d698-fdbd-11ea-2ed9-cf100ceb1ef1
# ╟─ea2cc4fe-fdbd-11ea-159f-3bad3c16d624
# ╠═ea33f1ac-fdbd-11ea-06e1-e98d93f9fa4b
# ╟─ea3ddca0-fdbd-11ea-1c96-2dc2f71a1fd5
# ╠═ea42399c-fdbd-11ea-3d76-435c05a5b479
# ╠═ea49dbf2-fdbd-11ea-08a5-eb8b6c521a7b
# ╟─ea51fbac-fdbd-11ea-2976-21fe61762e65
# ╠═ea5f64a4-fdbd-11ea-12ea-f5c71ba97e3c
# ╠═ea617c6c-fdbd-11ea-210d-61484d081bd5
# ╟─ea6d1c7a-fdbd-11ea-3998-91787bc3c0d9
