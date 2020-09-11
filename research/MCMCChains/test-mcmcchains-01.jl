Test script Julia 1.6-DEV

using MCMCChains, Distributions, StatsBase, StatsPlots

samples = reshape(rand(Normal(1, 1), 4000), 1000, 1, 4);
chn = MCMCChains.Chains(samples, [:toss]);

# PrettyTables issue
chn |> display
# Grisu issue
plot(chn)
