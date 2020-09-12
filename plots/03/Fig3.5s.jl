# Fig3.5s.jl

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
histogram(d; normalize=:probability, 
  bins=-0.5:1:9.5, leg=false, xticks=0:9, bar_width=0.2)
savefig(plotsdir("03", "Fig3.5s.png"))

# End of Fig3.5s.jl