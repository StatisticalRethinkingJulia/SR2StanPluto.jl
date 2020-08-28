# Clip-00-04-05.jl

# ### snippet 0.5 is replaced by below `using StatisticalRethinking`.

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking
using GLM

# ### snippet 0.4

df = CSV.read("$(srdatadir())/Howell1.csv", DataFrame; delim=';')
howell1 = filter(row -> row[:age] >= 18, df);
first(howell1, 5)

# Fit a linear regression of distance on speed

m = lm(@formula(height ~ weight), howell1)

# estimated coefficients from the model

coef(m)

# Plot residuals against speed

scatter( howell1.height, residuals(m), xlab="Height",
  ylab="Model residual values", lab="Model residuals", leg=:bottomright)

# End of clip-00-04-05.jl
