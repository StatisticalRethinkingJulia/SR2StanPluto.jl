# Load Julia packages (libraries) needed.

using StatisticalRethinking

ProjDir = @__DIR__

# ### snippet 5.29

println()
df = CSV.read(rel_path("..", "data", "milk.csv"), delim=';');
df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
df[!, :lmass] = log.(df[:, :mass])
#first(df, 5) |> display

# ### snippet 5.1

scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
println()

m_5_5 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}

parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

# Define the SampleModel and set the output format to :mcmcchains.

m5_5s = SampleModel("m5.5", m_5_5);

# Input data for cmdstan

m5_5_data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
    "K" => df[!, :kcal_per_g_s]);

# Sample using StanSample

rc = stan_sample(m5_5s, data=m5_5_data);

if success(rc)

  # Describe the draws

  dfa5 = read_samples(m5_5s; output_format=:dataframe)
  p = Particles(dfa5)
  quap(dfa5) |> display

  retinking = "
            mean   sd  5.5% 94.5%
    a     0.04 0.15 -0.21  0.29
    bN    0.13 0.22 -0.22  0.49
    sigma 1.00 0.16  0.74  1.26
  "

end
