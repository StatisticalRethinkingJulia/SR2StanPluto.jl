## Purpose of this project

This project contains Julia versions of selected `code snippets` and `mcmc models` contained in the R package "rethinking" associated with the book [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/) by Richard McElreath.

As stated many times by the author in his [online lectures](https://www.youtube.com/watch?v=ENxTrFf9a7c&list=PLDcUM9US4XdNM4Edgs7weiyIguLSToZRI), StatisticalRethinking is a hands-on course. This project is intended to assist with that aspect of learning the key ideas in StatisticalRethinking.

This project uses Stan as the underlying mcmc implementation. Another [project](https://github.com/karajan9/statisticalrethinking) is exploring the use of Turing.jl.

## Usage

StatisticalRethinkingStan.jl is a DrWatson project, with some added subdirectories:

1. `models`, which will contain the Stan models used in the chapters scripts,
2.  `notebooks`, used to store Pluto notebooks, and
3.  `exercises`, can be used to store the exercises (not stored on the StatisticalRethinking/StatitsticalRethinkingStan reposotory)

It is authored by Goedman and Karajan.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> include(joinpath("path/to/this/project", "scripts", "00", "clip-00-01-03.jl")
   ```

This will install all necessary packages for you to be able to run the script and
everything should work out of the box.

## Usage

StatisticalRethinkingStan.jl is compatible with the 2nd edition of the book.

Expanded coverage of chapters 7 and beyond of the book will likely happen while working on StatisticalRethinkingStan.jl (as I got seriously sidetracked working on [StructuralCausalModels.jl](https://github.com/StatisticalRethinkingJulia/StructuralCausalModels.jl)). StructuralCausalModels.jl is included as en experimental dependency in the StatisticalRethinkingStan.jl project.

Any feedback is appreciated. Please open an issue.

## Versions

### Version 0.1.0 (in preparation)

1. Initial version

## Introduction

In the book and associated R package `rethinking`, statistical models are defined as illustrated below:

```
flist <- alist(
  height ~ dnorm( mu , sigma ) ,
  mu <- a + b*weight ,
  a ~ dnorm( 156 , 100 ) ,
  b ~ dnorm( 0 , 10 ) ,
  sigma ~ dunif( 0 , 50 )
)
```

Posterior values can be approximated by
 
```
# Simulate quadratic approximation (for simpler models)
m4.31 <- quad(flist, data=d2)
```

or generated using Stan by:

```
# Generate a Stan model and run a simulation
m4.32 <- ulam(flist, data=d2)
```

The author of the book states: "*If that (the statistical model) doesn't make much sense, good. ... you're holding the right textbook, since this book teaches you how to read and write these mathematical descriptions*" (page 77).

[StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl) is intended to allow experimenting with this learning process using [StanJulia](https://github.com/StanJulia).

## Rethinking `rethinking`

There are a few important differences between `rethinking` and `StatisticalRethinking.jl`:

1. StatisticalRethinkingStan.jl, ulam() has been replaced by StanSample.jl.

This means that much earlier on than in the book, StatisticalRethinking.jl introduces the reader to the Stan language.

To help out with this, in the subdirectory `scripts/03/intro-stan` the Stan language is introduced and the execution of Stan language programs illustrated. Chapter 9 of the book contains a nice introduction to translating the `alist` R models to the Stan language (just before section 9.5).

To check the chains produced MCMCChains.jl can be used, e.g. see the scripts in chapter 5.

2. The equivalent of the R function `quap()` in StatisticalRethinking.jl v2.0 uses the MAP density of the Stan samples as the mean of the Normal distribution and reports the approximation as a NamedTuple. e.g. from `scripts/04-part-1/clip-31.jl`:
```
if success(rc)
  df = read_samples(sm; output_format=:dataframe)
  q = quap(df)
  q |> display
end
```
returns:
```
(mu = 178.0 ± 0.1, sigma = 24.5 ± 0.94)
```

The above call to read_samples(...) appends all chains in a single dataframe. To retrieve the chains in separate dataframes ( `Vector{DataFrames}` ) use:
```
df = read_samples(sm; output-Format=:dataframes)
```

To obtain the mu quap:
```
q.mu
```

To obtain the samples:
```
q.mu.particles
```

Examples and comparisons of different ways of computing a quap approximation can be found in `scripts/03/intro-stan/intro-part-4.jl`.

3. In `scripts/04-part-1` an additional section has been added, `intro-logpdf` which introduces an alternative way to compute the MAP (quap) using Optim.jl. This kind of builds on the logpdf formulation introduced in `scripts/03/intro-stan/intro-part-4.jl`

4. In `scripts/09` an additional intro section has been included, `scripts/09/intro-dhmc`. It is envisage that a future version of StatisticalRethinking.jl will be based on DynamicHMC.jl. No time line has been set for this work.

## Layout of the package

Instead of having all snippets in a single file, the snippets are organized by chapter and grouped in clips by related snippets. E.g. chapter 0 of the R package has snippets 0.1 to 0.5. Those have been combined into 2 clips:

1. `clip-01-03.jl` - contains snippets 0.1 through 0.3
2. `clip-04-05.jl` - contains snippets 0.4 and 0.5.

A single snippet clip will be referred to as `03/clip-02.jl`.

As mentioned above, a few chapters contain additional scripts intended as introductions for specific topics.

### Data Access

If you want to use this package as an easy way to access the dataset samples, the package offers the function `rel_path` to work with paths inside the StatisticalRethinking package:

```julia

using StatisticalRethinking

# for example, grabbing the `Howell1` dataset used in Chapter 4
datapath = rel_path("..", "data/","Howell1.csv") 
df = DataFrame(CSV.read(datapath))
```

## Other packages in the StatisticalRethinkingJulia Github organization

Implementations of the models using Stan, DynamicHMC and Turing can be found in [StanModels](https://github.com/StatisticalRethinkingJulia/StanModels.jl), [DynamicHMCModels](https://github.com/StatisticalRethinkingJulia/DynamicHMCModels.jl) and [TuringModels](https://github.com/StatisticalRethinkingJulia/TuringModels.jl).

In the meantime time, Chris Fisher has made tremendous progress with [MCMCBenchmarks.jl](https://github.com/StatisticalRethinkingJulia/MCMCBenchmarks.jl), which compares three NUTS mcmc options.
