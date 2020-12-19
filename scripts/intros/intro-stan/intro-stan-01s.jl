
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize            # Used to compute quadratic approximation
	using StatisticalRethinking
	using PlutoUI
end

md"## Rethinking vs. StatisticalRethinking.jl."

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

md"The author of the book states: *If that (the statistical model) doesn't make much sense, good. ... you're holding the right textbook, since this book teaches you how to read and write these mathematical descriptions* (page 77).

The Pluto notebooks in [StatisticalRethinkingJuliaStan](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl) are intended to allow experimenting with this learning process using [Stan](https://github.com/StanJulia) and [Julia](https://julialang.org).

In the R package `rethinking`, posterior values can be approximated by
 
```
m4.31 <- quap(flist, data=d2)
```

or generated using Stan by:

```
m4.32 <- ulam(flist, data=d2)
```

In StatisticalRethinkingStan, R's ulam() has been replaced by StanSample.jl. This means that much earlier on than in the book, StatisticalRethinkingStan introduces the reader to the Stan language."




md"To help out with this, in this notebook and a few additional notebooks in the subdirectory `notebooks/intro-stan` the Stan language is introduced and the execution of Stan language programs illustrated. Chapter 9 of the book contains a nice introduction to translating the `alist` R models to the Stan language (just before section 9.5)."

md"The equivalent of the R function `quap()` in StatisticalRethinkingStan uses StanOptimize (or, as a further shortcut, the MAP density of the Stan samples) as the mean of the Normal distribution and reports the quap approximation as a NamedTuple. e.g. see `./notebooks/intro-stan/intro-stan-03.jl` and `./notebooks/intro-stan/intro-stan-04.jl`."

md"## Introduction to a Stan Language program"

md"## Intro-stan-01s.jl"

md"Additional context can be found in the cells at the end of this notebook."

md"##### This model represents N experiments each tossing a globe n times and recording the number of times the globe lands on water (`W`) in an array `k`."

md"##### R's `rethinking` model is defined as:
```
flist <- alist(
  theta ~ Uniform(0, 1)
  k ~ Binomial(n, theta)
)
```"

md"##### This model in Stan language could be written as:"

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
}";

md"###### For this model three Stan language blocks are used: data, parameters and the model block."

md"###### The first two blocks define the data and the parameter definitions for the model and at the same time can be used to define constraints. As explained in section 2.3 of the book (*'Components of the model'*), variables can be observable or unobservable. Variables known (chosen or observed) are defined in the data block, parameters are not observed but need to be inferred and are defined in the parameter block."

md"###### We know that k can't be negative (k[i] == 0 indicates the globe never landed on `W` in the n tosses). We also assume at least 1 toss is performed, hence n >= 1. In this example we use N=10 experiments of 9 tosses, thus n = 9 in all trials. k[i] is the number of times the globe lands on water in each experiment."

md"###### N, n and the vector k[N] and are all integers."

md"###### In this golem, theta, the fraction of water on the globe surface, is assumed to generate the probability a toss lands on `W`. Theta cannot be observed and is the parameter of interest. We know this probability is between 0 an 1. Thus theta is also constrained in the parameters block. Theta is a real number."

md"###### The third block is the actual model and is pretty much identical to R's alist."

md"###### Note that unfortunately the names of distributions such as Normal and Binomial are not identical between Stan, R and Julia. The Stan language uses the Stan convention (starts with lower case). Also, each Stan language statement ends with a `;`"

md"##### Running a Stan language program in Julia."

md"###### Once the Stan language model is defined, in this case stored in the Julia variable stan1_1, below steps execute the program:"

md"##### 1. Create a Stanmodel object:"

m1_1s = SampleModel("m1.1s", stan1_1);

md"##### 2. Simulate the results of N repetitions of 9 tosses."

begin
	N = 10                        # Number of globe toss experiment
	d = Binomial(9, 0.66)         # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                # Simulate 15 trial results
	n = 9                         # Each experiment has 9 tosses
end;

md"##### 3. Input data in the form of a Dict"

m1_1_data = Dict("N" => N, "n" => n, "k" => k)

md"##### 4. Sample using stan_sample."

rc1_1s = stan_sample(m1_1s, data=m1_1_data);

md"##### 5. Describe and check the results"

if success(rc1_1s)
  post1_1s_df = read_samples(m1_1s; output_format=:dataframe)
end;

PRECIS(post1_1s_df)

md"###### Sample Particles summary:"

part1_1s = read_samples(m1_1s; output_format=:particles)

md"The increasing use of Particles to represent quap-like approximations is possible thanks to the package [MonteCarloMeasurements.jl](https://github.com/baggepinnen/MonteCarloMeasurements.jl). [Soss.jl](https://github.com/cscherrer/Soss.jl) and [related write-ups](https://cscherrer.github.io) introduced me to that option."

md"###### NamedTuple representation of quap estimate:"

begin
	data = m1_1_data
	init = Dict(:theta => 0.5)
	q1_1s, sm, om = quap("m1.1s", stan1_1; data, init)
	q1_1s
end

begin
	quap1_1s_df = sample(q1_1s)
	PRECIS(quap1_1s_df)
end

md"##### Check the chains using MCMCChains.jl"

begin
	chns1_1s = read_samples(m1_1s; output_format=:mcmcchains)
	
	# Display the chns
	
	CHNS(chns1_1s)
end

md"##### Plot the chains."

plot(chns1_1s; seriestype=:traceplot)

plot(chns1_1s; seriestype=:density)

md"##### Display the stansummary result"

success(rc1_1s) && read_summary(m1_1s)

md"## End of intros/intro-stan-01s.jl"

