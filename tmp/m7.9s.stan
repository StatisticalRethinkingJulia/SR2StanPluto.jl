data {
    int<lower=1> K;
    int<lower=0> N;
    matrix[N, K] x;
    vector[N] y;
}
parameters {
    real a;
    vector[K] b;
    real<lower=0> sigma;
}
transformed parameters {
    vector[N] mu;
    mu = a + x * b;
}
model {
    a ~ normal(0, 100);
    b ~ normal(0, 10);
    sigma ~ exponential(1);
    y ~ normal(mu, sigma);          // observed model
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | mu[i], sigma);
}