### A Pluto.jl notebook ###
# v0.12.16

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
md"## Stan-optimize-02s.jl"

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

# ╔═╡ a109cbc0-3803-11eb-114c-09042c8e43aa
md"##### Single quap() call to compoute the quadratic approximation to std (sigma) and mean (mu). Note that the SampleModel and the OptimizeModel are accessable later on."

# ╔═╡ cf29cb5a-33e8-11eb-142c-319fcce6609b
begin
	(q4_2s, sm, om) = quap("m4.2s", stan4_2;
		data=m4_2_data, init=m4_2_init)
	q4_2s.coef
end

# ╔═╡ 32dfec2e-3808-11eb-23a6-9beab7ea7ad9
md"##### Full NamedTuple that represents a quap model."

# ╔═╡ 253abe0c-3808-11eb-34ed-e326357b5ef1
q4_2s

# ╔═╡ c827a84e-3803-11eb-3132-49fe04345644
md"##### Covariance matrix associated with quadratic approximation."

# ╔═╡ 6eb72422-3803-11eb-3466-15f6c77d34d8
q4_2s.vcov

# ╔═╡ fa682b4e-3803-11eb-1227-cd8b362e2bb7
md"##### Convert to standard deviation."

# ╔═╡ 31979c2c-3803-11eb-03bd-c70e943ebff3
√q4_2s.vcov

# ╔═╡ 40852ba4-3804-11eb-1e35-d7615b8949a1
md"##### Sample quap model."

# ╔═╡ 4cf05e2c-3804-11eb-09ad-87aecc8e1dd0
begin
	quap4_2s_df = sample(q4_2s)
	PRECIS(quap4_2s_df)
end

# ╔═╡ 11fa4ba2-3804-11eb-38c8-67ed4fdb4ce4
md"##### Original draws from Stan model."

# ╔═╡ b4df80fc-3802-11eb-0234-5d8def35738f
begin
	m4_2_sample_s_df = read_samples(sm; output_format=:dataframe)
    PRECIS(m4_2_sample_s_df)
end

# ╔═╡ 2464df32-3804-11eb-255f-adc24b6c47d8
md"##### MAP estimates using stan_optimize (4 chains)."

# ╔═╡ c998ac88-3802-11eb-2d23-25478d2c3786
begin
  optim_stan, _ = read_optimize(om)
  optim_stan
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
md"## End of stan-optimize-02s.jl"

# ╔═╡ Cell order:
# ╟─766ea8e6-0e8b-11eb-15fa-477197ab5a31
# ╠═b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
# ╠═b878f13a-0e8b-11eb-3a3d-3df3931f026e
# ╠═b88588d8-0e8b-11eb-096f-f152abbd3d1e
# ╠═b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
# ╠═b89c414e-0e8b-11eb-2056-bd70c5d493ee
# ╠═a109cbc0-3803-11eb-114c-09042c8e43aa
# ╠═cf29cb5a-33e8-11eb-142c-319fcce6609b
# ╟─32dfec2e-3808-11eb-23a6-9beab7ea7ad9
# ╠═253abe0c-3808-11eb-34ed-e326357b5ef1
# ╟─c827a84e-3803-11eb-3132-49fe04345644
# ╠═6eb72422-3803-11eb-3466-15f6c77d34d8
# ╟─fa682b4e-3803-11eb-1227-cd8b362e2bb7
# ╠═31979c2c-3803-11eb-03bd-c70e943ebff3
# ╟─40852ba4-3804-11eb-1e35-d7615b8949a1
# ╠═4cf05e2c-3804-11eb-09ad-87aecc8e1dd0
# ╟─11fa4ba2-3804-11eb-38c8-67ed4fdb4ce4
# ╠═b4df80fc-3802-11eb-0234-5d8def35738f
# ╟─2464df32-3804-11eb-255f-adc24b6c47d8
# ╠═c998ac88-3802-11eb-2d23-25478d2c3786
# ╟─314b3234-3348-11eb-0d37-c5aa7e3f6c94
# ╟─b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
