### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 7184cb0a-f266-4ed1-bb68-766a982c6ebb
using Pkg, DrWatson

# ╔═╡ aa1d626b-4d59-43c1-a804-f7296f3f2b95
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
	using ParetoSmooth
	using CategoricalArrays, CSV
	using StatisticalRethinkingPlots
	using PlutoUI
end

# ╔═╡ 4b01173e-9c38-478e-a059-78737a0df530
Pkg.status()

# ╔═╡ 2ff66636-0441-4790-815f-c864c879500f
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
end

# ╔═╡ 910aa3fd-af82-44ea-99cb-60154ac99d78
stan5_1 = "
data {
    int < lower = 1 > N; // Sample size
    vector[N] D; // Outcome
    vector[N] A; // Predictor
}
parameters {
    real a; // Intercept
    real bA; // Slope (regression coefficients)
    real < lower = 0 > sigma;    // Error SD
}
transformed parameters {
    vector[N] mu;               // mu is a vector
    for (i in 1:N)
        mu[i] = a + bA * A[i];
}
model {
    a ~ normal(0, 0.2);         //Priors
    bA ~ normal(0, 0.5);
    sigma ~ exponential(1);
    D ~ normal(mu , sigma);     // Likelihood
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(D[i] | mu[i], sigma);
}
";

# ╔═╡ cdadcb73-9b51-4f30-8cb8-acf180fe3b72
stan5_2 = "
data {
    int N;
    vector[N] D;
    vector[N] M;
}
parameters {
    real a;
    real bM;
    real<lower=0> sigma;
}
transformed parameters {
    vector[N] mu;
    for (i in 1:N)
        mu[i]= a + bM * M[i];

}
model {
    a ~ normal( 0 , 0.2 );
    bM ~ normal( 0 , 0.5 );
    sigma ~ exponential( 1 );
    D ~ normal( mu , sigma );
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(D[i] | mu[i], sigma);
}
";

