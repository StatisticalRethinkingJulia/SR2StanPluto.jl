using Test

# Run project tests

TestDir = @__DIR__

@testset "coeftab_plot" begin
    println("\nTesting coeftab_plot.\n")
    include(joinpath(TestDir, "Coeftab_plot", "test_coeftab_plot.jl"))
end

@testset "pk_plot" begin
    println("\nTesting test_pk_plot.\n")
    include(joinpath(TestDir, "Pk_plot", "test_pk_plot.jl"))
end

closeall()

