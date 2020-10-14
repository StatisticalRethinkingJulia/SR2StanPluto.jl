### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 85146726-fb5f-11ea-0e9b-c178282ef940
using Pkg, DrWatson

# ╔═╡ 8514b000-fb5f-11ea-0f19-4131e60e5e40
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
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
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ 8534f82e-fb5f-11ea-272a-5d6ffc867d60
begin
	m4_1s = SampleModel("m4_1s", m4_1)
	m4_1_data = Dict("N" => length(df.height), "h" => df.height)
	rc4_1s = stan_sample(m4_1s, data=m4_1_data)
end;

# ╔═╡ 8542c8b2-fb5f-11ea-175b-739d60bcb414
if success(rc4_1s)

	# Array od DataFrames, 1 Dataframe/chain
	
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
	plot(figs..., layout=(2,1))
end

# ╔═╡ 855315e8-fb5f-11ea-1be3-fd3515317471
success(rc4_1s) && (part4_1s = read_samples(m4_1s; output_format=:particles))

# ╔═╡ 855512da-fb5f-11ea-3166-39b8cbfc82d7
md"### Snippet 4.28 & 4.29"

# ╔═╡ 8560d76c-fb5f-11ea-0bc6-2b249358d29f
begin
	
	# Append all chains in a single DataFrame

	dfa4_1s = read_samples(m4_1s; output_format=:dataframe)
	
	# Stan quap estimate
	
	quap4_1s = quap(dfa4_1s)
end

# ╔═╡ 856acb96-fb5f-11ea-0158-43294ff1757c
md"### Snippet 4.30"

# ╔═╡ 856beda2-fb5f-11ea-2681-0942a973cf86
md"##### If required, starting values can be passed in to `stan_sample()`.
Open `Live docs` and click on `stan_sample` in a cell."

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
# ╠═8534f82e-fb5f-11ea-272a-5d6ffc867d60
# ╠═8542c8b2-fb5f-11ea-175b-739d60bcb414
# ╠═855315e8-fb5f-11ea-1be3-fd3515317471
# ╟─855512da-fb5f-11ea-3166-39b8cbfc82d7
# ╠═8560d76c-fb5f-11ea-0bc6-2b249358d29f
# ╟─856acb96-fb5f-11ea-0158-43294ff1757c
# ╟─856beda2-fb5f-11ea-2681-0942a973cf86
# ╟─8573377e-fb5f-11ea-05ef-1b6568304ef8
