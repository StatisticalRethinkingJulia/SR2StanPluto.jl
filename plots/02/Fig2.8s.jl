# Fig2.8s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
x = 0:0.01:1

for (j, i) in enumerate([1, 2, 4])
  local w = i * 6
  local n = i * 9
 
  local p_grid = range(0, stop=1, length=1000);
  local prior = ones(length(p_grid));
  local likelihood = [pdf(Binomial(n, p), w) for p in p_grid];
  local posterior = likelihood .* prior;
  local posterior = posterior / sum(posterior);

  N = 10000
  samples = sample(p_grid, Weights(posterior), N);

  # Analytical calculation

  p[j] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(0.0, 1.0), 
    lab="exact", leg=:topleft, title="n = $n")
  #density!(p[j], samples, lab="Sample density")

  # Quadratic approximation using StatisticalRethinking.jl quap()

  df = DataFrame(:toss => samples)
  q = quap(df)
  plot!( p[j], x, pdf.(Normal(mean(q.toss), std(q.toss) ) , x ),
    lab="quap")
end

plot(p..., layout=(1, 3))
savefig(plotsdir("02", "Fig2.8s.png"))

# End of Fig2.8s.jl
