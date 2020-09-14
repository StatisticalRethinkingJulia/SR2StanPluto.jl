# Fig3.5s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

begin
  N = 100000
  d = rand(Binomial(9, 0.7), N);
  histogram(d; normalize=:probability, 
    bins=-0.5:1:9.5, leg=false, xticks=0:9, bar_width=0.2)
  savefig(plotsdir("03", "Fig3.5s.png"))
end

# End of Fig3.5s.jl