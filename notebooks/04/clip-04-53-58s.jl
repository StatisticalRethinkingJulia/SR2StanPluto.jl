### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 50cd0aec-fbbc-11ea-1e67-4b1144cfb859
using Pkg, DrWatson

# ╔═╡ 50cd42e6-fbbc-11ea-08af-4b4a08ff30ab
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 552d65ea-fbbb-11ea-3fec-f978e814a5b1
md"## Clip-04-53-58s.jl"

# ╔═╡ 50cdc32e-fbbc-11ea-1a2e-2f7a2b0b897a
md"### Preliminary snippets."

# ╔═╡ 50d52c22-fbbc-11ea-3f1f-776b0366db1c
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame, delim=';')
	df = filter(row -> row[:age] >= 18, df);
	scale!(df, [:height, :weight])
end;

# ╔═╡ 50e60cc2-fbbc-11ea-31f3-a1b4a684f54c
md"##### Define the Stan language model."

# ╔═╡ 50e864fe-fbbc-11ea-01e9-f7b1351ca6f9
stan4_8 = "
data{
    int N;
    real xbar;
    vector[N] height;
    vector[N] weight;
}
parameters{
    real alpha;
    real beta;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta ~ normal( 0 , 1 );
    alpha ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = alpha + beta * (weight[i] - xbar);
    }
    height ~ normal( mu , sigma );
}
";

# ╔═╡ 50f76cf6-fbbc-11ea-29f9-1b5f9df1f2d5
md"##### Define the SampleModel."

# ╔═╡ 50f8139a-fbbc-11ea-1bc0-8342bf3499f8
begin
	m4_8s = SampleModel("weights", stan4_8);
	m4_8_data = Dict("N" => size(df, 1), "height" => df.height, "weight" => df.weight,
		"xbar" => mean(df.weight));
	rc4_8s = stan_sample(m4_8s, data=m4_8_data);
end;

# ╔═╡ 5101d5ec-fbbc-11ea-090b-3d24839b633b
rethinking = "
        mean   sd   5.5%  94.5%
a     154.60 0.27 154.17 155.03
b       0.90 0.04   0.84   0.97
sigma   5.07 0.19   4.77   5.38
";

# ╔═╡ 510618a0-fbbc-11ea-0644-65a7a15b78fd
if success(rc4_8s)
	sdf4_8s = read_summary(m4_8s)
end

# ╔═╡ 5116f0b2-fbbc-11ea-1231-1bf3ad357e4e
md"### Snippet 4.53 - 4.56"

# ╔═╡ 5117af0c-fbbc-11ea-0f09-5dc77745a9a4
begin
	post4_8s_df = read_samples(m4_8s; output_format=:dataframe)
	mu_range = 30:1:60
	xbar = mean(df[:, :weight])
	mu = link(post4_8s_df, [:alpha, :beta], mu_range, xbar);

	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	figs[1] = plot(xlab="weight", ylab="height")
	for (indx, mu_val) in enumerate(mu_range)
		for j in 1:length(mu_range)
			scatter!(figs[1], [mu_val], [mu[indx][j]], markersize=3, leg=false, color=:lightblue)
		end
	end

	mu_range = 30:0.1:60
	xbar = mean(df[:, :weight])
	mu = link(post4_8s_df, [:alpha, :beta], mu_range, xbar);
	figs[2] = plot(xlab="weight", ylab="height", legend=:topleft)
	scatter!(figs[2], df[:, :weight], df[:, :height], markersize=2, lab="Observations")
	for (ind, m) in enumerate(mu_range)
		plot!(figs[2], [m, m], quantile(mu[ind], [0.055, 0.945]), color=:grey, leg=false)
	end
	plot!(figs[2], mu_range, [mean(mu[i]) for i in 1:length(mu_range)], color=:red, lab="Means of mu")
end

# ╔═╡ 51235af0-fbbc-11ea-2d1d-5f4d9e8e3203
plot(figs..., layout=(2,1))

# ╔═╡ 5126df6a-fbbc-11ea-0f8a-1f0a96e921dd
md"## End of clip-04-53-58s.jl"

# ╔═╡ Cell order:
# ╟─552d65ea-fbbb-11ea-3fec-f978e814a5b1
# ╠═50cd0aec-fbbc-11ea-1e67-4b1144cfb859
# ╠═50cd42e6-fbbc-11ea-08af-4b4a08ff30ab
# ╟─50cdc32e-fbbc-11ea-1a2e-2f7a2b0b897a
# ╠═50d52c22-fbbc-11ea-3f1f-776b0366db1c
# ╟─50e60cc2-fbbc-11ea-31f3-a1b4a684f54c
# ╠═50e864fe-fbbc-11ea-01e9-f7b1351ca6f9
# ╟─50f76cf6-fbbc-11ea-29f9-1b5f9df1f2d5
# ╠═50f8139a-fbbc-11ea-1bc0-8342bf3499f8
# ╠═5101d5ec-fbbc-11ea-090b-3d24839b633b
# ╠═510618a0-fbbc-11ea-0644-65a7a15b78fd
# ╟─5116f0b2-fbbc-11ea-1231-1bf3ad357e4e
# ╠═5117af0c-fbbc-11ea-0f09-5dc77745a9a4
# ╠═51235af0-fbbc-11ea-2d1d-5f4d9e8e3203
# ╟─5126df6a-fbbc-11ea-0f8a-1f0a96e921dd
