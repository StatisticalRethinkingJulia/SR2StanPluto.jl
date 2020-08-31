# Load Julia packages (libraries) needed for clip

using StatisticalRethinking

ProjDir = @__DIR__

# ### snippet 5.1

df = CSV.read(rel_path("..", "data", "WaffleDivorce.csv"), delim=';')
scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])

# Define the Stan language model

m_5_3 = "
data {
  int N;
  vector[N] divorce_s;
  vector[N] marriage_s;
  vector[N] medianagemarriage_s;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + + bA * medianagemarriage_s + bM * marriage_s;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  divorce_s ~ normal( mu , sigma );
}
";

# Define the SampleModel
m5_3s = SampleModel("m5.3", m_5_3);

# Input data

m5_3_data = Dict(
  "N" => size(df, 1), 
  "divorce_s" => df[:, :Divorce_s],
  "marriage_s" => df[:, :Marriage_s],
  "medianagemarriage_s" => df[:, :MedianAgeMarriage_s] 
);

# Sample using cmdstan

rc = stan_sample(m5_3s, data=m5_3_data);

if success(rc)

  # Describe the draws

  dfa3 = read_samples(m5_3s; output_format=:dataframe)

  # Rethinking results

  rethinking_results = "
           mean   sd  5.5% 94.5%
    a      0.00 0.10 -0.16  0.16
    bM    -0.07 0.15 -0.31  0.18
    bA    -0.61 0.15 -0.85 -0.37
    sigma  0.79 0.08  0.66  0.91
  ";

  Particles(dfa3)

end
