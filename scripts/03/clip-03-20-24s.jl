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

N = 100000
d = rand(Binomial(2, 0.7), N);
[length(filter(e -> e == i, d)) for i in 0:2] / N |> display

d = rand(Binomial(9, 0.7), N);
h1 = histogram([filter(e -> e == i, d) for i in 0:9];
 bins=-0.5:1:9.5, color=:grey, leg=false, xticks=0:9)

# End of clip-03-20-24s.jl
