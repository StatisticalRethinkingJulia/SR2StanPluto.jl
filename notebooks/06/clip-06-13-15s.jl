### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 2ebffa2a-feac-11ea-27d0-3b7cf030672a
using Pkg, DrWatson

# ╔═╡ 2ec03170-feac-11ea-3cd8-e9c1d16cd34c
begin
  @quickactivate "StatisticalRethinkingStan"
  using StanSample
  using StatisticalRethinking
end

# ╔═╡ 37e0328a-feab-11ea-031f-df82e9c87154
md"## Clip-06-13-15s.jl"

# ╔═╡ 2ec0c25c-feac-11ea-2439-07e617727eb5
begin
  N = 100
  df = DataFrame(
    :h0 => rand(Normal(10,2 ), N),
    :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
  );
  df.fungus = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
  df.h1 = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
  scale!(df, [:h0, :treatment, :fungus, :h1])
end;

# ╔═╡ 2ed0d892-feac-11ea-1ad3-5dfeacd40f38
Text(precis(df, io=String))

# ╔═╡ 2ed17b7e-feac-11ea-2d49-3ba0f6783ba4
sim_p = DataFrame(:sim_p => rand(LogNormal(0, 0.25), 10000));

# ╔═╡ 2edbc4b2-feac-11ea-0977-37cb5da52497
Text(precis(sim_p; io=String))

# ╔═╡ 2edc81fe-feac-11ea-3f3c-2ff7b2c13458
stan6_6 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
}
parameters{
  real<lower=0> p;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  p ~ lognormal(0, 0.25);
  sigma ~ exponential(1);
  mu = h0 * p;
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 2ee7bd6a-feac-11ea-1120-776954c32bd8
begin
	m6_6s = SampleModel("m6.6s", stan6_6)
	m6_6_data = Dict(:N => nrow(df), :h0 => df.h0, :h1 => df.h1)
	rc6_6s = stan_sample(m6_6s; data=m6_6_data)
	success(rc6_6s) && (post6_6s_df = read_samples(m6_6s; output_format=:dataframe))
end;

# ╔═╡ 2ef5aa9c-feac-11ea-1da4-67356630f549
if success(rc6_6s)
	part6_6s = Particles(post6_6s_df)
end

# ╔═╡ 2f01856c-feac-11ea-0b6b-537d35689cfc
success(rc6_6s) && (Text(precis(post6_6s_df; io=String)))

# ╔═╡ 2f093c3a-feac-11ea-2325-37124b7e6bdf
md"## End of clip-06-13-15s.jl"

# ╔═╡ Cell order:
# ╠═37e0328a-feab-11ea-031f-df82e9c87154
# ╠═2ebffa2a-feac-11ea-27d0-3b7cf030672a
# ╠═2ec03170-feac-11ea-3cd8-e9c1d16cd34c
# ╠═2ec0c25c-feac-11ea-2439-07e617727eb5
# ╠═2ed0d892-feac-11ea-1ad3-5dfeacd40f38
# ╠═2ed17b7e-feac-11ea-2d49-3ba0f6783ba4
# ╠═2edbc4b2-feac-11ea-0977-37cb5da52497
# ╠═2edc81fe-feac-11ea-3f3c-2ff7b2c13458
# ╠═2ee7bd6a-feac-11ea-1120-776954c32bd8
# ╠═2ef5aa9c-feac-11ea-1da4-67356630f549
# ╠═2f01856c-feac-11ea-0b6b-537d35689cfc
# ╟─2f093c3a-feac-11ea-2325-37124b7e6bdf
