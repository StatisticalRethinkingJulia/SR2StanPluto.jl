# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame);

# Define the Stan language model

stan10_1s = "
data{
    int N;
    int pulled_left[N];
}
parameters{
    real a;
}
model{
    real p;
    a ~ normal( 0 , 10 );
    pulled_left ~ binomial( 1 , inv_logit(a) );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m10_1s = SampleModel("m10.1s", stan10_1s);

# Input data for cmdstan

m10_1_data = Dict("N" => size(df, 1), 
  "pulled_left" => df[!, :pulled_left]);

# Sample using cmdstan

rc10_1s = stan_sample(m10_1s, data=m10_1_data);

# Result rethinking

rethinking = "
  mean   sd  5.5% 94.5% n_eff Rhat
a 0.32 0.09 0.18  0.46   166    1
";

# Describe the draws

if success(rc10_1s)
  part10_1s = read_samples(m10_1s; output_format=:particles)
  part10_1s |> display
end