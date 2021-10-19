struct PsisLooComparison
    psis::Vector{PsisLoo}
    df::DataFrame
end

function psis_loo_compare(models::Vector{SampleModel}; 
    loglikelihood_name="log_lik",
    model_names=nothing,
    sort_models=true)

    nmodels = length(models)
    mnames = [models[i].name for i in 1:nmodels]

    chains_vec = read_samples.(models, :namedtuple)
    ll_vec = Array.(matrix.(chains_vec, loglikelihood_name))
    ll_vecp = map(to_paretosmooth, ll_vec)
    psis_vec = psis_loo.(ll_vecp)

    psis_values = Vector{Float64}(undef, nmodels)
    se_values = Vector{Float64}(undef, nmodels)
    loos = Vector{Vector{Float64}}(undef, nmodels)

    for i in 1:nmodels
        psis_values[i] = psis_vec[i].estimates(:cv_elpd, :total)
        se_values[i] = psis_vec[i].estimates(:cv_elpd, :se_total)
        loos[i] = psis_vec[i].pointwise(:cv_elpd)
    end

    if sort_models
        ind = sortperm([psis_values[i][1] for i in 1:nmodels]; rev=true)
        psis_vec = psis_vec[ind]
        psis_values = psis_values[ind]
        se_values = se_values[ind]
        loos = loos[ind]
        mnames = mnames[ind]
    end

    # Setup comparison vectors

    elpd_diff = zeros(nmodels)
    se_diff = zeros(nmodels)
    weight = ones(nmodels)

    # Compute comparison values

    for i in 2:nmodels
        elpd_diff[i] = psis_values[i] - psis_values[1]
        diff = loos[1] - loos[i]
        se_diff[i] = √(length(loos[i]) * var(diff; corrected=false))
    end
    data = elpd_diff
    data = hcat(data, se_diff)

    sumval = sum([exp(psis_values[i]) for i in 1:nmodels])
    @. weight = exp(psis_values) / sumval
    data = hcat(data, weight)
    
    # Create DataFrame object for display
    
    df = DataFrame()
    
    if length(mnames) > 0
        df.models = String.(mnames)
    end

    df.PSIS = round.(-2 .* [psis_values[i] for i in 1:nmodels], digits=1)
    df.lppd = zeros(nmodels)
    df.SE = se_diff
    
    dloo = zeros(nmodels)
    for i in 2:nmodels
        dloo[i] = df[i, :PSIS] - df[1, :PSIS]
    end
    df.dPSIS = round.(dloo, digits=1)
    
    dse = zeros(nmodels)
    for i in 2:nmodels
        diff = 2(loos[1] .- loos[i])
        dse[i] = √(length(loos[i]) * var(diff; corrected=false))
    end
    df.dSE = round.(dse, digits=2)
    
    ps = zeros(nmodels)
    for i in 1:nmodels
    end
    df.pPSIS = ps
   
    # Return PsisLooCompare object
    
    PsisLooComparison(psis_vec, df)

end
