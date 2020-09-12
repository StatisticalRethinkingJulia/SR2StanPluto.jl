# Fig3.6s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# snippet 3.23

N = 10000
p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
for j in 1:9

  prob = j * 0.1
  d = rand(Binomial(9, prob), N);
  h = fit(Histogram, d, -0.5:1:9.5)

  p[j] = plot(xlim=(0,9), xticks=0:9)
  for (i, w) in enumerate(h.weights)
    plot!(p[j], [i-1, i-1], [0.0, w], color=:blue,
      leg=false, title="prob=$(round(prob, digits=1))")
  end
end
plot(p..., layout=(3,3))
savefig(plotsdir("03", "Fig3.6s.png"))

# End of Fig3.6s.jl