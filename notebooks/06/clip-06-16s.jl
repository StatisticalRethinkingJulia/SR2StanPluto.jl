### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ b4949654-ff30-11ea-225c-2ffc47a35a31
using Pkg, DrWatson

# ╔═╡ b494da42-ff30-11ea-25d2-37857c757c9f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ b0e1bc4a-ff2f-11ea-1dca-f78fefb58b8f
md"## Clip-06-16s.jl"

# ╔═╡ b495756a-ff30-11ea-378a-236707f95773
begin
	N = 100
	df = DataFrame(
		:h0 => rand(Normal(10,2 ), N),
		:treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
	);
	df.fungus = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
	df.h1 = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
end;

# ╔═╡ 221f1e8a-00f6-11eb-3504-a91f4659a8a6
Text(precis(df; io=String))

# ╔═╡ b4a2fe56-ff30-11ea-255b-bbe592530dac
stan6_7 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
  vector[N] fungus;
}
parameters{
  real a;
  real bt;
  real bf;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ b4a44e3c-ff30-11ea-0868-93935a280415
begin
	m6_7s = SampleModel("m6.7s", stan6_7)
	m6_7_data = Dict(
	  :N => nrow(df),
	  :h0 => df[:, :h0],
	  :h1 => df[:, :h1],
	  :fungus => df[:, :fungus],
	  :treatment => df[:, :treatment]
	)
	rc6_7s = stan_sample(m6_7s; data=m6_7_data)
	success(rc6_7s) && (post6_7s_df = read_samples(m6_7s; output_format=:dataframe))
end;

# ╔═╡ b4a98408-ff30-11ea-2918-9b5d39692695
success(rc6_7s) && Particles(post6_7s_df)

# ╔═╡ b4b7702a-ff30-11ea-169a-159df3080e8b
success(rc6_7s) && (Text(precis(post6_7s_df; io=String)))

# ╔═╡ b4b8301e-ff30-11ea-2a3c-a11e3745616e
if success(rc6_7s)
	(part6_7s, fig6_7s) = plotcoef([m6_7s], [:a, :bt, :bf])
	fig6_7s
end

# ╔═╡ b4c852fa-ff30-11ea-18d0-47dfe321ba8a
md"## End of clip-06-16s.jl"

# ╔═╡ Cell order:
# ╟─b0e1bc4a-ff2f-11ea-1dca-f78fefb58b8f
# ╠═b4949654-ff30-11ea-225c-2ffc47a35a31
# ╠═b494da42-ff30-11ea-25d2-37857c757c9f
# ╠═b495756a-ff30-11ea-378a-236707f95773
# ╠═221f1e8a-00f6-11eb-3504-a91f4659a8a6
# ╠═b4a2fe56-ff30-11ea-255b-bbe592530dac
# ╠═b4a44e3c-ff30-11ea-0868-93935a280415
# ╠═b4a98408-ff30-11ea-2918-9b5d39692695
# ╠═b4b7702a-ff30-11ea-169a-159df3080e8b
# ╠═b4b8301e-ff30-11ea-2a3c-a11e3745616e
# ╟─b4c852fa-ff30-11ea-18d0-47dfe321ba8a
