### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ cd892ad4-fdba-11ea-2b87-41c0d68c6a27
using Pkg, DrWatson

# ╔═╡ cd89683c-fdba-11ea-0ff4-3d500f086774
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ f2c5b4bc-fdb9-11ea-1f2f-13802209834b
md"## Clip-05-41s.jl"

# ╔═╡ cd89eb2e-fdba-11ea-3689-f933b28ab670
begin
	df1 = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df1 = filter(row -> !(row[:neocortex_perc] == "NA"), df1);

	df = DataFrame()
	df[!, :NC] = parse.(Float64, df1[:, :neocortex_perc])
	df[!, :M] = log.(df1[:, :mass])
	df[!, :K] = df1[:, :kcal_per_g]
	scale!(df, [:K, :NC, :M])
end;

# ╔═╡ 2f8bd97c-fdbe-11ea-0855-55a321d0e010
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

# ╔═╡ 664db714-fdbe-11ea-20ba-b18074f27490
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

# ╔═╡ cd977756-fdba-11ea-0b92-79d3b2439454
md"### Snippet 5.22"

# ╔═╡ cda28e98-fdba-11ea-2e23-95ab5e6d382a
a_seq = range(-2, stop=2, length=100)

# ╔═╡ cda9c6f4-fdba-11ea-359b-a5464143c8a6
m_sim, d_sim = simulate(dfa, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma]);

# ╔═╡ cdab170c-fdba-11ea-1c9b-17e26c5d30f5
md"### Snippet 5.24"

# ╔═╡ cdb7171e-fdba-11ea-350c-f3cc664af8d9
begin
	plot(xlab="Manipulated M", ylab="Counterfactual K",
		title="Total counterfactual effect of M on K")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

# ╔═╡ cdb7b26e-fdba-11ea-3abb-2714f92bb8c8
md"## End of clip-05-41s.jl"

# ╔═╡ Cell order:
# ╠═f2c5b4bc-fdb9-11ea-1f2f-13802209834b
# ╠═cd892ad4-fdba-11ea-2b87-41c0d68c6a27
# ╠═cd89683c-fdba-11ea-0ff4-3d500f086774
# ╠═cd89eb2e-fdba-11ea-3689-f933b28ab670
# ╠═2f8bd97c-fdbe-11ea-0855-55a321d0e010
# ╠═664db714-fdbe-11ea-20ba-b18074f27490
# ╟─cd977756-fdba-11ea-0b92-79d3b2439454
# ╠═cda28e98-fdba-11ea-2e23-95ab5e6d382a
# ╠═cda9c6f4-fdba-11ea-359b-a5464143c8a6
# ╟─cdab170c-fdba-11ea-1c9b-17e26c5d30f5
# ╠═cdb7171e-fdba-11ea-350c-f3cc664af8d9
# ╟─cdb7b26e-fdba-11ea-3abb-2714f92bb8c8
