
function satisfies_first(predicate, itr)

    for i in itr
        predicate(i) && return Some(i)
    end

    nothing
end

println()
satisfies_first(iseven ∘ first, ((i, 2*i) for i in 1:10)) |> display
println()

Iterators.filter(==(4), [1 2 3 5 6]) |> x -> isempty(x) ? nothing : first(x) |> display

Iterators.filter(==(3), [1 2 3 5 6]) |> x -> isempty(x) ? nothing : first(x) |> display
println()

findfirst(==(5), [1 2 3 5 6]) |> display
