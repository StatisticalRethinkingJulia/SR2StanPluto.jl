#
# This example assumes below packages are available in your environment
#

using Turing, MCMCChains, Distributions, ParetoSmooth, Random
using StatsFuns

Random.seed!(5574)

data = rand(Normal(0, 1), 30)

@model function model(y)
    μ ~ Normal(0, 1)
    σ ~ truncated(Cauchy(0, 1), 0.0, Inf)

    y .~ Normal(μ, σ)
end

chains = sample(model(data), NUTS(1000, .65), MCMCThreads(), 1000, 3)

# method for MCMCChains
function pointwise_loglikes(chain::Chains, data, ll_fun)
    samples = Array(Chains(chain, :parameters).value)
    pointwise_loglikes(samples, data, ll_fun)
end

# generic method for arrays
function pointwise_loglikes(samples::Array{Float64,3}, data, ll_fun)
    n_data = length(data)
    n_samples, n_chains = size(samples)[[1,3]]
    pointwise_lls = fill(0.0, n_data, n_samples, n_chains)
    for c in 1:n_chains 
        for s in 1:n_samples
            for d in 1:n_data
                pointwise_lls[d,s,c] = ll_fun(samples[s,:,c], data[d])
            end
        end
    end
    return pointwise_lls
end

function compute_loo(psis_output, pointwise_lls)
    dims = size(pointwise_lls)
    lwp = deepcopy(pointwise_lls)
    lwp += psis_output.weights;
    lwpt = reshape(lwp, dims[1], dims[2] * dims[3])';
    loos = reshape(logsumexp(lwpt; dims=1), size(lwpt, 2));
    return sum(loos)
end

# compute the pointwise log likelihoods where indices correspond to [data, sample, chain]
pointwise_lls = pointwise_loglikes(chains, data, (p,d)->logpdf(Normal(p...), d))

# compute the psis object
psis_output = psis(pointwise_lls)

# return loo based on Rob's example
loo = compute_loo(psis_output, pointwise_lls)
