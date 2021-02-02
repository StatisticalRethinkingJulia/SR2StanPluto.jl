
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-18s.jl"

function sim_train_test(;
    N = 20,
	K = 3,
    rho = [0.15, -0.4]) 

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

m7_9s = SampleModel("m7.9s", stan7_9);

begin
	N = 100
	rho = [0.15, -0.4]
	L = 20
	K = 6
	k = K < 2 ? K : K - 1
	in_sample_deviance = zeros(L, K)
	out_of_sample_deviance = zeros(L, K)
	pks_is = zeros(N, L, K)
	pks_oos = zeros(N, L, K)
end;

begin
	for i in 1:L
		for j = 1:K
			y, x_train, x_test = sim_train_test(;N, K, rho)
			data = (N = size(x_train, 1), K = size(x_train, 2),
				y = y, x = x_train,
				N_new = size(x_test, 1), x_new = x_test)
			rc7_9s = stan_sample(m7_9s; data)
			if success(rc7_9s)
				nt7_9s = read_samples(m7_9s)
				
				log_lik_is = nt7_9s.log_lik'
				loo_is, loos_is, pk_is = psisloo(log_lik_is)
				in_sample_deviance[i, j] = -2loo_is
				pks_is[:, i, j] = pk_is
				
				log_lik_oos = nt7_9s.log_lik_new'
				loo_oos, loos_oos, pk_oos = psisloo(log_lik_oos)
				out_of_sample_deviance[i, j] = -2loo_oos
				pks_oos[:, i, j] = pk_oos
			end
		end
	end
    post7_9s_df = read_samples(m7_9s; output_format=:dataframe)
    PRECIS(post7_9s_df[:, vcat([:a], [Symbol("b.$i") for i in 1:k])])
end

mean_is = mean(in_sample_deviance, dims=1)

std(in_sample_deviance, dims=1)

mean_oos = mean(out_of_sample_deviance, dims=1)

std(out_of_sample_deviance, dims=1)

begin
	scatter(mean_is[1,:], xlab = "No of parameters", ylab = "Deviance",
		ylims=(200, 400), lab="In sample")
	scatter!(mean_oos[1,:], xlab = "No of parameters", ylab = "Deviance",
		lab = "Out of sample")
end

begin
	fig1a = pk_plot(pks_is[:, 1, 1])
	fig2a = pk_plot(pks_oos[:, 1, 1])
	plot(fig1a, fig2a, layout=(1, 2))
end

begin
	fig1b = pk_plot(pks_is[:, 1, 2])
	fig2b = pk_plot(pks_oos[:, 1, 2])
	plot(fig1b, fig2b, layout=(1, 2))
end

begin
	fig1c = pk_plot(pks_is[:, 1, 3])
	fig2c = pk_plot(pks_oos[:, 1, 3])
	plot(fig1c, fig2c, layout=(1, 2))
end

begin
	fig1d = pk_plot(pks_is[:, 1, 4])
	fig2d = pk_plot(pks_oos[:, 1, 4])
	plot(fig1d, fig2d, layout=(1, 2))
end

begin
	fig1e = pk_plot(pks_is[:, 1, 5])
	fig2e = pk_plot(pks_oos[:, 1, 5])
	plot(fig1e, fig2e, layout=(1, 2))
end

begin
	fig1f = pk_plot(pks_is[:, 1, 6])
	fig2f = pk_plot(pks_oos[:, 1, 6])
	plot(fig1f, fig2f, layout=(1, 2))
end

begin
	fig1g = pk_plot(pks_is[:, 2, 6])
	fig2g = pk_plot(pks_oos[:, 2, 6])
	plot(fig1g, fig2g, layout=(1, 2))
end

md" ## End of clip-07-18s.jl"

