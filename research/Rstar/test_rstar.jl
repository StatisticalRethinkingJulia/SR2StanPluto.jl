using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"

using StanSample,XGBoost

include("$(@__DIR__)/rstar.jl")
include("$(@__DIR__)/clip-04-31s.jl");

rstar(chns, 1)

rs = rstar(chns, 100)

mean(rs) |> display

histogram(rs)

#gui()

#closeall()
