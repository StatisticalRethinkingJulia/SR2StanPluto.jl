using DrWatson
@quickactivate "StatisticalRethinkingStan"

# ### snippet 0.5 is replaced by below `using StatisticalRethinking`.

using StatisticalRethinking
using GLM

ProjDir = @__DIR__

# ### snippet 0.4

df = DataFrame!(CSV.read(sr_path("..", "data", "Howell1.csv"),
  DataFrame; delim=';'))
howell1 = filter(row -> row[:age] >= 18, df);
first(howell1, 5)

# Fit a linear regression of distance on speed

m = lm(@formula(height ~ weight), howell1)

# estimated coefficients from the model

coef(m)

# Plot residuals against speed

scatter( howell1.height, residuals(m), xlab="Height",
  ylab="Model residual values", lab="Model residuals", leg=:bottomright)

# End of `00/clip-04-05.jl`
