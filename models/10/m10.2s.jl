# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame);

# Define the Stan language model

stan10_2s = "
data{
    int N;
    int pulled_left[N];
    int prosoc_left[N];
}
parameters{
    real a;
    real bp;
}
model{
    vector[N] p;
    bp ~ normal( 0 , 10 );
    a ~ normal( 0 , 10 );
    for ( i in 1:N ) {
        p[i] = a + bp * prosoc_left[i];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m10_2s = SampleModel("m10.2s", stan10_2s);

# Input data for cmdstan

m10_2_data = Dict("N" => size(df, 1), 
"pulled_left" => df[!, :pulled_left], "prosoc_left" => df[!, :prosoc_left]);

# Sample using cmdstan

rc10_2s= stan_sample(m10_2s, data=m10_2_data);

# Result rethinking

rethinking = "
   mean   sd  5.5% 94.5% n_eff Rhat
a  0.04 0.12 -0.16  0.21   180 1.00
bp 0.57 0.19  0.30  0.87   183 1.01
";

# Describe the draws

if success(rc10_2s)
  part10_2s = read_samples(m10_2s, :particles)
  part10_2s |> display
end