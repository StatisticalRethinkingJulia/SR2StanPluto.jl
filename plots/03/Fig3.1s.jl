# Fig3.1s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# ### snippet 3.2

p_grid = range(0, step=0.001, stop=1)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(9, p), 6) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)
samples = sample(p_grid, Weights(posterior), length(p_grid));
samples[1:5]

# ### snippet 3.3
# Draw 10000 samples from this posterior distribution

N = 10000
samples2 = sample(p_grid, Weights(posterior), N);

# Store samples in an MCMCChains.Chains object. 

chn = MCMCChains.Chains(reshape(samples2, N, 1, 1), ["toss"]);

# Describe the chain

chn |> display

# Plot the chain

p1 = plot(chn)

# ### snippet 3.4

# Create a vector to hold the plots so we can later combine them

p1 = scatter(samples2, ylim=(0, 1), xlab="Sample number",
  ylab="Proportion water(p)", leg=false)
p2 = density(samples2, xlim=(0.0, 1.0), ylim=(0.0, 3.0), xlab="Proportion water (p)",
  ylab="Density", leg=false)
p2 = density!(samples2, fillrange=(0.0, 0.3), fill=(0.5, :lightblue))
plot(p1, p2, layout=(1,2))
savefig(plotsdir("03", "Fig3.1s.png"))

# End of Fig3.1s.jl