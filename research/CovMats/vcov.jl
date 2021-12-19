using CovarianceMatrices
using Random, DataFrames, GLM 
using StanSample
using StatisticalRethinking

Random.seed!(1)
n = 500
x = randn(n, 5)
u = zeros(2*n)
u[1] = rand()
for j in 2:2*n
    u[j] = 0.78*u[j-1] + randn()
end
u = u[n+1:2*n]
y = 0.1 .+ x*[0.2, 0.3, 0.0, 0.0, 0.5] + u

df = DataFrame()
for i in 1:5
    df[!, Symbol("x$i")] = x[:, i]
end
df[!,:y] = y

#Using the data in df, the coefficient of the regression can be estimated using GLM

lm1 = glm(@formula(y~x1+x2+x3+x4+x5), df, Normal(), IdentityLink())
lm1 |> display
println()

vcov(QuadraticSpectralKernel{Andrews}(), lm1, prewhite = false) |> display
println()

# For the previous example:

stderror(QuadraticSpectralKernel{Andrews}(), lm1, prewhite = false) |> display
println()

stderror(QuadraticSpectralKernel{NeweyWest}(), lm1, prewhite = false) |> display
println()

# Sometime is useful to access the bandwidth selected by the automatic procedures.
# This can be done using the optimalbandwidth method

optimalbandwidth(QuadraticSpectralKernel{NeweyWest}(), lm1; prewhite = false) |> display
println()

optimalbandwidth(QuadraticSpectralKernel{Andrews}(), lm1; prewhite = false) |> display
println()
