# m5.6s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.29

df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
df[!, :lmass] = log.(df[:, :mass])
scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])

stan5_6 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# Define the SampleModel and set the output format to :mcmcchains.

m5_6s = SampleModel("m5.6", stan5_6);

# Input data for cmdstan

m5_6_data = Dict("N" => size(df, 1), "M" => df[!, :lmass_s],
    "K" => df[!, :kcal_per_g_s]);

# Sample using StanSample

rc5_6s = stan_sample(m5_6s, data=m5_6_data);

if success(rc5_6s)

  part5_6s = read_samples(m5_6s; output_format=:particles)
  part5_6s |> display

  rethinking = "
             mean   sd  5.5% 94.5%
    a      0.05 0.15 -0.20  0.29
    bM    -0.28 0.19 -0.59  0.03
    sigma  0.95 0.16  0.70  1.20
  "

end
