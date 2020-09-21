### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 8b92427e-fb7a-11ea-245b-dfa0551ea518
using Pkg, DrWatson

# ╔═╡ 8b927db6-fb7a-11ea-2f69-0b162e382593
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 5fbe28a8-fb79-11ea-3272-f14edcf96064
md"## Clip-04-34-36s.jl"

# ╔═╡ 8b9312e4-fb7a-11ea-288c-75f07f76b347
md"### Snippet 4.26"

# ╔═╡ 8ba13c5c-fb7a-11ea-3cf9-71e790d5a555
begin
	df = CSV.read(sr_datadir("..", "data", "Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 8ba870bc-fb7a-11ea-0076-85e2db61cc2a
m4_1 = "
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

# ╔═╡ 8bafe478-fb7a-11ea-07bd-f585de346063
md"### Snippet 4.31"

# ╔═╡ 8bb0861c-fb7a-11ea-1482-fd704f9ad02e
m4_1s = SampleModel("m4_1", m4_1);

# ╔═╡ 8bbb60a0-fb7a-11ea-203d-6135be4c3a02
heightsdata = Dict("N" => length(df.height), "h" => df.height);

# ╔═╡ 8bbbe62e-fb7a-11ea-1016-577ddb595990
rc = stan_sample(m4_1s, data=heightsdata);

# ╔═╡ 8bc24488-fb7a-11ea-1ba1-770c5a7ebc55
if success(rc)
	p = read_samples(m4_1s; output_format=:particles)
end

# ╔═╡ 8bcdd60e-fb7a-11ea-3a73-2ff8064e7814
md"## Stan quap estimate."

# ╔═╡ 8bd83964-fb7a-11ea-2a5f-9b23b6992c80
begin
  dfa = read_samples(m4_1s; output_format=:dataframe)
  q = quap(dfa)
end

# ╔═╡ 8bd90fa6-fb7a-11ea-3c81-59fc91debe8b
md"## Check equivalence of Stan samples and Particles."

# ╔═╡ 8be87b94-fb7a-11ea-0cad-1948f391d2bf
begin
	mu_range = 152.0:0.01:157.0
	plot(mu_range, ecdf(sample(dfa.mu, 10000))(mu_range),
		xlabel="ecdf", ylabel="mu", lab="Stan samples")
end

# ╔═╡ 8bf180ac-fb7a-11ea-3f23-5d0f84019beb
md"## Sampling from quap result:"

# ╔═╡ bf59164a-fb7b-11ea-36b6-759b714a61ee
q

# ╔═╡ 8bfa2cc4-fb7a-11ea-3885-198c3330b7b0
begin
	d = Normal(mean(q.mu), std(q.mu))
	plot!(mu_range, ecdf(rand(d, 10000))(mu_range), lab="Quap samples")
	plot!(mu_range, ecdf(sample(dfa.mu, 10000))(mu_range), lab="Particles samples")
end

# ╔═╡ 8bfcef7a-fb7a-11ea-1b75-890ae0af98b2
begin
	dfas = read_samples(m4_1s; output_format=:dataframes)
	plts = Vector{Plots.Plot{Plots.GRBackend}}(undef, size(dfas[1], 2))

	for (indx, par) in enumerate(names(dfas[1]))
		for i in 1:size(dfas,1)
			if i == 1
				plts[indx] = plot()
	  		end
			e = ecdf(dfas[i][:, par])
			r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
			plts[indx] = plot!(plts[indx], r, e(r), lab = "ECDF $(par) in chain $i")
		end
	end
end

# ╔═╡ 8c0b72b6-fb7a-11ea-2476-bbb194b0fb05
plot(plts..., layout=(2,1))

# ╔═╡ 8c0d58ae-fb7a-11ea-0e3e-87081ac98c12
md"## End of clip-04-34-36s.jl"

# ╔═╡ Cell order:
# ╠═5fbe28a8-fb79-11ea-3272-f14edcf96064
# ╠═8b92427e-fb7a-11ea-245b-dfa0551ea518
# ╠═8b927db6-fb7a-11ea-2f69-0b162e382593
# ╠═8b9312e4-fb7a-11ea-288c-75f07f76b347
# ╠═8ba13c5c-fb7a-11ea-3cf9-71e790d5a555
# ╠═8ba870bc-fb7a-11ea-0076-85e2db61cc2a
# ╠═8bafe478-fb7a-11ea-07bd-f585de346063
# ╠═8bb0861c-fb7a-11ea-1482-fd704f9ad02e
# ╠═8bbb60a0-fb7a-11ea-203d-6135be4c3a02
# ╠═8bbbe62e-fb7a-11ea-1016-577ddb595990
# ╠═8bc24488-fb7a-11ea-1ba1-770c5a7ebc55
# ╟─8bcdd60e-fb7a-11ea-3a73-2ff8064e7814
# ╠═8bd83964-fb7a-11ea-2a5f-9b23b6992c80
# ╟─8bd90fa6-fb7a-11ea-3c81-59fc91debe8b
# ╠═8be87b94-fb7a-11ea-0cad-1948f391d2bf
# ╠═8bf180ac-fb7a-11ea-3f23-5d0f84019beb
# ╠═bf59164a-fb7b-11ea-36b6-759b714a61ee
# ╠═8bfa2cc4-fb7a-11ea-3885-198c3330b7b0
# ╠═8bfcef7a-fb7a-11ea-1b75-890ae0af98b2
# ╠═8c0b72b6-fb7a-11ea-2476-bbb194b0fb05
# ╟─8c0d58ae-fb7a-11ea-0e3e-87081ac98c12
