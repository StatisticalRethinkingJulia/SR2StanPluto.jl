#
# This example assumes below packages are available in your environment
#

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StatsModelComparisons, StanSample
using StatsFuns, CSV, Random
using ParetoSmooth, Bombe
using StatisticalRethinking

ProjDir = @__DIR__

df = CSV.read(joinpath(ProjDir, "..", "data", "cars.csv"), DataFrame)

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
"

Random.seed!(1)
cars_stan_model = SampleModel("cars.model", cars_stan)
data = (N = size(df, 1), speed = df.Speed, dist = df.Dist)
rc = stan_sample(cars_stan_model; data)
println()

if success(rc)
    #stan_summary(cars_stan_model, true)
    nt_cars = read_samples(cars_stan_model);
end

log_lik = nt_cars.log_lik';
n_sam, n_obs = size(log_lik)
lppd = reshape(logsumexp(log_lik .- log(n_sam); dims=1), n_obs);

pwaic = [var(log_lik[:, i]) for i in 1:n_obs];
@show -2(sum(lppd) - sum(pwaic))
println()

@show waic(log_lik)
println()

#Random.seed!(123)
loo, loos, pk = psisloo(log_lik);
@show -2loo

#Random.seed!(123)
ll = reshape(nt_cars.log_lik, 50, 1000, 4);
psis_ll = psis(ll);

lwp = deepcopy(ll);
lwp += psis_ll.weights;
lwpt = Matrix(reshape(lwp, 50, 4000)');
loos = reshape(logsumexp(lwpt; dims=1), size(lwpt, 2));

@show loo = sum(loos)
@show 2loo

pk_plot(pk)
savefig(joinpath(ProjDir, "pk.png"))

pk_plot(psis_ll.pareto_k)
savefig(joinpath(ProjDir, "pareto_k.png"))
