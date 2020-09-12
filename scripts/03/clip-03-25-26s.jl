# Clip-03-25-26s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# snippet 3.25

N = 10000
w = rand(Binomial(9, 0.6), N);
h1 = histogram(w; normalize=:probability, leg=false)

p_grid = range(0, step=0.001, stop=1)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(9, p), 6) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)
samples = sample(p_grid, Weights(posterior), N);

# snippet 3.26

d = rand.(Binomial.(9, samples));
h2 = histogram(d; normalize=:probability, 
  bins=-0.5:1:9.5, leg=false, xticks=0:9, bar_width=0.2)

plot(h1, h2, layout=(1, 2))

# End of clip-03-25-26s.jl
