
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Stan-optimize-02s.jl"

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

md"##### Quadratic approximation to std (sigma) and mean (mu)."

begin
	(q4_2s, sm, om) = quap("m4.2s", stan4_2;
		data=m4_2_data, init=m4_2_init)
	q4_2s.coef
end

md"##### Full NamedTuple that represents a quap model."

q4_2s

md"##### Covariance matrix associated with quadratic approximation."

q4_2s.vcov

md"##### Convert to standard deviation."

√q4_2s.vcov

md"##### Sample quap model."

begin
	quap4_2s_df = sample(q4_2s)
	precis(quap4_2s_df)
end

md"##### Original draws from Stan model."

begin
	m4_2_sample_s_df = read_samples(sm; output_format=:dataframe)
    precis(m4_2_sample_s_df)
end

md"##### MAP estimates using stan_optimize (4 chains)."

begin
  optim_stan, _ = read_optimize(om)
  optim_stan
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

md"## End of stan-optimize-02s.jl"

