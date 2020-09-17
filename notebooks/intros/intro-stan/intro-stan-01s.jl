### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 38677642-f1dd-11ea-2537-59511c140dab
using Pkg, DrWatson

# ╔═╡ 5d9316ec-f1dd-11ea-1c0d-0d8566ab3a90
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
	using PlutoUI
end

# ╔═╡ c7dd5b98-f1dd-11ea-168c-07c643e283a7
md"## Introduction to a Stan Language program"

# ╔═╡ 57f0ec9a-f913-11ea-2e7e-ad16a359b82d
md"## Intro-stan-01s.jl"

# ╔═╡ e1794cb4-f758-11ea-0888-9d7ce10db48f
md"Additional context can be found in the cells at the end of this notebook."

# ╔═╡ d12eb360-f1ea-11ea-1a2f-fd69805cb4b4
md"##### This model represents N experiments each tossing a globe n times and recording the number of times the globe lands on water (`W`) in an array `k`."

# ╔═╡ c265df40-f1de-11ea-3eaf-795a1560b5af
md"##### R's `rethinking` model is defined as:
```
flist <- alist(
  theta ~ Uniform(0, 1)
  k ~ Binomial(n, theta)
)
```"

# ╔═╡ 0bf971c6-f1df-11ea-1f57-41937efd2e21
md"##### This model in Stan language could be written as:"

# ╔═╡ 5da2632c-f1dd-11ea-2d50-9d80cda7b1ed
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
}";

# ╔═╡ 5da326d6-f1dd-11ea-17f5-e9341ab2118c
md"###### For this model three Stan language blocks are used: data, parameters and the model block."

# ╔═╡ 1a1a5292-f1e0-11ea-14db-4989e6acb15a
md"###### The first two blocks define the data and the parameter definitions for the model and at the same time can be used to define constraints. Data is known (chosen or observed), parameters are often not observed or even observable."

# ╔═╡ d12f1c4c-f1ea-11ea-1c5f-ab52ceca9c68
md"###### We know that k can't be negative (k == 0 indicates in the n tosses of an experiment the globe never landed on `W`). We also assume at least 1 toss is performed, hence n >= 1. In this example we use N=10 experiments of 9 tosses, thus n = 9 in all trials. k is the number of times the globe lands on water in each experiment."

# ╔═╡ d13a6034-f1ea-11ea-101e-c13a5918086f
md"###### N, n and the vector k[N] and are all integers."

# ╔═╡ d1441b68-f1ea-11ea-38f4-6bddd7e002b1
md"###### In this golem, theta, the fraction of water on the globe surface, is assumed to generate the probability a toss lands on `W`. Theta cannot be observed and is the parameter of interest. We know this probability is between 0 an 1. Thus theta is also constrained in the parameters block. Theta is a real number."

# ╔═╡ d156ce40-f1ea-11ea-09ee-65173a8eaa15
md"###### The third block is the actual model and is pretty much identical to R's alist."

# ╔═╡ d1639a94-f1ea-11ea-1df0-e11a07650af5
md"###### Note that unfortunately the names of distributions such as Normal and Binomial are not identical between Stan, R and Julia. The Stan language uses the Stan convention (starts with lower case). Also, each Stan language statement ends with a `;`"

# ╔═╡ 1a30c9b4-f1ea-11ea-0fef-cfcb7bc6a6af
md"##### Running a Stan language program in Julia."

# ╔═╡ 459f3540-f1ea-11ea-21da-9bf2ec949773
md"###### Once the Stan language model is defined, in this case stored in the Julia variable m1_1, below steps execute the program:"

# ╔═╡ 4b81f25e-f1ea-11ea-0f34-99192ddea9ad
md"##### 1. Create a Stanmodel object:"

# ╔═╡ a9af402c-f1de-11ea-2ad7-39922b622327
sm = SampleModel("m1.1s", m1_1);

# ╔═╡ ffdf3090-f1ea-11ea-084a-dda8c4d1a68c
md"##### 2. Simulate the results of N repetitions of 9 tosses."

# ╔═╡ 5daf1ed2-f1dd-11ea-1f3d-1909cc196f7a
begin
	N = 10                        # Number of globe toss experiment
	d = Binomial(9, 0.66)         # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                # Simulate 15 trial results
	n = 9                         # Each experiment has 9 tosses
end;

# ╔═╡ 5dcb2868-f1dd-11ea-389c-ff32a30fddc2
md"##### 3. Input data in the form of a Dict"

# ╔═╡ 49b87dde-f1eb-11ea-0ee1-67edf7b90b1c
m1_1_data = Dict("N" => N, "n" => n, "k" => k)

