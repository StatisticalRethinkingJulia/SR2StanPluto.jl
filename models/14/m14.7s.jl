# ### m14.7t.jl

using Pkg, DrWatson

using StanSample
using StatisticalRethinking

Dmat = CSV.read(sr_datadir("islandDistMatrix.csv"), DataFrame);
df = CSV.read(sr_datadir("Kline2.csv"), DataFrame);
df.society = 1:10

stan14_7 = "
functions{
    matrix cov_GPL2(matrix x, real sq_alpha, real sq_rho, real delta) {
        int N = dims(x)[1];
        matrix[N, N] K;
        for (i in 1:(N-1)) {
          K[i, i] = sq_alpha + delta;
          for (j in (i + 1):N) {
            K[i, j] = sq_alpha * exp(-sq_rho * square(x[i,j]) );
            K[j, i] = K[i, j];
          }
        }
        K[N, N] = sq_alpha + delta;
        return K;
    }
}
data{
    int T[10];
    int society[10];
    int P[10];
    matrix[10,10] Dmat;
}
parameters{
    vector[10] k;
    real<lower=0> g;
    real<lower=0> b;
    real<lower=0> a;
    real<lower=0> etasq;
    real<lower=0> rhosq;
}
model{
    vector[10] lambda;
    matrix[10,10] SIGMA;
    rhosq ~ exponential( 0.5 );
    etasq ~ exponential( 2 );
    a ~ exponential( 1 );
    b ~ exponential( 1 );
    g ~ exponential( 1 );
    SIGMA = cov_GPL2(Dmat, etasq, rhosq, 0.01);
    k ~ multi_normal( rep_vector(0,10) , SIGMA );
    for ( i in 1:10 ) {
        lambda[i] = (a * P[i]^b/g) * exp(k[society[i]]);
    }
    T ~ poisson( lambda );
}
";

m14_7s_data = Dict(
    :T => df.total_tools,
    :P => df.population,
    :society => df.society,
    :Dmat => Array(Dmat[:, 2:end])
)

m14_7s = SampleModel("m14.7s", stan14_7)
rc14_7s = stan_sample(m14_7s; data = m14_7s_data)
if success(rc14_7s)
  chns14_7s = read_samples(m14_7s)
  chns14_7s |> display

  println()

  read_summary(m14_7s) |> display
end

m14_7s_results = "
       mean   sd  5.5% 94.5% n_eff Rhat4
k[1]  -0.16 0.34 -0.71  0.33   615  1.01
k[2]  -0.02 0.33 -0.55  0.47   550  1.01
k[3]  -0.07 0.32 -0.58  0.40   566  1.01
k[4]   0.35 0.29 -0.05  0.81   557  1.01
k[5]   0.08 0.29 -0.36  0.51   509  1.01
k[6]  -0.38 0.30 -0.88  0.03   585  1.00
k[7]   0.14 0.28 -0.29  0.56   567  1.00
k[8]  -0.21 0.29 -0.66  0.20   526  1.01
k[9]   0.26 0.27 -0.15  0.65   534  1.01
k[10] -0.17 0.36 -0.73  0.36   768  1.00
g      0.61 0.60  0.07  1.70  1321  1.00
b      0.28 0.09  0.14  0.42  1011  1.00
a      1.38 1.05  0.25  3.30  1800  1.00
etasq  0.21 0.22  0.03  0.61   982  1.00
rhosq  1.28 1.56  0.08  4.32  2020  1.00
";

# End of m14_7s.jl