using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using XGBoost
using StatisticalRethinking

include("$(@__DIR__)/rstar.jl")
include("$(@__DIR__)/clip-04-31s.jl");

chns = read_samples(sm; output_format=:mcmcchains)

rstar(chns, 1)

rs = rstar(chns, 100)

mean(rs) |> display

histogram(rs)

gui()

closeall()