# ╔═╡ 5dd4b36a-f1dd-11ea-11af-a946fb4ac07a
md"##### 4. Sample using stan_sample."

# ╔═╡ 6f463898-f1eb-11ea-16f1-0b6de4bd69c4
rc = stan_sample(sm, data=m1_1_data);

# ╔═╡ 5ddf4cf6-f1dd-11ea-388f-77f48ba93c39
md"##### 5. Describe and check the results"

# ╔═╡ 73d0dd98-f1ec-11ea-2499-477a8024ecc6
if success(rc)
  dfs = read_samples(sm; output_format=:dataframe)
end;

# ╔═╡ 208e7a70-f1ec-11ea-3ba9-d5e8c8c00553
md"###### Sample Particles summary:"

# ╔═╡ cfe9027e-f1ec-11ea-33df-65cd05965437
p = Particles(dfs); p

# ╔═╡ cfe95fee-f1ec-11ea-32a1-bbf3633ab8e7
md"###### Quap Particles estimate:"

# ╔═╡ cfea40dc-f1ec-11ea-248e-9d1c3b0a0180
q = quap(dfs); q

# ╔═╡ d0006f7c-f1ec-11ea-3361-9baae166396a
md"##### Check the chains using MCMCChains.jl"

# ╔═╡ 1ce58ec6-f1ed-11ea-1c05-99a463481fd8
chn = read_samples(sm; output_format=:mcmcchains)

# ╔═╡ 2c465b0a-f1ed-11ea-35e3-017075244cd8
md"##### Plot the chains."

# ╔═╡ d00180d8-f1ec-11ea-0d29-350fac31122f
plot(chn; seriestype=:traceplot)

# ╔═╡ 3db08936-f914-11ea-1d74-d33b946ef534
plot(chn; seriestype=:density)

# ╔═╡ d00c24de-f1ec-11ea-1c83-cb2584421f6f
md"##### Display the stansummary result"

# ╔═╡ 0e3309b2-f1ed-11ea-0d57-2f0e5b83c8dd
success(rc) && read_summary(sm)

# ╔═╡ 45929f5a-f759-11ea-1955-67ba740778e6
md"## Rethinking vs. StatisticalRethinking.jl."

# ╔═╡ e27ece36-f756-11ea-250c-99d909d390f9
md"In the book and associated R package `rethinking`, statistical models are defined as illustrated below:

```
flist <- alist(
  height ~ dnorm( mu , sigma ) ,
  mu <- a + b*weight ,
  a ~ dnorm( 156 , 100 ) ,
  b ~ dnorm( 0 , 10 ) ,
  sigma ~ dunif( 0 , 50 )
)
```
"

# ╔═╡ 8819279a-f757-11ea-37ee-f7b0a267d351
md"The author of the book states: *If that (the statistical model) doesn't make much sense, good. ... you're holding the right textbook, since this book teaches you how to read and write these mathematical descriptions* (page 77).

