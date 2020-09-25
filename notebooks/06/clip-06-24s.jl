### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ ba04b94e-ff3e-11ea-1c4f-df1747ceff76
using Pkg, DrWatson

# ╔═╡ ba05026e-ff3e-11ea-14f2-0f30e9d422b2
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ bbb50ac4-ff3d-11ea-1ff8-c3a12b8a9a30
md"## Clip-06-24s.jl"

# ╔═╡ ba093834-ff3e-11ea-1139-4f6986da5b02
begin
	df = sim_happiness()
	df.A = (df.age .- 18) / (65 - 18)
	Text(precis(df; io=String))
end

# ╔═╡ ba1554d4-ff3e-11ea-00a5-01b221494ff3
m6_10 = "
data {
  int <lower=1> N;
  vector[N] happiness;
  vector[N] A;
}
parameters {
  real <lower=0> sigma;
  real a;
  real bA;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  bA ~ normal(0, 2);
  mu = a + bA * A;
  happiness ~ normal(mu, sigma);
}
";

# ╔═╡ ba160c44-ff3e-11ea-22f9-2d892aba888f
begin
	m6_10s = SampleModel("m6.10s", m6_10)
	m6_10_data = Dict(:N => nrow(df), :happiness => df.happiness, :A => df.A,)
	rc6_10s = stan_sample(m6_10s, data=m6_10_data)
	success(rc6_10s) && (p6_10s = read_samples(m6_10s, output_format=:particles))
end

# ╔═╡ ba209362-ff3e-11ea-168c-1d6dd60dae6c
if success(rc6_10s)
  dfa6_10s = read_samples(m6_10s, output_format=:dataframe)
  Text(precis(dfa6_10s; io=String))
end

# ╔═╡ ba2125ac-ff3e-11ea-257c-3974d8044dd8
begin
	p = plot(xlab="age", ylab="happiness", leg=false, title="unmarried (grey), married (blue)")
	for i in 1:nrow(df)
		if df[i, :married] == 1
			scatter!([df[i, :age]], [df[i, :happiness]], color=:darkblue)
		else
			scatter!([df[i, :age]], [df[i, :happiness]], color=:lightgrey)
		end
	end
	p
end

# ╔═╡ ba2a9f2e-ff3e-11ea-0c3c-1b46b3ab931f
md"## End of clip-06-24s.jl"

# ╔═╡ Cell order:
# ╟─bbb50ac4-ff3d-11ea-1ff8-c3a12b8a9a30
# ╠═ba04b94e-ff3e-11ea-1c4f-df1747ceff76
# ╠═ba05026e-ff3e-11ea-14f2-0f30e9d422b2
# ╠═ba093834-ff3e-11ea-1139-4f6986da5b02
# ╠═ba1554d4-ff3e-11ea-00a5-01b221494ff3
# ╠═ba160c44-ff3e-11ea-22f9-2d892aba888f
# ╠═ba209362-ff3e-11ea-168c-1d6dd60dae6c
# ╠═ba2125ac-ff3e-11ea-257c-3974d8044dd8
# ╟─ba2a9f2e-ff3e-11ea-0c3c-1b46b3ab931f
