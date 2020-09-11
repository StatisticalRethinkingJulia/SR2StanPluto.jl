# Fig3.2s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

p1 = plot_density_interval(samples2, [0.25, 0.43],
  #color=[:yellow, :green]
)
gui()

p2 = plot_density_interval(samples2, [0.65, 0.73], p=p1)
gui()
