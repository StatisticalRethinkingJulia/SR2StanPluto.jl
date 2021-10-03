using Pkg, DrWatson
#@quickactivate "StatisticalRethinkingStan"

function tf1(f::Number; l=12, kwargs...)
    x = range(f, stop=l, length=10)
    y = 10rand(length(x))
    println(length(keys(kwargs)))
    if length(keys(kwargs)) > 0
        plot(;kwargs...)
        plot!(x, y)
    else
        plot(x, y)
    end
end

tf1(1)
tf1(3)
tf1(5; xlims=(6, 9), ylims=(0, 20))
