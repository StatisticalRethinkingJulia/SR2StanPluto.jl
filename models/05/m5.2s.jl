# m5.2s.jl

using Pkg, DrWatson

using StanQuap
using StatisticalRethinking

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])

stan5_2 = "
data {
      int N;
      vector[N] divorce_s;
      vector[N] marriage_s;
}
parameters {
      real a;
      real bM;
      real<lower=0> sigma;
}
model {
      vector[N] mu = a + bM * marriage_s;
      a ~ normal( 0 , 0.2 );
      bM ~ normal( 0 , 0.5 );
      sigma ~ exponential( 1 );
      divorce_s ~ normal( mu , sigma );
}
";

data = (N=size(df, 1), divorce_s=df.Divorce_s, marriage_s=df.Marriage_s)
init = (a=1.0, bM=1.0, sigma=10.0)
q5_2s, m5_2s, o5_2s = stan_quap("m5.2s", stan5_2; data, init);

if !isnothing(q5_2s)
      quap5_2s_df = sample(q5_2s)
      precis(quap5_2s_df)
end

# End m5.2s.jl
