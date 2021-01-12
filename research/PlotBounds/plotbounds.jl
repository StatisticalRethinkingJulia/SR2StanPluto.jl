using DocStringExtensions

"""
# plotbounds

Plot regression line and PI interval with alpha=0.11.

$(SIGNATURES)

### Required arguments
```julia
* `df::DataFrame`                      : DataFrame with observed variables and scaled variables
* `xvar::Symbol`                       : X variable in df
* `yvar::Symbol`                       : Y variable in df
* `nt::NamedTuple`                     : NamedTuple with Stan samples
* `linkvars::Vector{Symbol}`           : Initial 2 Symbols are regression coefficients,
                                         3rd - only for :predict bounds indicates σ.
```
### Optional arguments
```julia
* `fnc = link`                         : Link function
* `fig::AbstractString=""`             : File to store the plot. If "", a plot is returned
* `stepsize::Float64=0.01`             : Stepsize for boundary accuracy 
* `rescale_axis=true`                  : Display using un-standardized scale         
* `title::AbstractString=""`           : Title for plot
* `lab::AbstractString=""`             : X axis variable label
```

This method is primarily intended to the PI region around the mean line. 

The 2nd symbol in `linkvars` needs to match the matrix 
```julia
linkvars = [:a, :bM]
```

For other options, :quantile and :hpdi, two parameters suffice (typically the itercept
and slope parameters).

"""
function pbounds(
    df::DataFrame,
    xvar::Symbol,
    yvar::Symbol,
    nt::NamedTuple, 
    linkvars::Vector{Symbol}; 
    fnc::Function=link,
    fig::AbstractString="",
    stepsize=0.01,
    rescale_axis=true,
    lab::AbstractString="",
    title::AbstractString="")

    xbar = mean(df[:, xvar])
    xstd = std(df[:, xvar])
    ybar = mean(df[:, yvar])
    ystd = std(df[:, yvar])

    xvar_s = Symbol(String(xvar)*"_s")
    yvar_s = Symbol(String(yvar)*"_s")

    minx = minimum(df[!, xvar_s])
    maxx = maximum(df[!, xvar_s])
    x_s = minx:stepsize:maxx

    k = size(nt[Symbol(linkvars[2])], 1)
    m = fnc(collect(x_s), k)
    y_s = m * nt[Symbol(linkvars[2])]
    y_s .+= nt[Symbol(linkvars[1])]'
    mul = meanlowerupper(y_s)

    p = plot(;title)
    if rescale_axis
        xrange = rescale(x_s, xbar, xstd)
        mm = rescale(mul.mean, ybar, ystd)
        lm = rescale(mul.lower, ybar, ystd)
        um = rescale(mul.upper, ybar, ystd)
        plot!(p, xrange, mm;
            xlab=String(xvar), ylab=String(yvar),
            ribbon=(mm-lm, um-mm),
            lab)
    else
        plot!(p, xrange, mul.mean;
            xlab=String(xvar), ylab=String(yvar),
            ribbon=(mul.mean-mul.lower, mul.upper-mul.mean),
            lab)
    end

    if fig == ""
        return(p)
    else
        savefig(p, fig)
    end
end

nt = nt7_2s
linkvars = [:a, :bA, :sigma]
fnc=create_observation_matrix
lab="$(size(nt[Symbol(vars[2])], 1))-th degree polynomial"
title="R^2 = $(r2_is_bad(nt, df))"

display(pbounds(df, :mass, :brain, nt, linkvars; stepsize=0.05, fnc, lab, title))
