
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

for i in 1:3
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

md"## Clip-05-12s.jl"

md"##### Include models [`m5_1s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.1s.jl), [`m5_2s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.2s.jl) and [`m5_3s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.3s.jl):"

md"##### The model m5.3s represents a regression of Divorce on both Marriage rate and MedianAgeMarriage and is defined as:"

md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bA ~ normal(0, 0.5);
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A + bM * M;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

md"##### D (Divorce rate), M (Marriage rate) and A (MediumAgeMarriage) are all standardized."

md"##### Normal estimates:"

if success(rc)
	(s1, p1) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM];
    title="Particles (Normal) estimates")
	p1
end

s1

md"##### Quap estimates:"

if success(rc)
	(s2, p2) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM];
    title="Quap estimates", func=quap)
	p2
end

s2

md"##### The simulations as in R code 5.12 will be included in StructuralCausalModels.jl."

md"## End of clip-05-12s.jl"

