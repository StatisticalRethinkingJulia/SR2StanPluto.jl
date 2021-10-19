using Pkg, DrWatson

begin
    using DimensionalData
    using CategoricalArrays
    using PrettyTables
    using StanSample
    using StatisticalRethinking
    using StatisticalRethinkingPlots
    using PlutoUI
end

begin
    df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
    scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
    data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
        M=df.Marriage_s)
end

stan5_1 = "
data {
    int < lower = 1 > N; // Sample size
    vector[N] D; // Outcome
    vector[N] A; // Predictor
}
parameters {
    real a; // Intercept
    real bA; // Slope (regression coefficients)
    real < lower = 0 > sigma;    // Error SD
}
transformed parameters {
    vector[N] mu;               // mu is a vector
    for (i in 1:N)
        mu[i] = a + bA * A[i];
}
model {
    a ~ normal(0, 0.2);         //Priors
    bA ~ normal(0, 0.5);
    sigma ~ exponential(1);
    D ~ normal(mu , sigma);     // Likelihood
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(D[i] | mu[i], sigma);
}
";

begin
    m5_1s = SampleModel("m5.1s", stan5_1)
    rc5_1s = stan_sample(m5_1s; data)
end;

begin
    das5_1s = read_samples(m5_1s, :dimarrays)
end

size(das5_1s)

begin
    da5_1s = read_samples(m5_1s, :dimarray)
end

axes(da5_1s)

dims(da5_1s)

dims(da5_1s)[2].val

dims(da5_1s)[2].val

size(da5_1s)
