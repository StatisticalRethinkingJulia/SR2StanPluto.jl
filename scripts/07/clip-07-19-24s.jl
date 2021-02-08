
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

df = DataFrame(
	speed = [4, 4, 7, 7, 8, 9, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13,
		13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 18,
		19, 19, 19, 20, 20, 20, 20, 20, 22, 23, 24, 24, 24, 24, 25],
	dist = [2, 10, 4, 22, 16, 10, 18, 26, 34, 17, 28, 14, 20, 24, 28, 26, 34,
		34, 46, 26, 36, 60, 80, 20, 26, 54, 32, 40, 32, 40, 50, 42, 56, 76, 84,
		36, 46, 68, 32, 48, 52, 56, 64, 66, 54, 70, 92, 93, 120, 85]
);

PRECIS(df)

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

begin
cars_stan_model = SampleModel("cars.model", cars_stan)
	data = (N = size(df, 1), speed = df.speed, dist = df.dist)
	rc = stan_sample(cars_stan_model; data)

	if success(rc)
		stan_summary(cars_stan_model, true)
		nt_cars = read_samples(cars_stan_model);
	end
end;

begin
	post_df = read_samples(cars_stan_model; output_format=:dataframe)
	PRECIS(post_df[:, [:a, :b, :sigma]])
end

begin
	log_lik = nt_cars.log_lik'
	n_sam, n_obs = size(log_lik)
	lppds = reshape(lppd(log_lik), n_obs)
	sum(lppds)
end

size(log_lik)

begin
	pwaic = [var(log_lik[:, i]) for i in 1:n_obs]
	-2(sum(lppds) - sum(pwaic))
end

md"
!!! note
	Below WAIC value is identical to the value obtained by switching to rethinking's ulam() for the cars data."

waic(log_lik)

begin
	loo, loos, pk = psisloo(log_lik)
	loo
end

sum(loos)

-2(loo - sum(pwaic))

pk_qualify(pk)

pk_plot(pk)

