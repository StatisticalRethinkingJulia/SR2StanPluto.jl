### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 2de17794-0e8c-11eb-3203-5f2b7b5b7dd7
using Pkg, DrWatson

# ╔═╡ 2decc0c0-0e8c-11eb-0775-913c59e73d99
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
  using StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 04aef49e-0e8c-11eb-3495-3130c54c5cfd
md"## stan-priors.jl"

# ╔═╡ 2df79612-0e8c-11eb-1157-af213cb775a3
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 2e01794a-0e8c-11eb-0825-973992a079a9
m4_2 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ 2e0c33a8-0e8c-11eb-0605-737c37533499
m4_2s = SampleModel("p4_2s", m4_2);

# ╔═╡ 2e0d4f02-0e8c-11eb-0d77-d138cebf1967
prior4_2_data = Dict("N" => 0, "h" => []);

# ╔═╡ 2e17787e-0e8c-11eb-13d8-7b8eca9c0326
rc = stan_sample(m4_2s; data=prior4_2_data);

# ╔═╡ 2e1fed7e-0e8c-11eb-0996-eb641a2c95ae
if success(rc)
  priors4_2s = read_samples(m4_2s; output_format=:dataframe)
  Text(precis(priors4_2s; io=String))
end

# ╔═╡ 2e20929c-0e8c-11eb-0388-c34bd6d066e9
md"## End of stan-priors.jl"

# ╔═╡ Cell order:
# ╟─04aef49e-0e8c-11eb-3495-3130c54c5cfd
# ╠═2de17794-0e8c-11eb-3203-5f2b7b5b7dd7
# ╠═2decc0c0-0e8c-11eb-0775-913c59e73d99
# ╠═2df79612-0e8c-11eb-1157-af213cb775a3
# ╠═2e01794a-0e8c-11eb-0825-973992a079a9
# ╠═2e0c33a8-0e8c-11eb-0605-737c37533499
# ╠═2e0d4f02-0e8c-11eb-0d77-d138cebf1967
# ╠═2e17787e-0e8c-11eb-13d8-7b8eca9c0326
# ╠═2e1fed7e-0e8c-11eb-0996-eb641a2c95ae
# ╟─2e20929c-0e8c-11eb-0388-c34bd6d066e9
