### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 74bfe2ae-ff3f-11ea-0432-59882876ebfa
using Pkg, DrWatson

# ╔═╡ fc2a7f98-ff3e-11ea-0a77-4303db026d38
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ d111008e-ff3e-11ea-0e7b-dbef3b2cbba7
md"## Clip-06-25-27s.jl"

# ╔═╡ fc38e330-ff3e-11ea-30d2-6d36a2b02d21
begin
	N = 200
	b_GP = 1                               # Direct effect of G on P
	b_GC = 0                               # Direct effect of G on C
	b_PC = 1                               # Direct effect of P on C
	b_U = 2                                # Direct effect of U on P and C
	df = DataFrame(:u => 2 * rand(Bernoulli(0.5), N) .- 1, :g => rand(Normal(), N))
	df[!, :p] = [rand(Normal(b_GP * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]
	df[!, :c] = [rand(Normal(b_PC * df[i, :p] + b_GC * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]
	Text(precis(df; io=String))
end

# ╔═╡ fc758632-ff3e-11ea-2bb7-a912dcd87e60
m6_11 = "
data {
  int <lower=0> N;
  vector[N] C;
  vector[N] P;
  vector[N] G;
}
parameters {
  real <lower=0> sigma;
  real a;
  real b_PC;
  real b_GC;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  b_PC ~ normal(0, 1);
  b_GC ~ normal(0, 1);
  mu = a + b_PC * P + b_GC * G;
  C ~ normal(mu, sigma);
}
";

# ╔═╡ fc83030c-ff3e-11ea-3b69-17c96c3cb2a6
begin
	m6_11s = SampleModel("m6.11s", m6_11)
	m6_11_data = Dict(:N => nrow(df), :C => df.c, :P => df.p, :G => df.g)
	rc6_11s = stan_sample(m6_11s, data=m6_11_data)
	if success(rc6_11s)
		dfa6_11s = read_samples(m6_11s, output_format=:dataframe)
		Text(precis(dfa6_11s; io=String))
	end
end

# ╔═╡ ef7c5e1e-ff3f-11ea-1a4b-0be0e86923e1
md"## End of clip-06-25-27s.jl"

# ╔═╡ Cell order:
# ╟─d111008e-ff3e-11ea-0e7b-dbef3b2cbba7
# ╠═74bfe2ae-ff3f-11ea-0432-59882876ebfa
# ╠═fc2a7f98-ff3e-11ea-0a77-4303db026d38
# ╠═fc38e330-ff3e-11ea-30d2-6d36a2b02d21
# ╠═fc758632-ff3e-11ea-2bb7-a912dcd87e60
# ╠═fc83030c-ff3e-11ea-3b69-17c96c3cb2a6
# ╟─ef7c5e1e-ff3f-11ea-1a4b-0be0e86923e1