# ╔═╡ 703b698c-acc3-4359-b6a8-ce78d47471c4
stan5_3 = "
data {
  int N;
  vector[N] D;
  vector[N] M;
  vector[N] A;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
transformed parameters {
    vector[N] mu;
    for (i in 1:N)
        mu[i] = a + bA * A[i] + bM * M[i];
}
model {
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
generated quantities{
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(D[i] | mu[i], sigma);
}
";

# ╔═╡ 3d17df8d-8c98-4f3d-b938-3a8f4ff27dfa
begin
	m5_1s = SampleModel("m5.1s", stan5_1)
	rc5_1s = stan_sample(m5_1s; data)

	m5_2s = SampleModel("m5.2s", stan5_2)
	rc5_2s = stan_sample(m5_2s; data)

	m5_3s = SampleModel("m5.3s", stan5_3)
	rc5_3s = stan_sample(m5_3s; data)
end

# ╔═╡ 1e0b6488-c615-4dfd-84ad-eb172e6a0b46
struct LooCompare
    psis::Vector{PsisLoo}
    table::KeyedArray
end

# ╔═╡ 5587fbda-7d9d-4842-9426-99c60d869e10
function loo_compare1(models::Vector{SampleModel}; 
    loglikelihood_name="log_lik",
    model_names=nothing,
    sort_models=true, 
    show_psis=true)

    nmodels = length(models)
    mnames = [models[i].name for i in 1:nmodels]

    ka = Vector{KeyedArray}(undef, nmodels)
    ll = Vector{Array{Float64, 3}}(undef, nmodels)
    psis = Vector{PsisLoo{Float64, Array{Float64, 3},
        Vector{Float64}, Int64, Vector{Int64}}}(undef, nmodels)

    for i in 1:length(models)
        ka[i] = read_samples(models[i], :keyedarray)
        ll[i] = permutedims(Array(matrix(ka[i], loglikelihood_name)), [3, 1, 2])
        psis[i] = psis_loo(ll[i])
        show_psis && psis[i] |> display
    end

    psis_values = Vector{Float64}(undef, nmodels)
    se_values = Vector{Float64}(undef, nmodels)
    loos = Vector{Vector{Float64}}(undef, nmodels)

    for i in 1:nmodels
        psis_values[i] = psis[i].estimates(:cv_est, :total)
        se_values[i] = psis[i].estimates(:cv_est, :se_total)
        loos[i] = psis[i].pointwise(:cv_est)
    end

    if sort_models
        ind = sortperm([psis_values[i][1] for i in 1:nmodels]; rev=true)
        psis = psis[ind]
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
    
    # Create KeyedArray object

    table = KeyedArray(
        data,
        model = mnames,
        statistic = [:cv_est, :se_cv_est, :weight],
    )

    # Return LooCompare object
    
    LooCompare(psis, table)

end

# ╔═╡ 8881729a-8ade-4afe-95e4-5ff6b0096d6a
function Base.show(io::IO, ::MIME"text/plain", loo_compare::LooCompare)
    table = loo_compare.table
    return pretty_table(
        table;
        compact_printing=false,
        header=table.statistic,
        row_names=table.model,
        formatters=ft_printf("%5.2f"),
        alignment=:r,
    )
end

# ╔═╡ 79971d17-89e7-4bac-b1aa-9fb3b2bcce08


# ╔═╡ b9eddbb1-72df-43c6-b655-9fb9458cc6d7
if success(rc5_1s)
    nt5_1s = read_samples(m5_1s, :particles)
    NamedTupleTools.select(nt5_1s, (:a, :bA, :sigma))
end

# ╔═╡ f08ff6a1-ed68-4441-984a-55baa3eef109
if success(rc5_2s)
    nt5_2s = read_samples(m5_2s, :particles)
    NamedTupleTools.select(nt5_2s, (:a, :bM, :sigma))
end

# ╔═╡ 724af235-a95d-4951-a1a1-a9f61af83964
if success(rc5_3s)
    nt5_3s = read_samples(m5_3s, :particles)
    NamedTupleTools.select(nt5_3s, (:a, :bA, :bM, :sigma))
end

# ╔═╡ e50b5498-f941-49c7-b479-7a1a4028c841
if success(rc5_1s) && success(rc5_2s) && success(rc5_3s)

    models = [m5_1s, m5_2s, m5_3s]
    loo_comparison = loo_compare(models)
    #=
    for i in 1:size(loo_comparison.pointwise, 3)
        pw = loo_comparison.pointwise[:, :, i]
        pk_plot(pw(:pareto_k))
        savefig(joinpath(@__DIR__, "m5.$(i)s.png"))
    end
    =#
    with_terminal() do
		Text(sprint(show, "text/plain", loo_comparison))
	end
end

# ╔═╡ 8e11386d-263a-4080-897a-11e77aaf6738
typeof(loo_comparison)

# ╔═╡ 8e4dd710-848f-47c8-8909-2f241461f3cc
if success(rc5_1s) && success(rc5_2s) && success(rc5_3s)

    models2 = [m5_1s, m5_2s, m5_3s]

    loo_comparison2 = loo_compare1(models2)
    #=
    for i in 1:size(loo_comparison.pointwise, 3)
        pw = loo_comparison.pointwise[:, :, i]
        pk_plot(pw(:pareto_k))
        savefig(joinpath(@__DIR__, "m5.$(i)s.png"))
    end
    =#
    with_terminal() do
		Text(sprint(show, "text/plain", loo_comparison2))
	end
end

# ╔═╡ 050785f7-757c-4f81-b01f-30690d8ed42d
typeof(loo_comparison2)

# ╔═╡ 5672fd67-ed76-4c84-a668-64483c42e85d
with_terminal() do
	Text(sprint(show, "text/plain", loo_comparison2.psis[1]))
end

# ╔═╡ 7fb48173-fdf1-482a-8dce-c1479460b35a
#=
With SR/ulam():
```
       PSIS    SE dPSIS  dSE pPSIS weight
m5.1u 126.0 12.83   0.0   NA   3.7   0.67
m5.3u 127.4 12.75   1.4 0.75   4.7   0.33
m5.2u 139.5  9.95  13.6 9.33   3.0   0.00
```
=#

# ╔═╡ Cell order:
# ╠═7184cb0a-f266-4ed1-bb68-766a982c6ebb
# ╠═aa1d626b-4d59-43c1-a804-f7296f3f2b95
# ╠═4b01173e-9c38-478e-a059-78737a0df530
# ╠═2ff66636-0441-4790-815f-c864c879500f
# ╠═910aa3fd-af82-44ea-99cb-60154ac99d78
# ╠═cdadcb73-9b51-4f30-8cb8-acf180fe3b72
# ╠═703b698c-acc3-4359-b6a8-ce78d47471c4
# ╠═3d17df8d-8c98-4f3d-b938-3a8f4ff27dfa
# ╠═1e0b6488-c615-4dfd-84ad-eb172e6a0b46
# ╠═5587fbda-7d9d-4842-9426-99c60d869e10
# ╠═8881729a-8ade-4afe-95e4-5ff6b0096d6a
# ╠═79971d17-89e7-4bac-b1aa-9fb3b2bcce08
# ╠═b9eddbb1-72df-43c6-b655-9fb9458cc6d7
# ╠═f08ff6a1-ed68-4441-984a-55baa3eef109
# ╠═724af235-a95d-4951-a1a1-a9f61af83964
# ╠═e50b5498-f941-49c7-b479-7a1a4028c841
# ╠═8e11386d-263a-4080-897a-11e77aaf6738
# ╠═8e4dd710-848f-47c8-8909-2f241461f3cc
# ╠═050785f7-757c-4f81-b01f-30690d8ed42d
# ╠═5672fd67-ed76-4c84-a668-64483c42e85d
# ╠═7fb48173-fdf1-482a-8dce-c1479460b35a
