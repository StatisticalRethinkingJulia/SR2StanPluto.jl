### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 8b92427e-fb7a-11ea-245b-dfa0551ea518
using Pkg, DrWatson

# ╔═╡ 8b927db6-fb7a-11ea-2f69-0b162e382593
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
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
stan4_1 = "
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
begin
	data = Dict(:N => length(df.height), :h => df.height)
	init = Dict(:mu => 180, :sigma => 10)
	q4_1s, m4_1s, _ = quap("m4.1s", stan4_1; data, init)
	if !isnothing(m4_1s)
		part4_1s = read_samples(m4_1s; output_format=:particles)
	end
end

# ╔═╡ 8bcdd60e-fb7a-11ea-3a73-2ff8064e7814
md"##### Stan quap estimate."

# ╔═╡ 8bd83964-fb7a-11ea-2a5f-9b23b6992c80
begin
	post4_1s_df = read_samples(m4_1s; output_format=:dataframe)
	quap4_1s_df = sample(q4_1s)
	PRECIS(quap4_1s_df)
end

# ╔═╡ 8bd90fa6-fb7a-11ea-3c81-59fc91debe8b
md"##### Check equivalence of Stan samples and Particles."

# ╔═╡ 8be87b94-fb7a-11ea-0cad-1948f391d2bf
begin
	mu_range = 152.0:0.01:157.0
	plot(mu_range, ecdf(sample(quap4_1s_df.mu, 10000))(mu_range),
		xlabel="ecdf", ylabel="mu", lab="Quap samples")
	plot!(mu_range, ecdf(sample(post4_1s_df.mu, 10000))(mu_range),
		xlabel="ecdf", ylabel="mu", lab="Stan samples")

end

# ╔═╡ 8bf180ac-fb7a-11ea-3f23-5d0f84019beb
md"##### Sampling from quap result:"

# ╔═╡ 8bfa2cc4-fb7a-11ea-3885-198c3330b7b0
begin
	d = Normal(mean(quap4_1s_df.mu), std(quap4_1s_df.mu))
	plot!(mu_range, ecdf(rand(d, 10000))(mu_range), lab="Quap samples")
	plot!(mu_range, ecdf(quap4_1s_df.mu)(mu_range), lab="Particles samples")
end

# ╔═╡ 8bfcef7a-fb7a-11ea-1b75-890ae0af98b2
begin
	dfs4_1s = read_samples(m4_1s; output_format=:dataframes)
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, size(dfs4_1s[1], 2))

	for (indx, par) in enumerate(names(dfs4_1s[1]))
		for i in 1:size(dfs4_1s,1)
			if i == 1
				figs[indx] = plot()
	  		end
			e = ecdf(dfs4_1s[i][:, par])
			r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
			figs[indx] = plot!(figs[indx], r, e(r), lab = "ECDF $(par) in chain $i")
		end
	end
end

# ╔═╡ 8c0b72b6-fb7a-11ea-2476-bbb194b0fb05
plot(figs..., layout=(2,1))

# ╔═╡ 8c0d58ae-fb7a-11ea-0e3e-87081ac98c12
md"## End of clip-04-34-36s.jl"

# ╔═╡ Cell order:
# ╠═5fbe28a8-fb79-11ea-3272-f14edcf96064
# ╠═8b92427e-fb7a-11ea-245b-dfa0551ea518
# ╠═8b927db6-fb7a-11ea-2f69-0b162e382593
# ╠═8b9312e4-fb7a-11ea-288c-75f07f76b347
# ╠═8ba13c5c-fb7a-11ea-3cf9-71e790d5a555
# ╠═8ba870bc-fb7a-11ea-0076-85e2db61cc2a
# ╟─8bafe478-fb7a-11ea-07bd-f585de346063
# ╠═8bb0861c-fb7a-11ea-1482-fd704f9ad02e
# ╟─8bcdd60e-fb7a-11ea-3a73-2ff8064e7814
# ╠═8bd83964-fb7a-11ea-2a5f-9b23b6992c80
# ╟─8bd90fa6-fb7a-11ea-3c81-59fc91debe8b
# ╠═8be87b94-fb7a-11ea-0cad-1948f391d2bf
# ╟─8bf180ac-fb7a-11ea-3f23-5d0f84019beb
# ╠═8bfa2cc4-fb7a-11ea-3885-198c3330b7b0
# ╠═8bfcef7a-fb7a-11ea-1b75-890ae0af98b2
# ╠═8c0b72b6-fb7a-11ea-2476-bbb194b0fb05
# ╟─8c0d58ae-fb7a-11ea-0e3e-87081ac98c12
