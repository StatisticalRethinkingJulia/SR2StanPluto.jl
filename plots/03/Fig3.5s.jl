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
h = fit(Histogram, d, -0.5:1:9.5)

plot(xlim=(0,9), xticks=0:9)
for (i, w) in enumerate(h.weights)
  println([i, w])
  plot!([i-1, i-1], [0.0, w], color=:blue, leg=false)
end
savefig(plotsdir("03", "Fig3.5s.png"))

# End of Fig3.5s.jl