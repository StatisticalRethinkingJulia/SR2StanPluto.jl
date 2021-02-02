### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 265ed188-5bf6-11eb-0d29-51ea74e6c7d1
using Pkg, DrWatson

# ╔═╡ ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ a4042486-5bf5-11eb-0183-33fd00d868e4
md" ## Clip-07-18s.jl"

# ╔═╡ ac6f6634-5bf6-11eb-0929-b5ed20ab3036
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

# ╔═╡ ac8227b2-5bf6-11eb-27dd-09924b99e6c2
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

# ╔═╡ 00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
m7_9s = SampleModel("m7.9s", stan7_9);

# ╔═╡ 5d5b8982-64b2-11eb-0ca9-b94e3197ff31
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

# ╔═╡ f253787c-64c3-11eb-2cd4-9322707100b7
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

# ╔═╡ b481987e-64c5-11eb-3d96-4b1e4adf242c
mean_is = mean(in_sample_deviance, dims=1)

# ╔═╡ 61bd0eba-657f-11eb-0593-072e7c8dc510
std(in_sample_deviance, dims=1)

# ╔═╡ c938af32-64c5-11eb-3b78-53bd350c8e39
mean_oos = mean(out_of_sample_deviance, dims=1)

# ╔═╡ 736f7594-657f-11eb-239d-73cab1fd5e5d
std(out_of_sample_deviance, dims=1)

# ╔═╡ 7eb8b028-657f-11eb-0abf-37c3819aea78
begin
	scatter(mean_is[1,:], xlab = "No of parameters", ylab = "Deviance",
		ylims=(200, 400), lab="In sample")
	scatter!(mean_oos[1,:], xlab = "No of parameters", ylab = "Deviance",
		lab = "Out of sample")
end

# ╔═╡ 263e7030-657b-11eb-1614-89eb98d87ef8
begin
	fig1a = pk_plot(pks_is[:, 1, 1])
	fig2a = pk_plot(pks_oos[:, 1, 1])
	plot(fig1a, fig2a, layout=(1, 2))
end

# ╔═╡ b8dbc372-6565-11eb-2cce-5b005337c92a
begin
	fig1b = pk_plot(pks_is[:, 1, 2])
	fig2b = pk_plot(pks_oos[:, 1, 2])
	plot(fig1b, fig2b, layout=(1, 2))
end

# ╔═╡ 4fbbe5bc-657b-11eb-149d-c7f3f1080d21
begin
	fig1c = pk_plot(pks_is[:, 1, 3])
	fig2c = pk_plot(pks_oos[:, 1, 3])
	plot(fig1c, fig2c, layout=(1, 2))
end

# ╔═╡ 737b9faa-657b-11eb-2bbd-a5001aacefa5
begin
	fig1d = pk_plot(pks_is[:, 1, 4])
	fig2d = pk_plot(pks_oos[:, 1, 4])
	plot(fig1d, fig2d, layout=(1, 2))
end

# ╔═╡ 90396b52-657b-11eb-018b-2b1d3e63083b
begin
	fig1e = pk_plot(pks_is[:, 1, 5])
	fig2e = pk_plot(pks_oos[:, 1, 5])
	plot(fig1e, fig2e, layout=(1, 2))
end

# ╔═╡ 92040134-657b-11eb-3c45-47708152dc68
begin
	fig1f = pk_plot(pks_is[:, 1, 6])
	fig2f = pk_plot(pks_oos[:, 1, 6])
	plot(fig1f, fig2f, layout=(1, 2))
end

# ╔═╡ 7a185d54-657d-11eb-246e-672b0d809163
begin
	fig1g = pk_plot(pks_is[:, 2, 6])
	fig2g = pk_plot(pks_oos[:, 2, 6])
	plot(fig1g, fig2g, layout=(1, 2))
end

# ╔═╡ 74d4016e-6563-11eb-0c3b-b7c4f81baca6
md" ## End of clip-07-18s.jl"

# ╔═╡ Cell order:
# ╟─a4042486-5bf5-11eb-0183-33fd00d868e4
# ╠═265ed188-5bf6-11eb-0d29-51ea74e6c7d1
# ╠═ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
# ╠═ac6f6634-5bf6-11eb-0929-b5ed20ab3036
# ╠═ac8227b2-5bf6-11eb-27dd-09924b99e6c2
# ╠═00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
# ╠═5d5b8982-64b2-11eb-0ca9-b94e3197ff31
# ╠═f253787c-64c3-11eb-2cd4-9322707100b7
# ╠═b481987e-64c5-11eb-3d96-4b1e4adf242c
# ╠═61bd0eba-657f-11eb-0593-072e7c8dc510
# ╠═c938af32-64c5-11eb-3b78-53bd350c8e39
# ╠═736f7594-657f-11eb-239d-73cab1fd5e5d
# ╠═7eb8b028-657f-11eb-0abf-37c3819aea78
# ╠═263e7030-657b-11eb-1614-89eb98d87ef8
# ╠═b8dbc372-6565-11eb-2cce-5b005337c92a
# ╠═4fbbe5bc-657b-11eb-149d-c7f3f1080d21
# ╠═737b9faa-657b-11eb-2bbd-a5001aacefa5
# ╠═90396b52-657b-11eb-018b-2b1d3e63083b
# ╠═92040134-657b-11eb-3c45-47708152dc68
# ╠═7a185d54-657d-11eb-246e-672b0d809163
# ╟─74d4016e-6563-11eb-0c3b-b7c4f81baca6
