
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-19s.jl"

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

N = 20
rho = [0.15, -0.4]
L = 30
K = 5
in_sample_deviance = zeros(L, K)
out_of_sample_deviance = zeros(L, K)
lppd_is = zeros(L, K)
lppd_oos = zeros(L, K)
pks_is = zeros(N, L, K)
pks_oos = zeros(N, L, K)

begin
	for i in 1:L
		for j = 1:K
			local y, x_train, x_test = sim_train_test(;N, K, rho)
			local data = (N = size(x_train, 1), K = size(x_train, 2),
				y = y, x = x_train,
				N_new = size(x_test, 1), x_new = x_test)
			local rc7_9s = stan_sample(m7_9s; data)
			if success(rc7_9s)
				global nt7_9s = read_samples(m7_9s)
				
				log_lik_is = nt7_9s.log_lik'
				local loo_is, loos_is, pk_is = psisloo(log_lik_is)
				global in_sample_deviance[i, j] = -2loo_is
                global lppd_is[i, j] = -2sum(lppd(log_lik_is))
				global pks_is[:, i, j] = pk_is
				
				log_lik_oos = nt7_9s.log_lik_new'
				local loo_oos, loos_oos, pk_oos = psisloo(log_lik_oos)
				global out_of_sample_deviance[i, j] = -2loo_oos
                global lppd_oos[i, j] = -2sum(lppd(log_lik_oos))
				global pks_oos[:, i, j] = pk_oos
			end
		end
	end
    post7_9s_df = read_samples(m7_9s; output_format=:dataframe)
    precis(post7_9s_df[:, vcat([:sigma, :a], [Symbol("b.$i") for i in 1:K])])
end

mean_is = mean(in_sample_deviance, dims=1)
mean_lppd_is = mean(lppd_is, dims=1)

std(in_sample_deviance, dims=1)

mean_oos = mean(out_of_sample_deviance, dims=1)
mean_lppd_oos = mean(lppd_oos, dims=1)

std(out_of_sample_deviance, dims=1)

begin
	scatter(mean_is[1,:], xlab = "No of parameters", ylab = "Deviance (loo)",
		lab="In sample (loo)")
	scatter!(mean_oos[1,:], xlab = "No of parameters", ylab = "Deviance (loo)",
		lab = "Out of sample (loo)")
    scatter!(mean_lppd_is[1,:], xlab = "No of parameters", ylab = "Deviance (lppd)",
        lab="In sample (lppd)")
    scatter!(mean_lppd_oos[1,:], xlab = "No of parameters", ylab = "Deviance (lppd)",
        lab = "Out of sample (lppd)")
end
savefig(joinpath(ProjDir, "clip-07-19-fig.png"))

md" ## End of clip-07-19s.jl"

