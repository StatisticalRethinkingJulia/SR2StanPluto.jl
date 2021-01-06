### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ e610b214-fdc3-11ea-134c-05cf4c0a4e4c
using Pkg, DrWatson

# ╔═╡ e610e930-fdc3-11ea-3591-7db6a3c831be
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking

	# Circumvent filtering rows with "NA" values out

	c_id= [4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	kcal_per_g = [
	  0.49, 0.51, 0.46, 0.48, 0.60, 0.47, 0.56, 0.89, 0.91, 0.92,
	  0.80, 0.46, 0.71, 0.71, 0.73, 0.68, 0.72, 0.97, 0.79, 0.84,
	  0.48, 0.62, 0.51, 0.54, 0.49, 0.53, 0.48, 0.55, 0.71]

	df = DataFrame(:clade_id => c_id, :K => kcal_per_g)
	scale!(df, [:K])
end;

# ╔═╡ abf55a2e-fdc3-11ea-0e1c-e555171f6c94
md"## Clip-05-49.2s.jl"

# ╔═╡ e6116536-fdc3-11ea-2255-075c0866b513
stan5_9 = "
data{
  int <lower=1> N;              // Sample size
  int <lower=1> k;              // Categories
  vector[N] K;                  // Outcome
  int clade_id[N];              // Predictor
}
parameters{
  vector[k] a;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.5 );
  for ( i in 1:N ) {
      mu[i] = a[clade_id[i]];
  }
  K ~ normal( mu , sigma );
}
";

# ╔═╡ e61e09f8-fdc3-11ea-0391-bfbbb35fbc9b
begin
	data = (N = size(df, 1), clade_id = c_id, K = df.K_s, k = 4);
    init = (sigma=2.0,)
    q5_9s, m5_9s, o5_9s = quap("m5.9s", stan5_9; data, init)
end;

# ╔═╡ d4f8ade0-504f-11eb-3bc2-854d8eca33c4
if !isnothing(m5_9s)
  part5_9s = read_samples(m5_9s; output_format=:particles)
  nt5_9s = read_samples(m5_9s)
end

# ╔═╡ d5238400-504f-11eb-255a-5deed62c878b
if !isnothing(q5_9s)
  quap5_9s_df = sample(q5_9s)
  quap5_9s = Particles(quap5_9s_df)
end

# ╔═╡ d52411cc-504f-11eb-085c-b53444c50f19
if !isnothing(o5_9s)
  read_optimize(o5_9s)
end

# ╔═╡ e74c8da0-5051-11eb-2142-a3ba1967eb1d
q5_9s

# ╔═╡ e62ae894-fdc3-11ea-3de4-2b3cce9dd0bb
rethinking_result = "
       mean   sd  5.5% 94.5% n_eff Rhat4
a[1]  -0.47 0.24 -0.84 -0.09   384     1
a[2]   0.35 0.25 -0.07  0.70   587     1
a[3]   0.64 0.28  0.18  1.06   616     1
a[4]  -0.53 0.29 -0.97 -0.05   357     1
sigma  0.81 0.11  0.64  0.98   477     1
";

# ╔═╡ e62b7ac0-fdc3-11ea-1282-f5b4b9a7118e
md"## End of clip-05-49.2s.jl"

# ╔═╡ Cell order:
# ╟─abf55a2e-fdc3-11ea-0e1c-e555171f6c94
# ╠═e610b214-fdc3-11ea-134c-05cf4c0a4e4c
# ╠═e610e930-fdc3-11ea-3591-7db6a3c831be
# ╠═e6116536-fdc3-11ea-2255-075c0866b513
# ╠═e61e09f8-fdc3-11ea-0391-bfbbb35fbc9b
# ╠═d4f8ade0-504f-11eb-3bc2-854d8eca33c4
# ╠═d5238400-504f-11eb-255a-5deed62c878b
# ╠═d52411cc-504f-11eb-085c-b53444c50f19
# ╠═e74c8da0-5051-11eb-2142-a3ba1967eb1d
# ╠═e62ae894-fdc3-11ea-3de4-2b3cce9dd0bb
# ╟─e62b7ac0-fdc3-11ea-1282-f5b4b9a7118e
