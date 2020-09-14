# Fig4.3s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 4.7

df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)

# ### snippet 4.8

# Show a summary of the  DataFrame

println()
Particles(df) |> display

# ### snippet 4.9

# Show some statistics

describe(df, :all)

# ### snippet 4.10

df.height

# ### snippet 4.11

# Use only adults

df = filter(row -> row[:age] >= 18, df);
println()
Particles(df) |> display
precis(df)

# Our model:

m4_1 = "
  height ~ Normal(μ, σ) # likelihood
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
";

# Plot the prior densities.

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)

# ### snippet 4.12

# μ prior

d1 = Normal(178, 20)
p[1] = plot(100:250, [pdf(d1, μ) for μ in 100:250],
  xlab="mu",
  ylab="density",
  lab="Prior on mu")

# ### snippet 4.13

# Show σ  prior

d2 = Uniform(0, 50)
p[2] = plot(-5:0.1:55, [pdf(d2, σ) for σ in 0-5:0.1:55],
  xlab="sigma",
  ylab="density",
  lab="Prior on sigma")

# ### snippet 4.14

sample_mu_20 = rand(d1, 10000)
sample_sigma = rand(d2, 10000)

d3 = Normal(178, 100)
sample_mu_100 = rand(d3, 10000)

prior_height_20 = [rand(Normal(sample_mu_20[i], sample_sigma[i]), 1)[1] for i in 1:10000]
p[3] = density(prior_height_20,
  xlab="height",
  ylab="density",
  lab="Prior predictive height")

prior_height_100 = [rand(Normal(sample_mu_100[i], sample_sigma[i]), 1)[1] for i in 1:10000]
p[4] = density(prior_height_100,
  xlab="height",
  ylab="density",
  lab="Prior predictive mu")

plot(p..., layout=(2,2))
savefig(plotsdir("04", "Fig4.3s.png"))

# End of Fig4.3s.jl
