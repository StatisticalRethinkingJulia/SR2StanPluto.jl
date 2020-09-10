# Clip-03-11-16s.jl

# Load Julia packages (libraries) needed for clip

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# ### snippet 3.11

p_grid = range(0, step=0.001, stop=1)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(3, p), 3) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)

# Draw 10000 samples from this posterior distribution

N = 10000
samples = sample(p_grid, Weights(posterior), N);

# ### snippet 3.13

hpdi(samples, alpha=0.11) |> display

# ### snippet 3.14

println("\nMode: $(mode(samples))\n")

# ### snippet 3.15

println("Mean: $(mean(samples))\n")

# ### snippet 3.16

println("Median: $(median(samples))\n")

density(samples, lab="density")
vline!(hpdi(samples, alpha=0.5), line=:dash, lab="hpdi")
vline!(quantile(samples, [0.25, 0.75]), line=:dash, lab="quantile (pi)")

# End of clip-03-11-16s.jl

