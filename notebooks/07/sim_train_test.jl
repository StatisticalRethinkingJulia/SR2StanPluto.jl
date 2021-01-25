using StatisticalRethinking

function sim_train_test(;
    N = 20, k = 3,
    rho = [0.15, -0.4], 
    b_sigma = 100,
    WAIC = false, LOOCV=false, LOOIC=false,
    return_model=false ) 

    n_dim = 1 + length(rho)
    if n_dim < k 
        n_dim = k
    end
    Rho = Matrix{Float64}(I, n_dim, n_dim)
    for i in 1:length(rho)
        Rho[i+1, 1] = Rho[1, i + 1] = rho[i]
    end
    x_train = rand(MvNormal(zeros(n_dim), Rho), N)
    x_test = Matrix(rand(MvNormal(zeros(n_dim), Rho), N)')
    mm_train = hcat(ones(N, 1), x_train[2:end, :]')
    (x_train[1, :], mm_train, x_test)
end

N = 20; k = 3
rho = [0.15, -0.4] 
b_sigma = 100
WAIC = false; LOOCV=false; LOOIC=false
return_model=false

y, mm_train, x_test = sim_train_test()

data = (y = x_train[:,1], )

stan7_8 = "
data{
    int N;
    int K;
    vector[N] y;
    matrix[N, K] x1;
    matrix[N, K] x2;
}
parameters{
    real a;
    vector[K] b1;
    vector[K] b2;
}
transformed parameters{
    vector[N] mu;
    mu = a + x1 * b1 + x2 * b2
}
model{
    a ~ normal(0, 10)
    b1 ~ normal(0, 1)
    b2 ~ normal(0, 1)
    y ~ normal(mu, 1);
}
generated quantities{
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | u[i], 1)
}
";

