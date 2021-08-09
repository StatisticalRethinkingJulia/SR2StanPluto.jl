### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 85146726-fb5f-11ea-0e9b-c178282ef940
using Pkg, DrWatson

# ╔═╡ 8514b000-fb5f-11ea-0f19-4131e60e5e40
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
end

# ╔═╡ 34416e06-fb5b-11ea-2816-6deba8768ba8
md"## Clip-04-26-30s.jl"

# ╔═╡ 85152788-fb5f-11ea-3f58-0bb01df7f423
md"### Snippet 4.26"

# ╔═╡ 8523db98-fb5f-11ea-143e-e5ae17aabbe8
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 852467a2-fb5f-11ea-01cd-cbcae8197739
md"### Snippet 4.27"

# ╔═╡ 852d4188-fb5f-11ea-399e-b9a0892f608e
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
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ 855512da-fb5f-11ea-3166-39b8cbfc82d7
md"### Snippet 4.28, 4.29 & 4.30"

# ╔═╡ b6f80b9c-3cc0-11eb-2dd5-2b133f397f41
 md"##### Quadratic approximation vs. Stan samples vs. Normal distribution."

# ╔═╡ 24cec984-3c27-11eb-2ff2-f79c61deccf4
begin
	m4_1_data = Dict("N" => length(df.height), "h" => df.height)      # 4.26
	m4_1_init = Dict(:mu => 180.0, :sigma => 10.0)                    # 4.30
	q4_1s, m4_1s, om = stan_quap("m4_1_s", stan4_1; data=m4_1_data, init=m4_1_init)
	quap4_1s_df = sample(q4_1s)                                       # 4.29
	PRECIS(quap4_1s_df)                                               # 4.29
end

# ╔═╡ 9e4ba502-3c2c-11eb-0e99-ad512c8ca8e4
begin
	post4_1s_df = read_samples(m4_1s, :dataframe)
	e = ecdf(post4_1s_df.mu)
	f = ecdf(quap4_1s_df.mu)
	g = ecdf(rand(Normal(mean(post4_1s_df.mu), std(post4_1s_df.mu)), 4000))
	r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
	plot(r, e(r), lab = "ECDF mu (Stan samples)", leg = :bottomright)
	plot!(r, f(r), lab = "ECDF mu (quap approx.)")
	plot!(r, g(r), lab = "ECDF mu (Normal distr.)")
end

# ╔═╡ 8dbed206-3cc0-11eb-05e0-2fabb5827e04
md"##### Look at individual chains."

# ╔═╡ 8542c8b2-fb5f-11ea-175b-739d60bcb414
if !isnothing(m4_1s)

	# Array of DataFrames, 1 Dataframe/chain
	
	dfs4_1s = read_samples(m4_1s, :dataframes)
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
	plot(figs..., layout=(2,1))
end

# ╔═╡ aacb8f74-3cc0-11eb-0493-8def94216dd8
md"##### Particle summary."

# ╔═╡ 855315e8-fb5f-11ea-1be3-fd3515317471
if !isnothing(m4_1s)
	part4_1s = read_samples(m4_1s, :particles)
end

# ╔═╡ 8573377e-fb5f-11ea-05ef-1b6568304ef8
md"# End of clip-04-26-30s.jl"

# ╔═╡ Cell order:
# ╟─34416e06-fb5b-11ea-2816-6deba8768ba8
# ╠═85146726-fb5f-11ea-0e9b-c178282ef940
# ╠═8514b000-fb5f-11ea-0f19-4131e60e5e40
# ╟─85152788-fb5f-11ea-3f58-0bb01df7f423
# ╠═8523db98-fb5f-11ea-143e-e5ae17aabbe8
# ╟─852467a2-fb5f-11ea-01cd-cbcae8197739
# ╠═852d4188-fb5f-11ea-399e-b9a0892f608e
# ╟─855512da-fb5f-11ea-3166-39b8cbfc82d7
# ╟─b6f80b9c-3cc0-11eb-2dd5-2b133f397f41
# ╠═24cec984-3c27-11eb-2ff2-f79c61deccf4
# ╠═9e4ba502-3c2c-11eb-0e99-ad512c8ca8e4
# ╟─8dbed206-3cc0-11eb-05e0-2fabb5827e04
# ╠═8542c8b2-fb5f-11ea-175b-739d60bcb414
# ╟─aacb8f74-3cc0-11eb-0493-8def94216dd8
# ╠═855315e8-fb5f-11ea-1be3-fd3515317471
# ╟─8573377e-fb5f-11ea-05ef-1b6568304ef8
