# Clip-00-01-03.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"

# snippet 0.1

println( "All models are wrong, but some are useful." );

# snippet 0.2

# This is a StepRange, not a vector

@show x = 1:3

# Below still preserves the StepRange

@show x = x*10

# `Broadcast` log to steprange elements in x, this returms a vector!
# Notice the log.(x) notation.

@show x = log.(x)

# We can sum the vector x
@show x = sum(x)

# Etc.

@show x = exp(x)
x = x*10
x = log(x)
x = sum(x)
x = exp(x)

# ### snippet 0.3

@show [log(0.01^200) 200 * log(0.01)]

# End of clip-00-01-03.jl
