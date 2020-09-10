using MCMCChains, Distributions, StatsBase, StatsPlots

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

# In StatisticalRethinkingJulia samples are stored
# in an MCMCChains.Chains object. 

chn = MCMCChains.Chains(reshape(samples2, N, 1, 1), ["toss"]);

# Describe the chain

chn |> display
