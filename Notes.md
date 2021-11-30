
### Tag version notes

1. git commit -m "Tag v4.0.3: changes"
2. git tag v4.0.3
3. git push origin master --tags

### Cloning the repository

```
# Cd to where you would like to clone to
$ git clone https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl
$ cd SR2StanPluto.jl
$ julia
```
and in the Julia REPL:

```
julia> ]                                        # Actvate Pkg mode
(@v1.6) pkg> activate .                         # Activate pkg in .
(SR2StanPluto) pkg> instantiate    # Install in pkg environment
(SR2StanPluto) pkg> <delete>       # Exit package mode
julia>
```

If above procedure fails, if present, try to delete the Manifest.toml file and repeat above steps. As mentioned above, these steps are only needed the first time.

If you want to use a specific tagged version, use:
```
# cd to cloned directory
$ git checkout v2.0.0
```

### Extract .jl from Jupyter notebook (`jupytext` needs to be installed)

# jupytext --to jl "./ch7.ipynb"
