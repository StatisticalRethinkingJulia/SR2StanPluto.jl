# Clip-01-03.jl

cd(@__DIR__)
using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# ### snippet 0.1

println( "All models are wrong, but some are useful." );

# ### snippet 0.2

# This is a StepRange, not a vector

x = 1:3

# Below still preserves the StepRange

x = x*10

# `Broadcast` log to steprange elements in x, this returms a vector!
# Notice the log.(x) notation.

x = log.(x)

# We can sum the vector x
x = sum(x)

# Etc.

x = exp(x)
x = x*10
x = log(x)
x = sum(x)
x = exp(x)

# ### snippet 0.3

[log(0.01^200) 200 * log(0.01)]

# End of `00/clip-01-03.jl`
