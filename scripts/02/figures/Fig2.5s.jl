# Fig 2.5

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

#=
This clip is only intended to generate Fig 2.5.
It is not intended to show how to use Stan (yet)!
=#

m2_0 = "
// Inferring a rate
data {
  int n;
  int k;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

# Create a StanModel object:

m2_0s = SampleModel("m2.0s", m2_0);

# n will go from 1:9

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
dens = Vector{DataFrame}(undef, 10)

k = [1,0,1,1,1,0,1,0,1]       # Sequence observed
x = range(0, stop=9, length=10)

for n in 1:9

  p[n] = plot(xlims=(0.0, 1.0), ylims=(0.0, 3.0), leg=false)
  local m2_0_data = Dict("n" => n, "k" => sum(k[1:n]));
  local rc = stan_sample(m2_0s, data=m2_0_data);
  local dfs = read_samples(m2_0s; output_format=:dataframe)
  if n == 1
    hline!([1.0], line=(:dash))
  else
    density!(dens[n][:, :theta], line=(:dash))
  end
  density!(dfs[:, :theta])
  dens[n+1] = dfs

end

plot(p..., layout=(3, 3))
savefig(plotsdir("02", "Fig2.5.png"))

# End of Fig 2.5
