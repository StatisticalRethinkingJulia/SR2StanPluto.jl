## Purpose of this package

This project contains Julia versions of selected `code snippets` and `mcmc models` contained in the R package "rethinking" associated with the book [Statistical Rethinking](https://xcelab.net/rm/statistical-rethinking/) by Richard McElreath.

As stated many times by the author in his [online lectures](https://www.youtube.com/watch?v=ENxTrFf9a7c&list=PLDcUM9US4XdNM4Edgs7weiyIguLSToZRI), StatisticalRethinking is a hands-on course. This project is intended to assist with that aspect of learning the key ideas in StatisticalRethinking.

This project uses Stan as the underlying mcmc implementation. Another [project](https://github.com/karajan9/statisticalrethinking) is exploring the use of Turing.jl.

## Usage

StatisticalRethinkingStan.jl is a DrWatson project, with an added subdirectory `models`, which will contain the Stan models used in the chapters scripts and (Pluto)notebooks.

StatisticalRethinkingStan.jl is compatible with the 2nd edition of the book.

Expanded coverage of chapters 7 and beyond of the book will likely happen while working on StatisticalRethinkingStan.jl (as I got seriously sidetracked working on [StructuralCausalModels.jl](https://github.com/StatisticalRethinkingJulia/StructuralCausalModels.jl)). StructuralCausalModels.jl is included as en experimental dependency in the StatisticalRethinkingStan.jl project.

Any feedback is appreciated. Please open an issue.
This is an awesome new scientific project that uses `DrWatson`!

## Versions

### Version 0.1.0 (in preparation)

1. Initial version
2. 