# Clip-05-01-02s.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);

include(projectdir("models", "05", "m5.1s.jl"))

# ### snippet 5.2

std(df.MedianAgeMarriage) |> display

if success(rc)

  # Describe the draws

  dfs = read_samples(m5_1s; output_format=:dataframe)
  println("\nSample Particles summary:"); p_m_5_1 = Particles(dfs); p_m_5_1 |> display
  println("\nQuap Particles estimate:"); q_m_5_1 = quap(dfs); display(q_m_5_1)

  # Result rethinking

  rethinking = "
           mean   sd  5.5% 94.5%
    a      0.00 0.10 -0.16  0.16
    bA    -0.57 0.11 -0.74 -0.39
    sigma  0.79 0.08  0.66  0.91
  "

  # Plot regression line using means and observations

  title = "Divorce rate vs. median age at marriage" * "\nshowing predicted and quantile range"
  p1 = plotbounds(
    df, :MedianAgeMarriage, :Divorce,
    dfs, [:a, :bA, :sigma];
    title=title,
    colors=[:yellow, :darkgrey]
  )
  title = "Divorce rate vs. median age at marriage" * "\nshowing predicted and hpdi range"
  p2 = plotbounds(
    df, :MedianAgeMarriage, :Divorce,
    dfs, [:a, :bA, :sigma];
    title=title,
    colors=[:pink, :darkgrey]
  )

  plot(p1, p2, layout=(2,1))
  savefig(plotsdir("05", "Fig-01-02.png"))

end

# End of clip-05-01-02s.jl
