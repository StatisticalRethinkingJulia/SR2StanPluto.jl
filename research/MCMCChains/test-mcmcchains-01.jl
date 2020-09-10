using MCMCChains, Distributions, StatsBase, StatsPlots

# ### snippet 3.3
# Draw 10000 samples from this posterior distribution

N = 4000
samples = reshape(rand(Normal(1, 1), N), 1000, 1, 4);

chn = MCMCChains.Chains(samples, [:toss]);

chn |> display

plot(chn)
#savefig(joinpath(@__DIR__, "test_plot.png"))
