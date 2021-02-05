
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-20s.jl"

stan7_9 = "
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

ProjDir = @__DIR__
tmpdir = joinpath(ProjDir, "tmp")
m7_9s = SampleModel("m7.9s", stan7_9; tmpdir);

begin
	N = 20
	rho = [0.15, -0.4]
	K = 2
end;

begin
	y, x_train, x_test = sim_train_test(;N, K, rho)
	data = (N = size(x_train, 1), K = size(x_train, 2),
		y = y, x = x_train,
		N_new = size(x_test, 1), x_new = x_test)
	rc7_9s = stan_sample(m7_9s; data)
	if success(rc7_9s)
		nt7_9s = read_samples(m7_9s)
		
		ll_is = nt7_9s.log_lik'
		loo_is, loos_is, pk_is = psisloo(ll_is)
		
		ll_oos = nt7_9s.log_lik_new'
		loo_oos, loos_oos, pk_oos = psisloo(ll_oos)
	end
    post7_9s_df = read_samples(m7_9s; output_format=:dataframe)
    precis(post7_9s_df[:, vcat([:a], [Symbol("b.$i") for i in 1:K])])
end

lppd_is = lppd(ll_is)
lppd_oos = lppd(ll_oos)
[-2sum(lppd_is), -2sum(lppd_oos)] |> display
[-2loo_is, -2loo_oos] |> display

md" ## End of clip-07-20s.jl"

