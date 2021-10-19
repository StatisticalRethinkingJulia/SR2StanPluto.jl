# Load Julia packages (libraries)

using Pkg, DrWatson

using DataFrames
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);

mean_ma = mean(df[!, :MedianAgeMarriage])
df[!, :MedianAgeMarriage_s] = 
    convert(Vector{Float64},  (df[!, :MedianAgeMarriage]) .-
        mean_ma)/std(df[!, :MedianAgeMarriage]);
df.Divorce_SE = df[:, "Divorce SE"]

stan14_1 = "
  data {
    int N;
    vector[N] A;
    vector[N] R;
    vector[N] Dobs;
    vector[N] Dsd;
  }
  parameters {
    real a;
    real ba;
    real br;
    real<lower=0> sigma;
    vector[N] Dest;
  }
  model {
    vector[N] mu; 
    // priors
    target += normal_lpdf(a | 0, 10);
    target += normal_lpdf(ba | 0, 10);
    target += normal_lpdf(br | 0, 10);
    target += cauchy_lpdf(sigma | 0, 2.5);
  
    // linear model
    mu = a + ba * A + br * R;
  
    // likelihood
    target += normal_lpdf(Dest | mu, sigma);
  
    // prior for estimates
    target += normal_lpdf(Dobs | Dest, Dsd);
  }
  generated quantities {
    vector[N] log_lik;
    {
      vector[N] mu;
      mu = a + ba * A + br * R;
      for(i in 1:N) log_lik[i] = normal_lpdf(Dest[i] | mu[i], sigma);
    }
  }
";

m14_1s = SampleModel("m14.1s", stan14_1)

m14_1_data = Dict(
    "N" => size(df, 1),
    "A" => df[!, :MedianAgeMarriage],
    "R" => df[!, :Marriage],
    "Dobs" => df[!, :Divorce],
    "Dsd" => df[!, :Divorce_SE]
)

rc14_1s = stan_sample(m14_1s, data=m14_1_data)

if success(rc14_1s)
    chns14_1s = read_samples(m14_1s, :dataframe)
    chns14_1s |> display
end
