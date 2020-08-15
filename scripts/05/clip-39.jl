# Load Julia packages (libraries) needed.

using StatisticalRethinking

ProjDir = @__DIR__

# ### snippet 5.39

for i in 5:7
  include("$(ProjDir)/m5.$i.jl")
end

if success(rc)

  r1 = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM], "$(ProjDir)/Fig-39a.png",
    "Masked relationships: bN & bM Normal estimates")
  r1 |> display

  r2 = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM], "$(ProjDir)/Fig-39b.png",
    "Masked relationships: bN & bM Normal estimates", quap)
  r2 |> display

end
