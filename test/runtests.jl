# Run project tests

TestDir = @__DIR__
cd(TestDir)

include("Coeftab_plot/test_coeftab_plot.jl")
include("Pk_plot/test_pk_plot.jl")
