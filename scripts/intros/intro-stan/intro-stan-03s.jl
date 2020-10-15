
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Intro-stan-03s.jl"

md"##### Define the Stan language model."

begin
	m1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}"
end;

md"##### Create an OptimizeModel"

sm = OptimizeModel("m1.1s", m1_1);

begin
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	m1_1_data = Dict("N" => N, "n" => n, "k" => k)
end;

rc = stan_optimize(sm, data=m1_1_data);

md"##### Describe the optimize result"

if success(rc)
  optim_stan, cnames = read_optimize(sm)
  optim_stan
end

md"## End of intro/intro-stan-03s.jl"

