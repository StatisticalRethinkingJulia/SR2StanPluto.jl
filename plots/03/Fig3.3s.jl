# Fig3.2s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# snippet 3.11

p_grid = range(0, step=0.000001, stop=1)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(3, p), 3) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)
samples = sample(p_grid, Weights(posterior), length(p_grid));


# ### snippet 3.12
density(samples, lab="density")
vline!(hpdi(samples, alpha=0.5), line=:dash, lab="hpdi")
vline!(quantile(samples, [0.25, 0.75]), line=:dash, lab="quantile (pi)")

b1 = quantile(samples, [0.25, 0.75])
b2 = hpdi(samples, alpha=0.5)

p1 = plot_density_interval(samples, b1;
  xlab="Proportion water (p)", title="50% PI");
p2 = plot_density_interval(samples, b2;
  xlab="Proportion water (p)", title="50% HPDI");
plot(p1, p2, layout=(1, 2))
savefig(plotsdir("03", "Fig3.3s.png"))
