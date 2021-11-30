### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 79789782-8d97-11eb-112c-fd8c2c294527
using Pkg, DrWatson

# ╔═╡ dd81850e-8d97-11eb-0cff-8bf4f38f0660
begin
	#@quickactivate "SR2StanPluto"
	using StanSample
	using StatisticalRethinking
	using BrowseTables, Tables
end

# ╔═╡ 3cb90c0e-8db1-11eb-324a-0f66762c31f6
md" ## HTMLTable.jl"

# ╔═╡ 24856618-d93c-4467-b04b-b952117bfed6
begin
	# make example table, but any table that supports Tables.jl will work
	table = Tables.columntable(collect(i == 5 ?
			(a = missing, b = "string", c = nothing) :
			(a = i, b = Float64(i), c = 'a'-1+i) for i in 1:10))
end;

# ╔═╡ 2e1e3519-81ad-4124-9e2a-c3128465be46
HTMLTable(table) # show HTML table using Julia's display system

# ╔═╡ 0ad949c1-8b2e-439e-a5e4-3dcb168dcc1e
begin
    df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame)
    df[!, "treatment"] = 1 .+ df.prosoc_left + 2 * df.condition
end;

# ╔═╡ 1db203ac-fdcf-4ece-8e94-52bf1c32f86a
stan11_4 = "
data{
	int N;
	int K;
    int pulled_left[N];
    int treatment[N];
    int actor[N];
}
parameters{
    vector[7] a;
    vector[4] b;
}
model{
    vector[N] p;
    b ~ normal( 0 , 0.5 );
    a ~ normal( 0 , 1.5 );
    for ( i in 1:N ) {
        p[i] = a[actor[i]] + b[treatment[i]];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

# ╔═╡ 3864cff3-f9c1-42a0-96be-a04fc9d3f325
begin
	m11_4s = SampleModel("m11.4s", stan11_4)
	data = (N = size(df, 1), K = length(unique(df.treatment)),
		pulled_left = df.pulled_left, actor=df.actor,
		treatment = df.treatment)
	rc11_4s = stan_sample(m11_4s; data)
end;

# ╔═╡ d92eb94f-3003-4ea5-aeb1-ae6ee8978b6a
if success(rc11_4s)
	post11_4s_df = read_samples(m11_4s, :dataframe)
	PRECIS(post11_4s_df[:, 1:11])
end

# ╔═╡ 59879eb7-f3aa-4b90-a22e-653ccd9d5616
HTMLTable(post11_4s_df[1:10, 1:11])

# ╔═╡ f1dc6158-aa8d-41a1-b292-fb5ff917b5fa
function precis_df(df::DataFrame; digits = 4, depth = Inf, alpha = 0.11)
    d = DataFrame()
    d.param = names(df)
    d.mean = mean.(eachcol(df))
    d.std = std.(eachcol(df))
    d[:, "5.5%"] = quantile.(eachcol(df), alpha/2)
    d[:, "50%"] = quantile.(eachcol(df), 0.5)
    d[:, "94.5%"] = quantile.(eachcol(df), 1 - alpha/2)
    u = StatisticalRethinking.unicode_histogram.(eachcol(df), min(size(df, 1), 12))
	
	#=
    d.histogram = StatisticalRethinking.unicode_histogram.(eachcol(df),
		min(size(df, 1), 12))
	for n in names(df)
		if eltype(df[!,n]) <: Number
			df[!,n] = round.(df[!,n], digits=2)
		end
	end 
	=#

    for col in ["mean", "std", "5.5%", "50%", "94.5%"]
        d[:, col] .= round.(d[:, col], digits = digits)
    end

    d
end

# ╔═╡ ec6df58e-3baf-4db0-8c5f-4189988e2c4b
begin
	summary_df = precis_df(post11_4s_df[:, 1:11])
	HTMLTable(summary_df)
end

# ╔═╡ ae03e891-5f44-4526-98df-1de2d113173d
if success(rc11_4s)
	sdf = read_summary(m11_4s)
	HTMLTable(sdf[8:end,:]; caption="m11.4s")
end

# ╔═╡ 3005a46a-571c-453c-b55d-e9eab17c2b87
md"# StatisticalRethinking
| Chapter | Clip | Topic |
|:---|---|---|
|Running a Stan Language program|||
|Introduction to the Stan Language      | Intros| StanQuap usage |
||Loglik|PSIS|
"

# ╔═╡ Cell order:
# ╠═3cb90c0e-8db1-11eb-324a-0f66762c31f6
# ╠═79789782-8d97-11eb-112c-fd8c2c294527
# ╠═dd81850e-8d97-11eb-0cff-8bf4f38f0660
# ╠═24856618-d93c-4467-b04b-b952117bfed6
# ╠═2e1e3519-81ad-4124-9e2a-c3128465be46
# ╠═0ad949c1-8b2e-439e-a5e4-3dcb168dcc1e
# ╠═1db203ac-fdcf-4ece-8e94-52bf1c32f86a
# ╠═3864cff3-f9c1-42a0-96be-a04fc9d3f325
# ╠═d92eb94f-3003-4ea5-aeb1-ae6ee8978b6a
# ╠═59879eb7-f3aa-4b90-a22e-653ccd9d5616
# ╠═f1dc6158-aa8d-41a1-b292-fb5ff917b5fa
# ╠═ec6df58e-3baf-4db0-8c5f-4189988e2c4b
# ╠═ae03e891-5f44-4526-98df-1de2d113173d
# ╠═3005a46a-571c-453c-b55d-e9eab17c2b87
