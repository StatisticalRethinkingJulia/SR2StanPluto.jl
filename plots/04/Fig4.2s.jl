# Clip-04-01-06s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# ### snippet 4.1

noofsteps = 20;
noofwalks = 15;
pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks));
pos[1, :] = zeros(noofwalks);
csum = cumsum(pos, dims=1);

f = Plots.font("DejaVu Sans", 6)
mx = minimum(csum) * 0.9

# Plot and annotate the random walks

p1 = plot(csum, leg=false, title="Random walks ($(noofwalks))")
plot!(p1, csum[:, Int(floor(noofwalks/2))], leg=false, title="Random walks ($(noofwalks))", color=:black)
plot!(p1, [5], seriestype="vline")
annotate!(5, mx, text("step 4", f, :left))
plot!(p1, [9], seriestype="vline")
annotate!(9, mx, text("step 8", f, :left))
plot!(p1, [17], seriestype="vline")
annotate!(17, mx, text("step 16", f, :left))

# Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)

p2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3);
plt = 1
for step in [4, 8, 16]
  indx = step + 1 # We aadded the first line of zeros
  global plt
  global fitl = fit_mle(Normal, csum[indx, :])
  lx = (fitl.μ-4*fitl.σ):0.01:(fitl.μ+4*fitl.σ)
  p2[plt] = density(csum[indx, :], legend=false, title="$(step) steps")
  plot!( p2[plt], lx, pdf.(Normal( fitl.μ , fitl.σ ) , lx ), fill=(0, .5,:orange))
  plt += 1
end
p3 = plot(p2..., layout=(1, 3))
plot(p1, p3, layout=(2,1))
savefig(plotsdir("04", "Fig4.2s.png"))
