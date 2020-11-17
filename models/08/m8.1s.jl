# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("rugged.csv"), DataFrame);

dcc = filter(row -> !(ismissing(row[:rgdppc_2000])), df)
dcc[!, :log_gdp] = log.(dcc[!, :rgdppc_2000])
dcc[!, :cont_africa] = Array{Float64}(convert(Array{Int}, dcc[!, :cont_africa]))
dcc[!, :rugged] = convert(Array{Float64}, dcc[!, :rugged])

# Define the Stan language model

stan8_1 = "
data{
    int N;
    vector[N] log_gdp;
    vector[N] cont_africa;
    vector[N] rugged;
    vector[N] rugged_cont_africa;
}
parameters{
    real a;
    real bR;
    real bA;
    real bAR;
    real sigma;
}
model{
    vector[N] mu = a + bR * rugged + bA * cont_africa + bAR * rugged_cont_africa;
    sigma ~ uniform( 0 , 10 );
    bAR ~ normal( 0 , 10 );
    bA ~ normal( 0 , 10 );
    bR ~ normal( 0 , 10 );
    a ~ normal( 0 , 100 );
    log_gdp ~ normal( mu , sigma );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m8_1s = SampleModel("m8.1s", stan8_1);

# Input data for cmdstan

m8_1_data = Dict(
  "N" => size(dcc, 1), 
  "log_gdp" => dcc[!, :log_gdp],  
  "cont_africa" => dcc[!, :cont_africa], 
  "rugged" => dcc[!, :rugged], 
  "rugged_cont_africa" => dcc[!, :rugged] .* dcc[!, :cont_africa] );

# Sample using cmdstan

rc = stan_sample(m8_1s, data=m8_1_data);

# Result rethinking

rethinking = "
       mean   sd  5.5% 94.5% n_eff Rhat
a      9.22 0.14  9.00  9.46   282    1
bR    -0.21 0.08 -0.33 -0.08   275    1
bA    -1.94 0.24 -2.33 -1.59   268    1
bAR    0.40 0.14  0.18  0.62   271    1
sigma  0.96 0.05  0.87  1.04   339    1
"

# Describe the draws

if success(rc)
  part8_1s = read_samples(m8_1s; output_format=:particles)
  part8_1s |> display
end

# End of m8_1s
