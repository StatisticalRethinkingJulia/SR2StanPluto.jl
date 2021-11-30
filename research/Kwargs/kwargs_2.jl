using Pkg, DrWatson
#@quickactivate "SR2StanPluto"

function tf1(f::Number; l=12, kwargs...)
    kwargs
 end

tf1(1) |> display
tf1(3) |> display
res = tf1(5; xlims=(6, 9), ylims=(0, 20))
res |> display

