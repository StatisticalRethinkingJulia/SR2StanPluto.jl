### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 63577d5e-8d41-4bc5-8d4c-c74be034d08c
using Pkg, DrWatson

# ╔═╡ a2d386d3-782f-4042-bae9-9751c73d42b5
begin
    # Use '#@quickactivate ...' to enable Pluto Pkg management.
    # Remove '#' to disable Pluto Pkg management.
    # Careful: It will _no longer_ be a reproducible environment!
    @quickactivate "StatisticalRethinkingStan"
end

# ╔═╡ 88faad64-f887-44d6-99e5-d56e9d6df486
begin
	using DataFrames
    using PrettyTables
    using StanSample
    using StatisticalRethinking
    using StatisticalRethinkingPlots
    using PlutoUI
end

# ╔═╡ 865295d7-451e-437b-bc4d-cbd939d3a080
md"#### Below cell enables switching between dev-environments and package environments. In most cases use `#@quickactivate ...`"

# ╔═╡ da61fb27-229d-4885-ba23-580f088db42b
begin
    df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
    scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
    data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
        M=df.Marriage_s)
end;

# ╔═╡ d4cc546f-cb4d-401d-bf7e-5c87e1ac8fcd
df

# ╔═╡ c6ccfa63-fd10-4d2a-b260-8fdba221f6d7
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

# ╔═╡ 5041bb2f-ba75-47cc-9a9a-40b6882fe161
begin
    m5_1s = SampleModel("m5.1s", stan5_1)
    rc5_1s = stan_sample(m5_1s; data)
end;

# ╔═╡ c63617a8-aea2-4e01-baca-e000fe1a8268
if success(rc5_1s)
    st5_1s = read_samples(m5_1s, :table)
end

# ╔═╡ 6d3a8e78-0758-463c-aa18-948dee2decef
df5_1s = DataFrame(st5_1s)

# ╔═╡ 4e8dfe63-f39b-4847-8e62-ad184ae222c6
md"#### Select a set of columns."

# ╔═╡ 270a906b-575c-4bcf-adcd-1ddfca3b42a5
df5_1s[:, [:a, :bA]]

# ╔═╡ be3252ef-32a6-411b-8c69-fc0a41b8ca96
md"#### Select a block of variables using Stan '.' notation."

# ╔═╡ dfa87068-887f-4dba-95f7-b4c472de3e37
DataFrame(df5_1s, :log_lik)

# ╔═╡ 984d07a4-e74a-4a56-bae9-8d833aa8f78e
md"#### Do not append multiple chains."

# ╔═╡ 3e26a611-9a74-407a-9ebe-927e9c94d0d7
if success(rc5_1s)
    sts5_1s = read_samples(m5_1s, :tables)
end

# ╔═╡ 149be65d-c4cf-4a7a-a250-a91bd72c6417
md"#### Create a DataFrame for each chain ( Vector{DataFrame} )."

# ╔═╡ 516b91db-7ebf-4699-95c9-1863d5d2b5b6
dfs5_1s = DataFrame.(sts5_1s)

# ╔═╡ 307306b3-e28d-440f-8023-14cb1fd62185
md" #### Extract Stan block of variables for each chain."

# ╔═╡ 0bc25437-a231-47c6-b92e-e4a09c94c962
DataFrame.(dfs5_1s, :log_lik)

# ╔═╡ Cell order:
# ╠═63577d5e-8d41-4bc5-8d4c-c74be034d08c
# ╟─865295d7-451e-437b-bc4d-cbd939d3a080
# ╠═a2d386d3-782f-4042-bae9-9751c73d42b5
# ╠═88faad64-f887-44d6-99e5-d56e9d6df486
# ╠═da61fb27-229d-4885-ba23-580f088db42b
# ╠═d4cc546f-cb4d-401d-bf7e-5c87e1ac8fcd
# ╠═c6ccfa63-fd10-4d2a-b260-8fdba221f6d7
# ╠═5041bb2f-ba75-47cc-9a9a-40b6882fe161
# ╠═c63617a8-aea2-4e01-baca-e000fe1a8268
# ╠═6d3a8e78-0758-463c-aa18-948dee2decef
# ╟─4e8dfe63-f39b-4847-8e62-ad184ae222c6
# ╠═270a906b-575c-4bcf-adcd-1ddfca3b42a5
# ╟─be3252ef-32a6-411b-8c69-fc0a41b8ca96
# ╠═dfa87068-887f-4dba-95f7-b4c472de3e37
# ╟─984d07a4-e74a-4a56-bae9-8d833aa8f78e
# ╠═3e26a611-9a74-407a-9ebe-927e9c94d0d7
# ╟─149be65d-c4cf-4a7a-a250-a91bd72c6417
# ╠═516b91db-7ebf-4699-95c9-1863d5d2b5b6
# ╟─307306b3-e28d-440f-8023-14cb1fd62185
# ╠═0bc25437-a231-47c6-b92e-e4a09c94c962
