
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Stan-optimize-01s.jl"

md"##### This notebook uses a SampleModel and OptimizeModel to demonstrate the quadratic approximation. See `stan-optimize-02s.jl` for a more streamlined approach for the relatively simple models in chapters 4 to 8 of StatisticalRethinking."

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

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

begin
  m4_2_data = Dict(:N => length(df.height), :h => df.height)
  m4_2_init = Dict(:mu => 174.0, :sigma => 5.0)
end;

md"##### Create a SampleModel:"

begin
  m4_2_sample_s = SampleModel("m4.2_sample_s", stan4_2)
  rc4_2_sample_s = stan_sample(m4_2_sample_s; data=m4_2_data)
end;

begin
  if success(rc4_2_sample_s)
    m4_2_sample_s_df = read_samples(m4_2_sample_s; output_format=:dataframe)
    precis(m4_2_sample_s_df)
  end
end

md"##### Create an OptimizeMdel:"

begin
	m4_2_opt_s = OptimizeModel("m4.2_opt_s", stan4_2)
	rc4_2_opt_s = stan_optimize(m4_2_opt_s; data=m4_2_data, init=m4_2_init)
end;

if success(rc4_2_opt_s)
  optim_stan, cnames = read_optimize(m4_2_opt_s)
  optim_stan
end

quap(m4_2_sample_s_df)

quap(m4_2_sample_s)

begin
  q4_2s = quap(m4_2_sample_s, m4_2_opt_s)
  quap4_2s_df = sample(q4_2s)
  precis(quap4_2s_df)
end

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

md"## End of stan-optimize-01s.jl intro"

