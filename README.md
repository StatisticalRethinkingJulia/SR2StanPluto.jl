## Purpose of StatisticalRethingStan.jl

This `project` contains Julia versions of selected `code snippets` and `mcmc models` contained in the R package "rethinking" associated with the book [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/) by Richard McElreath.

As stated many times by the author in his [online lectures](https://www.youtube.com/watch?v=ENxTrFf9a7c&list=PLDcUM9US4XdNM4Edgs7weiyIguLSToZRI), StatisticalRethinking is a hands-on course. This project is intended to assist with the hands-on aspect of learning the key ideas in StatisticalRethinking and particularly the Pluto notebooks are well suited for this purpose.

This Julia project uses Stan (the `cmdstan` executable) as the underlying mcmc implementation.

## Usage

StatisticalRethinkingStan.jl is a DrWatson project, with some added/re-purposed subdirectories:

1. `models`, which contains the Stan language models,
2. `notebooks`, used to store Pluto notebooks and
3. `exercises`, can be used to store the exercises (not stored in the StatisticalRethinkingStan.jl repository)

The `data` directory is only used for locally generated data, exercises, etc.

All example data files are stored and maintained in StatisticalRethinking.jl and can be accessed via `sr_datadir()`. 

This leads to a typical set of opening lines in each script:
```
using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"

# Note: below sequence is important
# A loaded StanSample influences StatisticalRethinking
 
using StanSample
using StatisticalRethinking

# To access e.g. the Howell1.csv data file:
d = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
d2 = d[d.age .>= 18, :]
```

To (locally) reproduce and use this project, do the following:

1. Download this [project](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl) from Github.
2. Move to the downloaded directory.
3. Open a Julia console and, to run the first script, do:
   ```
   julia> include(scriptsdir("00", "clip-00-01-03s.jl"))
   ```

This assumes your Julia setup includes `Pkg` and `DrWatson`. Step 3 activates project `StatisticalrethinkingStan`, if needed includes some source files, and everything should work out of the box.

For the notebooks you'll need to install Pluto.jl and PlutoUI.jl, e.g.:
```
] add Pluto PlutoUI
```

## Setup

All R snippets (fragments) have been organized in clips. Each clip is a self standing script. Clips are named as `clip-cc-fs-ls[s|t|d].jl` where

`cc`      : Chapter number
`fs`      : First snippet in clip
`ls`      : Last snippet in clip
`[s|t|d]` : Mcmc flavor used (s : Stan, t : Turing)

Note: `d` is reserved for a combination Soss/DynamicHMC.

Scripts containing the clips are stored by chapter.

Models and Pluto notebooks directories are also organized by chapter.

Special introductory notebooks have been included in `notebooks/intros`, e.g.
`intro-stan/intro-stan-01.jl` and `intro-R-users/distributions.jl`.

Scripts that generate important figures in the book are in the `plots` subdirectory, again store by chapter. The figures also right there with extension `/png`.


## Status

StatisticalRethinkingStan.jl is compatible with the 2nd edition of the book.

Expanded coverage of chapters 7 and beyond of the book will likely happen while working on StatisticalRethinkingStan.jl.

StructuralCausalModels.jl is included as en experimental dependency in the otherwise stripped down StatisticalRethinking.jl v3.0.0 package.

Any feedback is appreciated. Please open an issue.

## Acknowledgements

This repository and format is derived from work by Karajan, previous versions of StatisticalRethinking.jl and many other contributors.

The huge progress made by the Turing.jl team over the last 2 years, the availability of Julia `projects` in addition to Julia `packages` and the novel approach to notebooks in Pluto.jl were a few of the ideas that triggered exploring a new setup for the StatisticalRethinkingJulia.

## Versions

### Version 0.1.0 (in preparation, expected Oct 2020)

1. Initial version

