## Purpose of StatisticalRethinkingStan.jl

As stated many times by the author in his [online lectures](https://www.youtube.com/watch?v=ENxTrFf9a7c&list=PLDcUM9US4XdNM4Edgs7weiyIguLSToZRI), StatisticalRethinking is a hands-on course. This project is intended to assist with the hands-on aspect of learning the key ideas in StatisticalRethinking. 

StatisticalRethinkingStan is a Julia project that uses Pluto notebooks for this purpose. Each notebook demonstrates Julia versions of `code snippets` and `mcmc models` contained in the R package "rethinking" associated with the book [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/) by Richard McElreath.

This Julia project uses Stan (the `cmdstan` executable) as the underlying mcmc implementation. A companion project ( [StatisticalRethinkingTuring.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingTuring.jl) ) uses Turing.jl.

## Installation

To (locally) reproduce and use this project, do the following:

1. Download this [project](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl) from Github and move to the downloaded directory, e.g.:

```
$ git clone https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl
$ cd StatisticalRethinkingStan.jl
$ julia
```
and in the Julia REPL:

```
julia> ]                                        # Actvate Pkg mode
(@v1.5) pkg> activate .                         # Activate pkg in .
(StatisticalRethinkingStan) pkg> instantiate    # Install in pkg environment
(StatisticalRethinkingStan) pkg> <delete>       # Exit package mode
julia>
```

The next step assumes your Julia setup includes `Pkg`, `DrWatson`, `Pluto` and `PlutoUI`.

2. Start a Pluto notebook server.
```
$ julia

julia> using Pluto
julia> Pluto.run()
```

3. A Pluto page should open in a browser.

Select a notebook in the `open a file` entry box, e.g. type `./` and step to `./notebooks/00/clip-00-01-03s.jl`. All notebooks will activate the project `StatisticalRethinkingStan`.

## Usage

Note: *StatisticalRethinkingStan v1.1 requires StatisticalRethinking.jl v 3.1.*

StatisticalRethinkingStan.jl is a DrWatson project, with some added/re-purposed subdirectories:

1. `models`, which contains a subset of the Stan language models,
2. `notebooks`, used to store the Pluto notebooks and
3. `scripts`, Julia scripts (generated from the notebooks).

The `data` directory, in DrWatson accessible through `datadir()`, can be used for locally generated data, exercises, etc. All "rethinking" data files are stored and maintained in StatisticalRethinking.jl and can be accessed via `sr_datadir(...)`.

The scripts in the `scripts` subdirectory are directly generated from the notebooks and thus adhere to Pluto's programming restrictions.

This leads to a typical set of opening lines in each notebook:
```
using Pkg, DrWatson

# Note: Below sequence is important. First activate the project
# followed by `using` or `import` statements. Pretty much all
# scripts use StatisticalRethinking. If mcmc sampling is
# needed, it must be loaded before StatisticalRethinking:

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StanOptimize              # If quap() is used.
using StatisticalRethinking

# To access e.g. the Howell1.csv data file:
df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
df = df[df.age .>= 18, :]
```

## Naming conventions

All R snippets (fragments) have been organized in clips. Each clip is a notebook.

Clips are named as `clip-cc-fs-ls[s|t|d].jl` where

* `cc`               : Chapter number
* `fs`               : First snippet in clip
* `ls`               : Last snippet in clip
* `[s|sl|t|d|m]`     : Mcmc flavor used (s : Stan, t : Turing)

Note: `d` is reserved for a combination Soss/DynamicHMC, `sl` is reserved for Stan models using the `logpdf` formulation and `m` for Mamba.

The notebooks containing the clips are stored by chapter. In addition to clips, in the early notebook chapters (0-3) it is also shown how to create some of the figures in the book, e.g. `Fig2.5s.jl` in `notebooks/chapter/02`.

Special introductory notebooks have been included in `notebooks/intros`, e.g.
`intro-stan/intro-stan-01s.jl` and `intro-R-users/distributions.jl`. It is suggested to at least glance over the `intro-stan` notebooks.

Great introductory notebooks showing Julia and statistics ( based on the [Statistics with Julia](https://statisticswithjulia.org/index.html) book ) can be found in [StatisticsWithJuliaPlutoNotebooks](https://github.com/StatisticalRethinkingJulia/StatisticsWithJuliaPlutoNotebooks.jl).

One goal for the changes in StatisticalRethinking v3 was to make it easier to compare and mix and match results from different mcmc implementations. Hence consistent naming of models and results is important. The models and the results of simulations are stored as follows:

Models:

0. stan5_1           : Stan language program
1. m5_1s             : The sampled StanSample model
2. q5_1s             : Stan quap model (NamedTuple similar to Turing)

Draws:

3. chns5_1s          : MCMCChains object (4000 samples from 4 chains)
4. part5_1s          : Stan samples (Particles notation)

Results as a DataFrame:

5. prior5_1s_df      : Prior samples (DataFrame)
6. post5_1s_df       : Posterior samples (DataFrame)
7. quap5_1s_df       : Quap approximation to posterior samples (DataFrame)
8. pred5_1s_df       : Posterior predictions (DataFrame)

As before, the `s` at the end indicates Stan.

Most models in the `models` subdirectory return 0, 1 and 4 out of the box. But `read_samples(m5_1s; output_format=:...)` makes it easy to create MCMCChains.jl Chains objects, a DataFrame with draws or a MonteCarloMeasurements.jl Particles object (item 4 in above list).

## Status

StatisticalRethinkingStan.jl is compatible with the 2nd edition of the book. Version 1.0.0 covers pretty much the same as StatisticalRethinking.jl v2.2.9+.

Expanded coverage of chapters 7 remains WIP. Examples of Stan language models in the later chapters can be found in the `models` sub-directory

StructuralCausalModels.jl is included as en experimental dependency in the StatisticalRethinking.jl v3 package. Definitely WIP!

Any feedback is appreciated. Please open an issue.

## Acknowledgements

Of course, without the excellent textbook by Richard McElreath, this package would not have been possible. The author has also been supportive of this work and gave permission to use the datasets.

This repository and format is derived from work by Karajan, previous versions of StatisticalRethinking.jl and many other contributors.

### Version 1.0.0

1. Initial version (late Nov 2020).

