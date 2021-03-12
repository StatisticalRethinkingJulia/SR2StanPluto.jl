### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 0b19c578-762b-11eb-34b6-01e80cef1406
using Pkg, DrWatson

# ╔═╡ 3f814e9e-762b-11eb-1340-91617ca7b58a
begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking 
end

# ╔═╡ af1efcf4-779a-11eb-0d62-e3c63876a09b
md" ## Clip-09-25-27s.jl"

# ╔═╡ cb88768a-779b-11eb-1a4e-99f92ded29ca
begin
	y = rand(Normal(), 100)
	data = (N = length(y), y=y)
end;

# ╔═╡ e37331ea-779b-11eb-1b02-1fdb61aae124
stan9_4 = "
data {
	int N;
	vector[N] y;
}
parameters{
    real a1;
    real a2;
    real<lower=0> sigma;
}
model{
    real mu;
    sigma ~ exponential( 1 );
    a2 ~ normal( 0 , 1000 );
    a1 ~ normal( 0 , 1000 );
    mu = a1 + a2;
    y ~ normal( mu , sigma );
}
";

# ╔═╡ 3fafc7fe-762b-11eb-37da-254b6d75f5ca
begin
	m9_4s = SampleModel("m9.4s", stan9_4)
	rc9_4s = stan_sample(m9_4s; data)

	if success(rc9_4s)
		m9_4s_df = read_samples(m9_4s; output_format=:dataframe)
		PRECIS(m9_4s_df)
	end
end

# ╔═╡ 140d4962-7ebd-11eb-20f6-efc652cf9335
read_summary(m9_4s)

# ╔═╡ b4d020b8-762d-11eb-167a-9fd79d948647
trankplot(m9_4s, :a1)[1]

# ╔═╡ 7b4bc93e-7ebb-11eb-1912-f152a5e76df6
trankplot(m9_4s, :a2)[1]

# ╔═╡ 728ad3aa-7eb7-11eb-2fea-634a82832501
trankplot(m9_4s, :sigma)[1]

# ╔═╡ 059b3ada-7eb8-11eb-10aa-459e3ec2bc55
begin
	chns9_4s = read_samples(m9_4s; output_format=:mcmcchains)
	Text(sprint(show, "text/plain", summarize(chns9_4s)))
end

# ╔═╡ 453b6b34-8356-11eb-0049-51a7363b24d4
CHNS(chns9_4s)

# ╔═╡ 6fbfa790-7eb9-11eb-0360-ed6fc7fa11a3
plot(chns9_4s)

# ╔═╡ a93a71e4-7eb9-11eb-2a36-d33e7b88e2d6
stan9_5 = "
data {
	int N;
	vector[N] y;
}
parameters{
    real a1;
    real a2;
    real<lower=0> sigma;
}
model{
    real mu;
    sigma ~ exponential( 1 );
    a2 ~ normal( 0 , 10 );
    a1 ~ normal( 0 , 10 );
    mu = a1 + a2;
    y ~ normal( mu , sigma );
}
";

# ╔═╡ b4ea8d58-7eb9-11eb-172f-3941a1b8fe98
begin
	m9_5s = SampleModel("m9.5s", stan9_5)
	rc9_5s = stan_sample(m9_5s; data)

	if success(rc9_5s)
		m9_5s_df = read_samples(m9_5s; output_format=:dataframe)
		PRECIS(m9_5s_df)
	end
end

# ╔═╡ ef7953e8-7eb9-11eb-3344-8d762d7e3584
trankplot(m9_5s, :a1)[1]

# ╔═╡ f042277e-7ebb-11eb-33d4-b7edd9539943
trankplot(m9_5s, :a2)[1]

# ╔═╡ 29b1d698-7eba-11eb-00aa-e95796579cc6
trankplot(m9_5s, :sigma)[1]

# ╔═╡ 39bb0f76-7eba-11eb-1bc2-293259d12dfc
begin
	chns9_5s = read_samples(m9_5s; output_format=:mcmcchains)
	Text(sprint(show, "text/plain", summarize(chns9_5s)))
end

# ╔═╡ 6748f438-8380-11eb-312d-cbfe0500b586
CHNS(chns9_5s)

# ╔═╡ 43b362c6-7eba-11eb-389e-fb53b3783e8d
plot(chns9_5s)

# ╔═╡ ca61c622-779a-11eb-1292-3f272953867f
md" ## End of clip-09-25-27s.jl"

# ╔═╡ Cell order:
# ╟─af1efcf4-779a-11eb-0d62-e3c63876a09b
# ╠═0b19c578-762b-11eb-34b6-01e80cef1406
# ╠═3f814e9e-762b-11eb-1340-91617ca7b58a
# ╠═cb88768a-779b-11eb-1a4e-99f92ded29ca
# ╠═e37331ea-779b-11eb-1b02-1fdb61aae124
# ╠═3fafc7fe-762b-11eb-37da-254b6d75f5ca
# ╠═140d4962-7ebd-11eb-20f6-efc652cf9335
# ╠═b4d020b8-762d-11eb-167a-9fd79d948647
# ╠═7b4bc93e-7ebb-11eb-1912-f152a5e76df6
# ╠═728ad3aa-7eb7-11eb-2fea-634a82832501
# ╠═059b3ada-7eb8-11eb-10aa-459e3ec2bc55
# ╠═453b6b34-8356-11eb-0049-51a7363b24d4
# ╠═6fbfa790-7eb9-11eb-0360-ed6fc7fa11a3
# ╠═a93a71e4-7eb9-11eb-2a36-d33e7b88e2d6
# ╠═b4ea8d58-7eb9-11eb-172f-3941a1b8fe98
# ╠═ef7953e8-7eb9-11eb-3344-8d762d7e3584
# ╠═f042277e-7ebb-11eb-33d4-b7edd9539943
# ╠═29b1d698-7eba-11eb-00aa-e95796579cc6
# ╠═39bb0f76-7eba-11eb-1bc2-293259d12dfc
# ╠═6748f438-8380-11eb-312d-cbfe0500b586
# ╠═43b362c6-7eba-11eb-389e-fb53b3783e8d
# ╟─ca61c622-779a-11eb-1292-3f272953867f
