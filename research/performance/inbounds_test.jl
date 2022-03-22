using BenchmarkTools

function f_orig(x)
    Ind = fill(NaN, 10^5,1);
    for i in 1:10^5
        Ind[i] = x[i]>35;
    end
    return Ind;
end

function f(x)
    Ind = Vector{Bool}(undef, 10^5);
    for i in 1:10^5
        @inbounds Ind[i] = x[i]>35;
    end
    return Ind;
end

A = rand(1:100, 10^5,1);

@btime Ind1 = A .> 35; # Compilation
@btime Ind1 = A .> 35;
@btime Ind2 = f_orig(A);  # Compilation
@btime Ind2 = f_orig(A);
@btime Ind3 = f(A);  # Compilation
@btime Ind3 = f(A);

results = let 
       @benchmark(Ind4 = V .> 35; setup=(V = rand(1:100, 10^5))),
       @benchmark(Ind5 = f_orig(V); setup=(V = rand(1:100, 10^5))),
       @benchmark(Ind6 = f(V); setup=(V = rand(1:100, 10^5)))
end

results |> display
