function cmp(models::Vector{SampleModel}, type::Symbol)
    mnames = String[]
    lps = Matrix{Float64}[]
    for m in models
        nt = read_samples(m)
        if :log_lik in keys(nt)
            append!(mnames, String.([m.name]))
            append!(lps, [Matrix(nt.log_lik')])
        else
            @warn "Model $(m.name) does not produce a log_lik matrix."
        end
    end
    (lps, type, mnames)
end

function cmp(m::Vector{Matrix{Float64}}, type::Symbol;
    mnames=String[])

    df = DataFrame()
    loo = Vector{Float64}(undef, length(m))
    loos = Vector{Vector{Float64}}(undef, length(m))
    pk = Vector{Vector{Float64}}(undef, length(m))
    for i in 1:length(m)
        loo[i], loos[i], pk[i] = psisloo(m[i])
    end
    ind = sortperm([-2loo[i][1] for i in 1:length(m)])

    mods = m[ind]
    loo = loo[ind]
    loos = loos[ind]
    pk = pk[ind]

    if length(mnames) > 0
        df.models = String.(mnames[ind])
    end

    df.PSIS = round.([-2loo[i] for i in 1:length(loo)], digits=1)
    df.SE = round.([sqrt(size(m[i], 2)*var2(-2loos[i])) for i in 1:length(m)],
        digits=2)
    
    dloo = zeros(length(m))
    for i in 2:length(m)
        dloo[i] = df[i, :PSIS] - df[1, :PSIS]
    end
    df.dPSIS = round.(dloo, digits=1)

    dse = zeros(length(m))
    for i in 2:length(m)
        diff = 2(loos[1] .- loos[i])
        dse[i] = √(length(loos[i]) * var2(diff))
    end
    df.dSE = round.(dse, digits=2)

    ps = zeros(length(m))
    lppds = zeros(length(m))
    for j in 1:length(m)
        n_sam, n_obs = size(mods[j])
        pd = zeros(length(m), n_obs)
        pd[j, :] = [var2(mods[j][:,i]) for i in 1:n_obs]
        ps[j] = sum(pd[j, :])
    end
    df.pPSIS = round.(ps, digits=2)

    weights = ones(length(m))
    sumval = sum([exp(-0.5df[i, :PSIS]) for i in 1:length(m)])
    for i in 1:length(m)
        weights[i] = exp(-0.5df[i, :PSIS])/sumval
    end
    df.weight = round.(weights, digits=2)
    df
end

compare([m8_1s, m8_2s], :waic) |> display

lps, type, mnames = cmp([m8_1s, m8_2s], :psis)

cmp(lps, type; mnames) |> display

md"
```

> PSIS(m8.1)
       PSIS    lppd  penalty  std_err
1 -188.6114 94.3057 2.755778 13.35391

> PSIS(m8.2)
       PSIS     lppd  penalty  std_err
1 -252.1136 126.0568 4.272533 15.29773

> compare( m8.1 , m8.2 )
       WAIC   SE dWAIC   dSE pWAIC weight
m8.2 -252.3 15.3   0.0    NA   4.3      1
m8.1 -188.7 13.3  63.5 15.15   2.7      0

> compare( m8.1 , m8.2, func=PSIS )
Some Pareto k values are high (>0.5). Set pointwise=TRUE to inspect individual points.
       PSIS    SE dPSIS   dSE pPSIS weight
m8.2 -252.1 15.28   0.0    NA   4.3      1
m8.1 -188.7 13.40  63.4 15.16   2.7      0
```
"

l, ls, pk = psisloo(m8_1s)
sum(ls)
