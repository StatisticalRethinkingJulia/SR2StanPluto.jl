# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

df = CSV.read(sr_datadir("UCBadmit.csv"), DataFrame);

# Preprocess data

df[!, :male] = [(df[!, :gender][i] == "male" ? 1 : 0) for i in 1:size(df, 1)];
df[!, :dept_id] = [Int(df[!, :dept][i][1])-64 for i in 1:size(df, 1)];

stan13_2 = "
  data{
      int N;
      int N_depts;
      int applications[N];
      int admit[N];
      real male[N];
      int dept_id[N];
  }
  parameters{
      vector[N_depts] a_dept;
      real a;
      real bm;
      real<lower=0> sigma_dept;
  }
  model{
      vector[N] p;
      sigma_dept ~ cauchy( 0 , 2 );
      bm ~ normal( 0 , 1 );
      a ~ normal( 0 , 10 );
      a_dept ~ normal( a , sigma_dept );
      for ( i in 1:N ) {
          p[i] = a_dept[dept_id[i]] + bm * male[i];
          p[i] = inv_logit(p[i]);
      }
      admit ~ binomial( applications , p );
  }
";

# Define the Stanmodel and set the output format to :mcmcchains.

m13_2s = SampleModel("m13_2s", stan13_2);

# Input data for cmdstan

m13_2_data = Dict(
  "N" => size(df, 1), 
  "N_depts" => maximum(df[!, :dept_id]), 
  "applications" => df[!, :applications],  
  "admit" => df[!, :admit], 
  "male" => df[!, :male],
  "dept_id"=> df[!, :dept_id]
);

# Sample using cmdstan

rc13_2s = stan_sample(m13_2s, data=m13_2_data);

# Describe the draws

if success(rc13_2s)
  part13_2s = read_samples(m13_2s; output_format=:particles)
  part13_2s |> display
end

