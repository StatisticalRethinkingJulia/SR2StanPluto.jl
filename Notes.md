
### Tag version notes

1. git commit -m "Tag v4.0.3: changes"
2. git tag v4.0.3
3. git push origin master --tags

### Cloning the repository

```
# Cd to where you would like to clone to
$ git clone https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl SR2StanPluto
$ cd SR2StanPluto/notebooks
$ julia
```
and in the Julia REPL:

```
julia> using Pluto
julia> Pluto.run()
julia>
```

Pluto opens a notebook in your default browser.

### Extract .jl from Jupyter notebook (`jupytext` needs to be installed)

# jupytext --to jl "./ch7.ipynb"
