### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 31b32634-6730-11eb-1eb6-d512e0afd93c
using Pkg, DrWatson

# ╔═╡ 417ce078-6730-11eb-0150-d515235783f0
begin
	using ParetoSmoothedImportanceSampling
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ 63ddbd40-6730-11eb-3a30-61121b8061b0
df = DataFrame(
	speed = [4, 4, 7, 7, 8, 9, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13,
		13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 18,
		19, 19, 19, 20, 20, 20, 20, 20, 22, 23, 24, 24, 24, 24, 25],
	dist = [2, 10, 4, 22, 16, 10, 18, 26, 34, 17, 28, 14, 20, 24, 28, 26, 34,
		34, 46, 26, 36, 60, 80, 20, 26, 54, 32, 40, 32, 40, 50, 42, 56, 76, 84,
		36, 46, 68, 32, 48, 52, 56, 64, 66, 54, 70, 92, 93, 120, 85]
);

# ╔═╡ 85013b04-6731-11eb-3df7-4f9ba267f65b
PRECIS(df)

# ╔═╡ 97755284-6731-11eb-3a87-51384900e50b
cars_stan = "
data {
    int N;
    vector[N] speed;
    vector[N] dist;
}
parameters {
    real a;
    real b;
    real sigma;
}
transformed parameters{
    vector[N] mu;
    mu = a + b * speed;
}
model {
    a ~ normal(0, 100);
    b ~ normal(0, 10);
    sigma ~ exponential(1);
    dist ~ normal(mu, sigma)    ;
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(dist[i] | mu[i], sigma);
}
";

# ╔═╡ a3a5ba84-6732-11eb-3051-afe0b875f51b
begin
cars_stan_model = SampleModel("cars.model", cars_stan)
	data = (N = size(df, 1), speed = df.speed, dist = df.dist)
	rc = stan_sample(cars_stan_model; data)

	if success(rc)
		stan_summary(cars_stan_model, true)
		nt_cars = read_samples(cars_stan_model);
	end
end;

# ╔═╡ 1d99951e-673c-11eb-3920-49db0451c1cd
begin
	post_df = read_samples(cars_stan_model, :dataframe)
	PRECIS(post_df[:, [:a, :b, :sigma]])
end

# ╔═╡ a3a5feae-6732-11eb-2893-7397c30b2daa
begin
	log_lik = nt_cars.log_lik'
	n_sam, n_obs = size(log_lik)
	lppds = reshape(lppd(log_lik), n_obs)
	sum(lppds)
end

# ╔═╡ 41909984-6734-11eb-1cd7-79ae89926d10
size(log_lik)

# ╔═╡ a3a6bcfe-6732-11eb-0b05-db55dac22d9c
begin
	pwaic = [var2(log_lik[:, i]) for i in 1:n_obs]
	-2(sum(lppds) - sum(pwaic))
end

# ╔═╡ 17b3bcb0-6741-11eb-1d7a-69218af68695
md"
!!! note
	Below WAIC value is identical to the value obtained by switching to rethinking's ulam() for the cars data."

# ╔═╡ a3b8541e-6732-11eb-14a2-515449707918
waic(log_lik)

# ╔═╡ a1ef0db2-6732-11eb-05e9-67cda4f8de09
begin
	loo, loos, pk = psisloo(log_lik)
	loo
end

# ╔═╡ 995fbd44-6733-11eb-216c-47405debe19d
sum(loos)

# ╔═╡ bb0ef2de-6733-11eb-0b0e-5339d80ffdfd
-2(loo - sum(pwaic))

# ╔═╡ 7b69ec38-6733-11eb-02a2-25ea26f08d22
pk_qualify(pk)

# ╔═╡ 83adace8-6733-11eb-33af-c3d49d9385b1
pk_plot(pk)

# ╔═╡ 0552e952-8385-11eb-1d2f-154960f187ba
md" ### End of clip-07-19-24s.jl"

# ╔═╡ Cell order:
# ╠═31b32634-6730-11eb-1eb6-d512e0afd93c
# ╠═417ce078-6730-11eb-0150-d515235783f0
# ╠═63ddbd40-6730-11eb-3a30-61121b8061b0
# ╠═85013b04-6731-11eb-3df7-4f9ba267f65b
# ╠═97755284-6731-11eb-3a87-51384900e50b
# ╠═a3a5ba84-6732-11eb-3051-afe0b875f51b
# ╠═1d99951e-673c-11eb-3920-49db0451c1cd
# ╠═a3a5feae-6732-11eb-2893-7397c30b2daa
# ╠═41909984-6734-11eb-1cd7-79ae89926d10
# ╠═a3a6bcfe-6732-11eb-0b05-db55dac22d9c
# ╟─17b3bcb0-6741-11eb-1d7a-69218af68695
# ╠═a3b8541e-6732-11eb-14a2-515449707918
# ╠═a1ef0db2-6732-11eb-05e9-67cda4f8de09
# ╠═995fbd44-6733-11eb-216c-47405debe19d
# ╠═bb0ef2de-6733-11eb-0b0e-5339d80ffdfd
# ╠═7b69ec38-6733-11eb-02a2-25ea26f08d22
# ╠═83adace8-6733-11eb-33af-c3d49d9385b1
# ╟─0552e952-8385-11eb-1d2f-154960f187ba
