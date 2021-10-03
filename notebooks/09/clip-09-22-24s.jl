### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 0b19c578-762b-11eb-34b6-01e80cef1406
using Pkg, DrWatson

# ╔═╡ 3f814e9e-762b-11eb-1340-91617ca7b58a
begin
    #@quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking 
end

# ╔═╡ af1efcf4-779a-11eb-0d62-e3c63876a09b
md" ## Clip-09-22-24s.jl"

# ╔═╡ cb88768a-779b-11eb-1a4e-99f92ded29ca
begin
	y = [-1, 1]
	data = (N = length(y), y=y)
end

# ╔═╡ e37331ea-779b-11eb-1b02-1fdb61aae124
stan9_2 = "
data{
	int N;
    vector[N] y;
}
parameters{
    real alpha;
    real<lower=0> sigma;
}
model{
    real mu;
    sigma ~ exponential( 1e-04 );
    alpha ~ normal( 0 , 1000 );
    mu = alpha;
    y ~ normal( mu , sigma );
}
";

# ╔═╡ 3fafc7fe-762b-11eb-37da-254b6d75f5ca
begin
	m9_2s = SampleModel("m9.2s", stan9_2)
	rc9_2s = stan_sample(m9_2s; data)

	if success(rc9_2s)
		m9_2s_df = read_samples(m9_2s, :dataframe)
		PRECIS(m9_2s_df)
	end
end

# ╔═╡ 316b814a-7ebd-11eb-28a9-27ab6d02d9f9
read_summary(m9_2s)

# ╔═╡ b4d020b8-762d-11eb-167a-9fd79d948647
trankplot(m9_2s, :alpha)[1]

# ╔═╡ 728ad3aa-7eb7-11eb-2fea-634a82832501
trankplot(m9_2s, :sigma)[1]

# ╔═╡ 059b3ada-7eb8-11eb-10aa-459e3ec2bc55
begin
	chns9_2s = read_samples(m9_2s, :mcmcchains)
	Text(sprint(show, "text/plain", summarize(chns9_2s)))
end

# ╔═╡ 6fbfa790-7eb9-11eb-0360-ed6fc7fa11a3
plot(chns9_2s)

# ╔═╡ a93a71e4-7eb9-11eb-2a36-d33e7b88e2d6
stan9_3 = "
data {
	int N;
	vector[N] y;
}
parameters{
    real alpha;
    real<lower=0> sigma;
}
model{
    real mu;
    alpha ~ normal( 1 , 10 );
    sigma ~ exponential( 1 );
    mu = alpha;
    y ~ normal( mu , sigma );
}
";

# ╔═╡ b4ea8d58-7eb9-11eb-172f-3941a1b8fe98
begin
	m9_3s = SampleModel("m9.3s", stan9_3)
	rc9_3s = stan_sample(m9_3s; data)

	if success(rc9_3s)
		m9_3s_df = read_samples(m9_3s, :dataframe)
		PRECIS(m9_3s_df)
	end
end

# ╔═╡ ef7953e8-7eb9-11eb-3344-8d762d7e3584
trankplot(m9_3s, :alpha)[1]

# ╔═╡ 29b1d698-7eba-11eb-00aa-e95796579cc6
trankplot(m9_3s, :sigma)[1]

# ╔═╡ 39bb0f76-7eba-11eb-1bc2-293259d12dfc
begin
	chns9_3s = read_samples(m9_3s, :mcmcchains)
	Text(sprint(show, "text/plain", summarize(chns9_3s)))
end

# ╔═╡ 43b362c6-7eba-11eb-389e-fb53b3783e8d
plot(chns9_3s)

# ╔═╡ ca61c622-779a-11eb-1292-3f272953867f
md" ## End of clip-09-22-24s.jl"

# ╔═╡ Cell order:
# ╟─af1efcf4-779a-11eb-0d62-e3c63876a09b
# ╠═0b19c578-762b-11eb-34b6-01e80cef1406
# ╠═3f814e9e-762b-11eb-1340-91617ca7b58a
# ╠═cb88768a-779b-11eb-1a4e-99f92ded29ca
# ╠═e37331ea-779b-11eb-1b02-1fdb61aae124
# ╠═3fafc7fe-762b-11eb-37da-254b6d75f5ca
# ╠═316b814a-7ebd-11eb-28a9-27ab6d02d9f9
# ╠═b4d020b8-762d-11eb-167a-9fd79d948647
# ╠═728ad3aa-7eb7-11eb-2fea-634a82832501
# ╠═059b3ada-7eb8-11eb-10aa-459e3ec2bc55
# ╠═6fbfa790-7eb9-11eb-0360-ed6fc7fa11a3
# ╠═a93a71e4-7eb9-11eb-2a36-d33e7b88e2d6
# ╠═b4ea8d58-7eb9-11eb-172f-3941a1b8fe98
# ╠═ef7953e8-7eb9-11eb-3344-8d762d7e3584
# ╠═29b1d698-7eba-11eb-00aa-e95796579cc6
# ╠═39bb0f76-7eba-11eb-1bc2-293259d12dfc
# ╠═43b362c6-7eba-11eb-389e-fb53b3783e8d
# ╟─ca61c622-779a-11eb-1292-3f272953867f
