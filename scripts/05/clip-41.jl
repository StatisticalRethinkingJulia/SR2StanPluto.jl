# Load Julia packages (libraries) needed.

using StatisticalRethinking

ProjDir = @__DIR__

df1 = CSV.read(rel_path("..", "data", "milk.csv"), delim=';');
df1 = filter(row -> !(row[:neocortex_perc] == "NA"), df1);

df = DataFrame()
df[!, :NC] = parse.(Float64, df1[:, :neocortex_perc])
df[!, :M] = log.(df1[:, :mass])
df[!, :K] = df1[:, :kcal_per_g]
first(df, 5) |> display
scale!(df, [:K, :NC, :M])
println()

include("$(ProjDir)/m5.7_A.jl")

first(dfa, 5) |> display
println()

p = Particles(dfa)
display(p)

# Snippet 5.22

a_seq = range(-2, stop=2, length=100)

m_sim, d_sim = simulate(dfa, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma])

# Snippet 5.24

plot(xlab="Manipulated M", ylab="Counterfactual K",
  title="Total counterfactual effect of M on K")
plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
hpdi_array = zeros(length(a_seq), 2)
for i in 1:length(a_seq)
  hpdi_array[i, :] =  hpdi(d_sim[i, :])
end
plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
savefig("$(ProjDir)/Fig-41b.png")

