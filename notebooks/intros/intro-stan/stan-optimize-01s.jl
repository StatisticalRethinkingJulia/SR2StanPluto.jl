### A Pluto.jl notebook ###
# v0.12.15

using Markdown
using InteractiveUtils

# ╔═╡ b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
using Pkg, DrWatson

# ╔═╡ b878f13a-0e8b-11eb-3a3d-3df3931f026e
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 766ea8e6-0e8b-11eb-15fa-477197ab5a31
md"## Stan-optimize.jl"

# ╔═╡ b88588d8-0e8b-11eb-096f-f152abbd3d1e
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
stan4_2 = "
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

# ╔═╡ b89c414e-0e8b-11eb-2056-bd70c5d493ee
begin
  m4_2_data = Dict(:N => length(df.height), :h => df.height)
  m4_2_init = Dict(:mu => 174.0, :sigma => 5.0)
end;

# ╔═╡ cb914d40-3345-11eb-1f96-81c4902b8193
begin
  m4_2_sample_s = SampleModel("m4.2_sample_s", stan4_2)
  rc4_2_sample_s = stan_sample(m4_2_sample_s; data=m4_2_data)
end;

# ╔═╡ 847d6bee-3347-11eb-0b71-312d18c967df
begin
  if success(rc4_2_sample_s)
    m4_2_sample_s_df = read_samples(m4_2_sample_s; output_format=:dataframe)
    precis(m4_2_sample_s_df)
  end
end

# ╔═╡ a87dc40a-3345-11eb-191b-7f02f5ff8ee7
begin
	m4_2_opt_s = OptimizeModel("m4.2_opt_s", stan4_2)
	rc4_2_opt_s = stan_optimize(m4_2_opt_s; data=m4_2_data, init=m4_2_init)
end;

# ╔═╡ b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
if success(rc4_2_opt_s)
  optim_stan, cnames = read_optimize(m4_2_opt_s)
  optim_stan
end

# ╔═╡ 0c4bcc62-3345-11eb-1d44-652ed085b8c5
quap(m4_2_sample_s_df)

# ╔═╡ 3ac54690-3345-11eb-33c0-a9981f2867a6
quap(m4_2_sample_s)

# ╔═╡ cf29cb5a-33e8-11eb-142c-319fcce6609b
begin
  q4_2s = quap(m4_2_sample_s, m4_2_opt_s)
  quap4_2s_df = sample(q4_2s)
  precis(quap4_2s_df)
end

# ╔═╡ 314b3234-3348-11eb-0d37-c5aa7e3f6c94
md"##### Turing quap results:
```
julia> opt = optimize(model, MAP())
ModeResult with maximized lp of -1227.92
2-element Named Array{Float64,1}
A  │ 
───┼────────
:μ │ 154.607
:σ │ 7.73133

julia> coef = opt.values.array
2-element Array{Float64,1}:
 154.60702358192225
   7.731333062764486

julia> var_cov_matrix = informationmatrix(opt)
2×2 Named Array{Float64,2}
A ╲ B │          :μ           :σ
──────┼─────────────────────────
:μ    │     0.16974  0.000218032
:σ    │ 0.000218032    0.0849058
```"

# ╔═╡ b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
md"## End of Stan optimize intro"

# ╔═╡ Cell order:
# ╟─766ea8e6-0e8b-11eb-15fa-477197ab5a31
# ╠═b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
# ╠═b878f13a-0e8b-11eb-3a3d-3df3931f026e
# ╠═b88588d8-0e8b-11eb-096f-f152abbd3d1e
# ╠═b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
# ╠═b89c414e-0e8b-11eb-2056-bd70c5d493ee
# ╠═cb914d40-3345-11eb-1f96-81c4902b8193
# ╠═847d6bee-3347-11eb-0b71-312d18c967df
# ╠═a87dc40a-3345-11eb-191b-7f02f5ff8ee7
# ╠═b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
# ╠═0c4bcc62-3345-11eb-1d44-652ed085b8c5
# ╠═3ac54690-3345-11eb-33c0-a9981f2867a6
# ╠═cf29cb5a-33e8-11eb-142c-319fcce6609b
# ╟─314b3234-3348-11eb-0d37-c5aa7e3f6c94
# ╟─b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
