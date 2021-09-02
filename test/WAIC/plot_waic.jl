ProjDir = @__DIR__

include("./gen6-6-8.jl")

fig = plot_models([m6_6s, m6_7s, m6_8s], :waic)
plot(fig)
