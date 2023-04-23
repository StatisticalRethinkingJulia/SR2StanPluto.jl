## Purpose of SR2StanPluto.jl

As stated many times by the author in his [online lectures](https://www.youtube.com/watch?v=ENxTrFf9a7c&list=PLDcUM9US4XdNM4Edgs7weiyIguLSToZRI), StatisticalRethinking is a hands-on course. This project is intended to assist with the hands-on aspect of learning the key ideas in StatisticalRethinking. 

SR2StanPluto is a Julia project that uses Pluto notebooks for this purpose. Each notebook demonstrates Julia versions of `code snippets` and `mcmc models` contained in the R package "rethinking" associated with the book [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/) by Richard McElreath.

This Julia project uses Stan (the `cmdstan` executable) as the underlying mcmc implementation. Please see Stan.jl and/or StanSample.jl for details.

## Important note

From v5 onwards the basis will no longer be StatisticalRethinking.jl but RegressionAndOtherStories.jl. Both packages have very similar content, but StatisticalRethinking.jl uses Plots.jl while RegressionAndOtherStories.jl is using (Cairo)Makie.jl.

Tagged version 4.2.0 is the last more or less complete set of scripts covering `the old` chapters 1 to 11.

## Using Pluto's package management (or not!)

For development purposes most notebooks include a line like `#Pkg.activate("~/.julie/dev/SR2StanPluto"))`. On the repo it is commented out. While developing code I typically run notebooks inside a project environment (by uncommenting that line).

## Usage

To (locally) reproduce and use this project, do the following:

1. Download this [project](https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl) from Github and move to the downloaded directory, e.g.:

```
$ cd ./julia/dev
$ git clone https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl SR2StanPluto
$ cd SR2StanPluto
```
Or select a particular tagged version, i.e. `...//SR2StanPluto.jl@4.2.0 ...`.

The next step assumes your `basic` Julia environment includes `Pkg` and `Pluto`.

2. Start a Pluto notebook server.
```
$ cd notebooks
$ julia

julia> using Pluto
julia> Pluto.run()
```
3. A Pluto page should open in a browser.

4. Select a notebook in the `open a file` entry box, e.g. type `./` and select a notebook. 

## Usage details

All "rethinking" data files are stored and maintained in StatisticalRethinking.jl and can be accessed via `sr_datadir(...)`. See `notebooks/00-Preface.jl` for an example.

In scripts, for naming models and results of simulations I tend to use:

Models and results:

0. stan5_1           : Stan language program
1. m5_1s             : The sampled StanSample model
2. q5_1s             : Stan quap model (NamedTuple similar to Turing)

Draws:

3. chns5_1s          : MCMCChains object (4000 samples from 4 chains)
4. part5_1s          : Stan samples (Particles notation)
5. quap5_1s          : Quap samples (Particles notation)
6. nt5_1s            : NamedTuple with samples values
7. ka5_1s            : KeyedArray object (see AxisArrays.jl)
8. da5_1s            : DimArray object (see DimensionalData.jl)
9. st5_1s            : StanTable 0bject (see Tables.jl)
10. i5_1s            : InferenceObjects (see InferenceObjects.jl)

The default for `read_samples(m1_1s)` is a StanTable chains object.

Results as a DataFrame:

10. prior5_1s_df      : Prior samples (DataFrame)
11. post5_1s_df       : Posterior samples (DataFrame)
12. quap5_1s_df       : Quap approximation to posterior samples (DataFrame)
13. pred5_1s_df       : Posterior predictions (DataFrame)

The `s` at the end indicates Stan.

By default `read_samples(m5_1s)` returns a StanTable with the results. In general
it is safer to specify the desired format, i.e. `read_samples(m5_1s, :table)` as
the Julia eco-sytem is still evolving rapidly with new options.

Using `read_samples(m5_1s, :...)` makes it easy to convert samples to other formats.

In version 5 I expect to mainly use the output_formats :dataframe and :namedtuple.

For InferenceObjects.jl there is a separate function `inferencedata(m1_1s)`. 
See the Notebook_Examples in Stan.jl for an example Pluto notebook.

See the project maintenance section in the Readme of RegressionAndOtherStories.jl for a note on using projects environments instead of Pluto's package management features.

## Status

SR2StanPluto.jl is compatible with the 2nd edition of the book.

In v5.3.0 StructuralCausalModels.jl is repaced by CausalInference.jl as an extension. To display DAGs, GraphViz.jl and CairoMakie.jl are used.

ParetoSmoothedImportanceSampling.jl are included as experimental dependencies in the StatisticalRethinking.jl v3+ package.

Definitely WIP! See also below version 5 info.

Any feedback is appreciated. Please open an issue.

## Acknowledgements

Of course, without the excellent textbook by Richard McElreath, this project would not have been possible. The author has also been supportive of this work and gave permission to use the datasets.

This repository and format is influenced by previous versions of StatisticalRethinking.jl, work by Karajan, Max Lapan and many other contributors.

## Versions

### Version 5.4.0-5.5.1

1. Further updates in using CausalInference and GraphViz.

### Version 5.3

1. Switch to (Cairo)Makie.jl, Graphs.jl, CausalInference.jl, GraphViz.jl (and more probably).

### Version 5

1. Version 5 is a breaking change!
2. A new look is taken at packages available in the Julia ecosystem.

### Version 4

1. SR2StanPluto v4+ requires StatisticalRethinking v4+.

### versions 2 & 3

1. Many additions for 2nd edition of Statistical Rethinking book.
2. Version 3 switched to using StanSample and StanQuap

### Version 1

1. Initial versions (late Nov 2020).

