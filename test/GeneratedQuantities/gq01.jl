using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

function sim_train_test(N::Int, K::Int, rho = [0.15, -0.4]) 

    n_dim = 1 + length(rho)
    n_dim = n_dim < K ? K : n_dim
    
    Rho = Matrix{Float64}(I, n_dim, n_dim)
    for i in 1:length(rho)
        Rho[i+1, 1] = Rho[1, i + 1] = rho[i]
    end
    
    x_train = Matrix(rand(MvNormal(zeros(n_dim), Rho), N)')
    x_test = Matrix(rand(MvNormal(zeros(n_dim), Rho), N)')
    y = x_train[:, 1]
    x_train = x_train[:, 2:n_dim]
    (y, x_train, x_test[:, 2:n_dim])
end

stan_01 = "
data {
    int<lower=1> K;
    int<lower=0> N;
    matrix[N, K] x;
    vector[N] y;

    int<lower=0> N_new;
    matrix[N_new, K] x_new;
}
parameters {
    real a;
    vector[K] b;
    real<lower=0> sigma;

    vector[N_new] y_new;                  // predictions
}
transformed parameters {
    vector[N] mu;
    vector[N_new] mu_new;

    mu = a + x * b;
    mu_new = a + x_new * b;
}
model {
    y ~ normal(mu, sigma);          // observed model
    y_new ~ normal(mu_new, sigma);  // prediction model
}
generated quantities {
    vector[N] log_lik;
    vector[N_new] log_lik_new;

    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | mu[i], sigma);

    for (j in 1:N_new)
        log_lik_new[j] = normal_lpdf(y_new[j] | mu_new[j], sigma);

}
";

sm = SampleModel("stan_01", stan_01)
N = 100
K = 6
rho = [0.15, -0.4]
y, x_train, x_test = sim_train_test(N, K, rho)
println(length(y))
println(size(x_train))
println(size(x_test))
k = K < 2 ? K : K - 1
data = (N = size(x_train, 1), K = size(x_train, 2), y = y,
    x = x_train, N_new = size(x_test, 1), x_new = x_test)
rc = stan_sample(sm; data)
if success(rc)
    sm_df = read_samples(sm, :dataframe)
    precis(sm_df[:, vcat([:a], [Symbol("b.$i") for i in 1:k])])
end

nt = read_samples(sm)
log_lik = nt.log_lik'
log_lik_new = nt.log_lik_new'

loo, loos, pk = psisloo(log_lik)
loo_new, loos_new, pk_new = psisloo(log_lik_new)

[K, loo, loo_new] |> display

#plot(y)
#plot!(nt.y_new')