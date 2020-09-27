### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ b4f5c324-ff31-11ea-38d1-752f4fcf9800
using Pkg, DrWatson

# ╔═╡ b4f6069a-ff31-11ea-3a71-f3c373a846df
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 30fc3d94-ff33-11ea-1899-8dc818a46887
include(projectdir("models", "06", "m6.7s.jl"))

# ╔═╡ bee11e78-ff30-11ea-2603-2546c772ca4b
md"## Clip-06-17s.jl"

# ╔═╡ b4fae4da-ff31-11ea-372d-351491f76437
begin
	N = 100
	df = DataFrame(
	  :h0 => rand(Normal(10,2 ), N),
	  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df.fungus = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df.h1 = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
end;

# ╔═╡ b5092d06-ff31-11ea-2a2e-b1318107f9d9
m6_8 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
}
parameters{
  real a;
  real bt;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ b50a23b4-ff31-11ea-023e-0f45c3ea4cbe
begin
	m6_8s = SampleModel("m6.8s", m6_8)
	m6_8_data = Dict(:N => nrow(df), :h0 => df.h0, :h1 => df.h1, :treatment => df.treatment)
	rc6_8s = stan_sample(m6_8s; data=m6_8_data)
	if success(rc6_8s)
		dfa6_8s = read_samples(m6_8s; output_format=:dataframe)
		p6_8s = Particles(dfa6_8s)
	end
end

# ╔═╡ b5156ee0-ff31-11ea-181a-0dcd53fea5bb
success(rc6_8s) && (Text(precis(dfa6_8s; io=String)))

# ╔═╡ b51605f8-ff31-11ea-2d88-9b14ae2767b9
if success(rc6_8s)
	(s1, p1) = plotcoef([m6_7s, m6_8s], [:a, :bt, :bf])
	p1
end

# ╔═╡ b521ed8c-ff31-11ea-0470-31ae8d96b8ea
success(rc6_8s) && s1

# ╔═╡ b5227b8a-ff31-11ea-2545-91e90db9d361
md"## End of clip-06-17s.jl"

# ╔═╡ Cell order:
# ╟─bee11e78-ff30-11ea-2603-2546c772ca4b
# ╠═b4f5c324-ff31-11ea-38d1-752f4fcf9800
# ╠═b4f6069a-ff31-11ea-3a71-f3c373a846df
# ╠═30fc3d94-ff33-11ea-1899-8dc818a46887
# ╠═b4fae4da-ff31-11ea-372d-351491f76437
# ╠═b5092d06-ff31-11ea-2a2e-b1318107f9d9
# ╠═b50a23b4-ff31-11ea-023e-0f45c3ea4cbe
# ╠═b5156ee0-ff31-11ea-181a-0dcd53fea5bb
# ╠═b51605f8-ff31-11ea-2d88-9b14ae2767b9
# ╠═b521ed8c-ff31-11ea-0470-31ae8d96b8ea
# ╟─b5227b8a-ff31-11ea-2545-91e90db9d361
