#
# This example assumes below packages are available in your environment
#

using StatsModelComparisons, StanSample
using StatsFuns, CSV, Random
using ParetoSmooth
#using StatisticalRethinking

ProjDir = @__DIR__

df = CSV.read(joinpath(ProjDir, "cars_logprob.csv"), DataFrame)

log_lik = Matrix(df)';
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
ll = reshape(Matrix(df), 50, 1000, 4);
psis_ll = psis(ll);

lwp = deepcopy(ll);
lwp += psis_ll.weights;
lwpt = Matrix(reshape(lwp, 50, 4000)');
loos = reshape(logsumexp(lwpt; dims=1), size(lwpt, 2));

@show loo = sum(loos)
@show 2loo

if isdefined(Main, :StatisticalRethinking)
    pk_plot(pk)
    savefig(joinpath(ProjDir, "pk.png"))

    pk_plot(psis_ll.pareto_k)
    savefig(joinpath(ProjDir, "pareto_k.png"))
end