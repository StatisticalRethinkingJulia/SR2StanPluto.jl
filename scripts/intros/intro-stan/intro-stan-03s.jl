
md"The equivalent of the R function `quap()` in StatisticalRethinkingStan uses either StanOptimize or the MAP density of the Stan samples as the mean of the Normal distribution and reports the approximation as a NamedTuple. e.g. see `./notebooks/intro-stan/intro-stan-optimize-01s.jl` and `./notebooks/intro-stan/intro-stan-optimize-02s.jl`:

Examples and comparisons of different ways of computing a quap approximation can be found in `./notebooks/intro-stan/intro-stan-04.jl`."

md"The increasing use of Particles to represent quap approximations is possible thanks to the package [MonteCarloMeasurements.jl](https://github.com/baggepinnen/MonteCarloMeasurements.jl). [Soss.jl](https://github.com/cscherrer/Soss.jl) and [related write-ups](https://cscherrer.github.io) introduced me to that option."


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
	stan1_1 = "
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

begin
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	data = Dict(:N => N, :n => n, :k => k)
	init = Dict(:theta => 0.5)
end;

md"##### Create a quadratic apprximation."

begin
	q1_1s, m1_1s, om = quap("m1.1s", stan1_1; data, init)
	q1_1s
end

md"##### Describe the optimize result"

if !isnothing(om)
  optim_stan, cnames = read_optimize(om)
  optim_stan
end

md"## End of intro/intro-stan-03s.jl"

