# Clip-03-20-24s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# snippet 3.20

@show pdf.(Binomial(2, 0.7), 0:2)

# snippet 3.21

@show rand(Binomial(2, 0.7))

# snippet 3.22

@show rand(Binomial(2, 0.7), 10)

N = 10000

# snippet 3.23

d = rand(Binomial(2, 0.7), N);

# snippet 3.24

h1 = histogram(d; normalize=:probability,
  bins=-0.5:1:2.5, xticks=0:2, bar_width=0.2, leg=false)

# End of clip-03-20-24s.jl
