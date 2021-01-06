
using Markdown
using InteractiveUtils

using Pkg, DrWatson

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

md"## Clip-05-49.2s.jl"

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

begin
	data = (N = size(df, 1), clade_id = c_id, K = df.K_s, k = 4);
    init = (sigma=2.0,)
    q5_9s, m5_9s, o5_9s = quap("m5.9s", stan5_9; data, init)
end

if !isnothing(m5_9s)
  part5_9s = read_samples(m5_9s; output_format=:particles)
  nt5_9s = read_samples(m5_9s)
end

if !isnothing(q5_9s)
  quap5_9s_df = sample(q5_9s)
  quap5_9s = Particles(quap5_9s_df)
end

if !isnothing(o5_9s)
  read_optimize(o5_9s)
end

rethinking_result = "
       mean   sd  5.5% 94.5% n_eff Rhat4
a[1]  -0.47 0.24 -0.84 -0.09   384     1
a[2]   0.35 0.25 -0.07  0.70   587     1
a[3]   0.64 0.28  0.18  1.06   616     1
a[4]  -0.53 0.29 -0.97 -0.05   357     1
sigma  0.81 0.11  0.64  0.98   477     1
";

md"## End of clip-05-49.2s.jl"

