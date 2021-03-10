### A Pluto.jl notebook ###
# v0.12.21

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
begin
	m4_2s = SampleModel("p4_2s", m4_2)
	data = (N = 0, h = [])
	rc4_2s = stan_sample(m4_2s; data)
end;

# ╔═╡ 2e1fed7e-0e8c-11eb-0996-eb641a2c95ae
if success(rc4_2s)
  priors4_2s = read_samples(m4_2s; output_format=:dataframe)
  PRECIS(priors4_2s)
end

# ╔═╡ 3146d9a2-805d-11eb-06d2-17420dbd5a96
plot(density(priors4_2s.mu, lab="μ"), density(priors4_2s.sigma, lab="σ"),
	layout=(1,2))

# ╔═╡ 2e20929c-0e8c-11eb-0388-c34bd6d066e9
md"## End of stan-priors.jl"

# ╔═╡ Cell order:
# ╟─04aef49e-0e8c-11eb-3495-3130c54c5cfd
# ╠═2de17794-0e8c-11eb-3203-5f2b7b5b7dd7
# ╠═2decc0c0-0e8c-11eb-0775-913c59e73d99
# ╠═2df79612-0e8c-11eb-1157-af213cb775a3
# ╠═2e01794a-0e8c-11eb-0825-973992a079a9
# ╠═2e0c33a8-0e8c-11eb-0605-737c37533499
# ╠═2e1fed7e-0e8c-11eb-0996-eb641a2c95ae
# ╠═3146d9a2-805d-11eb-06d2-17420dbd5a96
# ╟─2e20929c-0e8c-11eb-0388-c34bd6d066e9
