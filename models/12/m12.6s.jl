# Load Julia packages (libraries)

using Pkg, DrWatson

using MonteCarloMeasurements
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("Kline.csv"), DataFrame);

# New col log_pop, set log() for population data
df[!, :log_pop] = map((x) -> log(x), df[!, :population]);
df[!, :society] = 1:10;

stan12_6 = "
data {
    int N;
    int N_societies;
    int total_tools[N];
    real logpop[N];
    int society[N];
}
parameters{
    real a;
    real bp;
    vector[N_societies] a_society;
    real<lower=0> sigma_society;
}
model{
    vector[N_societies] mu;
    sigma_society ~ cauchy( 0 , 1 );
    a_society ~ normal( 0 , sigma_society );
    bp ~ normal( 0 , 1 );
    a ~ normal( 0 , 10 );
    for ( i in 1:N ) {
        mu[i] = a + a_society[society[i]] + bp * logpop[i];
        mu[i] = exp(mu[i]);
    }
    total_tools ~ poisson( mu );
}
";

# Define the SampleModel.

m12_6s = SampleModel("m12.6s",  stan12_6);

# Input data for cmdstan

m12_6_data = Dict("N" => size(df, 1), "N_societies" => 10,  
"total_tools" => df[!, :total_tools], "logpop" => df[!, :log_pop],
"society" => df[!, :society]);
        
# Sample using cmdstan's sample option

rc12_6s = stan_sample(m12_6s, data=m12_6_data);

# Describe the draws

if success(rc12_6s)
  part12_6s = read_samples(m12_6s, :particles)
  part12_6s |> display
end
