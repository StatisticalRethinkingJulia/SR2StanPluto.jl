# Fig3.6s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

N = 10000
p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
for j in 1:9
  prob = j * 0.1
  local d = rand(Binomial(9, prob), N);
  p[j] = histogram(d; normalize=:probability, 
    bins=-0.5:1:9.5, leg=false, xticks=0:9, bar_width=0.2)
end
plot(p..., layout=(3,3))
savefig(plotsdir("03", "Fig3.6s.png"))

# End of Fig3.6s.jl