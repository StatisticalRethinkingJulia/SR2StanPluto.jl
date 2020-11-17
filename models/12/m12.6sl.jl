using StanSample, MCMCChains, CSV

df = CSV.read(joinpath(@__DIR__, "..",  "..", "data",  "Kline.csv"), DataFrame);

# New col log_pop, set log() for population data
df[!, :log_pop] = map((x) -> log(x), df[!, :population]);
df[!, :society] = 1:10;

m12_6sl = "
  data {
    int N;
    int T[N];
    int N_societies;
    int society[N];
    int P[N];
  }
  parameters {
    real alpha;
    real bp;
    vector[N_societies] a_society;
    real<lower=0> sigma_society;
  }
  model {
    vector[N_societies] mu;
    target += normal_lpdf(alpha | 0, 10);
    target += normal_lpdf(bp | 0, 1);
    target += cauchy_lpdf(sigma_society | 0, 1);
    target += normal_lpdf(a_society | 0, sigma_society);
    for(i in 1:N) {
      mu[i] = alpha + a_society[society[i]] + bp * log(P[i]);
    }
    target += poisson_log_lpmf(T | mu);
  }
  generated quantities {
    vector[N] log_lik;
    {
    vector[N] mu;
    for(i in 1:N) {
      mu[i] = alpha + a_society[society[i]] + bp * log(P[i]);
      log_lik[i] = poisson_log_lpmf(T[i] | mu[i]);
    }
  }
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

m_12_6sl = SampleModel("m12.6sl",  m12_6sl);

# Input data for cmdstan

m12_6_data = Dict("N" => size(df, 1), "N_societies" => 10,  
"T" => df[!, :total_tools], "P" => df[!, :population],
"society" => df[!, :society]);
        
# Sample using cmdstan

rc = stan_sample(m_12_6sl, data=m12_6_data);

# Describe the draws

if success(rc)
  chn = read_samples(m_12_6sl; output_format=:mcmcchains)
  describe(chn)
end