The Pluto notebooks in [StatisticalRethinkingJuliaStan](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl) are intended to allow experimenting with this learning process using [Stan](https://github.com/StanJulia) and [Julia](https://julialang.org).

In the R package `rethinking`, posterior values can be approximated by
 
```
# Simulate quadratic approximation (for simpler models)
m4.31 <- quap(flist, data=d2)
```

or generated using Stan by:

```
# Generate a Stan model and run a simulation
m4.32 <- ulam(flist, data=d2)
```

In StatisticalRethinkingStan, R's ulam() has been replaced by StanSample.jl. This means that much earlier on than in the book, StatisticalRethinkingStan introduces the reader to the Stan language."




# ╔═╡ 55ed2bde-f756-11ea-1f1d-7fbdf76c1b76
md"To help out with this, in this notebook and a few additional notebooks in the subdirectory `notebooks/intro-stan` the Stan language is introduced and the execution of Stan language programs illustrated. Chapter 9 of the book contains a nice introduction to translating the `alist` R models to the Stan language (just before section 9.5)."

# ╔═╡ 2e4c633e-f75a-11ea-2bcb-fb9800e518af
md"The equivalent of the R function `quap()` in StatisticalRethinkingStan uses the MAP density of the Stan samples as the mean of the Normal distribution and reports the approximation as a NamedTuple. e.g. from `./scripts/04-part-1/clip-31.jl`:
```
if success(rc)
  println()
  df = read_samples(sm; output_format=:dataframe)
  q = quap(df)
  q |> display
end
```
returns:
```
(mu = 178.0 ± 0.1, sigma = 24.5 ± 0.94)
```
To obtain the mu quap:
```
q.mu
```
Examples and comparisons of different ways of computing a quap approximation can be found in `notebooks/intro-stan/intro-stan-04.jl`."



# ╔═╡ b82e2e82-f757-11ea-2696-6f294e3070f5
md"The increasing use of Particles to represent quap approximations is possible thanks to the package [MonteCarloMeasurements.jl](https://github.com/baggepinnen/MonteCarloMeasurements.jl). [Soss.jl](https://github.com/cscherrer/Soss.jl) and [related write-ups](https://cscherrer.github.io) introduced me to that option."

# ╔═╡ 5de8c1c8-f1dd-11ea-1b97-5bbb6c6316ae
md"## End of intros/intro-stan-01s.jl"

# ╔═╡ Cell order:
# ╟─c7dd5b98-f1dd-11ea-168c-07c643e283a7
# ╟─57f0ec9a-f913-11ea-2e7e-ad16a359b82d
# ╟─e1794cb4-f758-11ea-0888-9d7ce10db48f
# ╠═38677642-f1dd-11ea-2537-59511c140dab
# ╠═5d9316ec-f1dd-11ea-1c0d-0d8566ab3a90
# ╟─d12eb360-f1ea-11ea-1a2f-fd69805cb4b4
# ╟─c265df40-f1de-11ea-3eaf-795a1560b5af
# ╟─0bf971c6-f1df-11ea-1f57-41937efd2e21
# ╠═5da2632c-f1dd-11ea-2d50-9d80cda7b1ed
# ╟─5da326d6-f1dd-11ea-17f5-e9341ab2118c
# ╟─1a1a5292-f1e0-11ea-14db-4989e6acb15a
# ╟─d12f1c4c-f1ea-11ea-1c5f-ab52ceca9c68
# ╟─d13a6034-f1ea-11ea-101e-c13a5918086f
# ╟─d1441b68-f1ea-11ea-38f4-6bddd7e002b1
# ╟─d156ce40-f1ea-11ea-09ee-65173a8eaa15
# ╟─d1639a94-f1ea-11ea-1df0-e11a07650af5
# ╟─1a30c9b4-f1ea-11ea-0fef-cfcb7bc6a6af
# ╟─459f3540-f1ea-11ea-21da-9bf2ec949773
# ╟─4b81f25e-f1ea-11ea-0f34-99192ddea9ad
# ╠═a9af402c-f1de-11ea-2ad7-39922b622327
# ╠═ffdf3090-f1ea-11ea-084a-dda8c4d1a68c
# ╠═5daf1ed2-f1dd-11ea-1f3d-1909cc196f7a
# ╟─5dcb2868-f1dd-11ea-389c-ff32a30fddc2
# ╠═49b87dde-f1eb-11ea-0ee1-67edf7b90b1c
# ╟─5dd4b36a-f1dd-11ea-11af-a946fb4ac07a
# ╠═6f463898-f1eb-11ea-16f1-0b6de4bd69c4
# ╟─5ddf4cf6-f1dd-11ea-388f-77f48ba93c39
# ╠═73d0dd98-f1ec-11ea-2499-477a8024ecc6
# ╟─208e7a70-f1ec-11ea-3ba9-d5e8c8c00553
# ╠═cfe9027e-f1ec-11ea-33df-65cd05965437
# ╟─cfe95fee-f1ec-11ea-32a1-bbf3633ab8e7
# ╠═cfea40dc-f1ec-11ea-248e-9d1c3b0a0180
# ╟─d0006f7c-f1ec-11ea-3361-9baae166396a
# ╠═1ce58ec6-f1ed-11ea-1c05-99a463481fd8
# ╟─2c465b0a-f1ed-11ea-35e3-017075244cd8
# ╠═d00180d8-f1ec-11ea-0d29-350fac31122f
# ╠═3db08936-f914-11ea-1d74-d33b946ef534
# ╟─d00c24de-f1ec-11ea-1c83-cb2584421f6f
# ╠═0e3309b2-f1ed-11ea-0d57-2f0e5b83c8dd
# ╟─45929f5a-f759-11ea-1955-67ba740778e6
# ╟─e27ece36-f756-11ea-250c-99d909d390f9
# ╟─8819279a-f757-11ea-37ee-f7b0a267d351
# ╟─55ed2bde-f756-11ea-1f1d-7fbdf76c1b76
# ╟─2e4c633e-f75a-11ea-2bcb-fb9800e518af
# ╟─b82e2e82-f757-11ea-2696-6f294e3070f5
# ╟─5de8c1c8-f1dd-11ea-1b97-5bbb6c6316ae
