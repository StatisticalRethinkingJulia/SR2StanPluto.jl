### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 79789782-8d97-11eb-112c-fd8c2c294527
using Pkg, DrWatson

# ╔═╡ dd81850e-8d97-11eb-0cff-8bf4f38f0660
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 3cb90c0e-8db1-11eb-324a-0f66762c31f6
md" ## Clip-11-15-24s.jl"

# ╔═╡ dd81af5c-8d97-11eb-10e4-73daebcd8875
begin
    df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame)
    df[!, "treatment"] = 1 .+ df.prosoc_left + 2 * df.condition
end;

# ╔═╡ dd82254a-8d97-11eb-3f3d-59b7642304f5
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
generated quantities{
    vector[N] log_lik;
    vector[N] p;
    for ( i in 1:N ) {
        p[i] = a[actor[i]] + b[treatment[i]];
        p[i] = inv_logit(p[i]);
    }
    for ( i in 1:N ) log_lik[i] = binomial_lpmf( pulled_left[i] | 1 , p[i] );
}
";

# ╔═╡ dd8c8ce4-8d97-11eb-1249-03382bfe3feb
begin
	m11_4s = SampleModel("m11.4s", stan11_4)
	data = (N = size(df, 1), K = length(unique(df.treatment)),
		pulled_left = df.pulled_left, actor=df.actor,
		treatment = df.treatment)
	rc11_4s = stan_sample(m11_4s; data)
end;

# ╔═╡ dd96b924-8d97-11eb-0d47-ffa72b39a875
if success(rc11_4s)
	post11_4s_df = read_samples(m11_4s, :dataframe)
	PRECIS(post11_4s_df[:, 1:11])
end

# ╔═╡ 83d6ef06-8e48-11eb-3cf2-f93f08c47e5d
md" ##### rethinking result:"

# ╔═╡ 75bc9c60-8e48-11eb-2eaa-5fac58b91570
md"
```
      mean   sd  5.5% 94.5% n_eff Rhat4
a[1] -0.43 0.33 -0.95  0.12   672  1.00
a[2]  3.93 0.76  2.83  5.22  1301  1.00
a[3] -0.73 0.34 -1.29 -0.18   845  1.00
a[4] -0.73 0.34 -1.31 -0.20   702  1.00
a[5] -0.43 0.33 -0.95  0.09   656  1.00
a[6]  0.50 0.34 -0.05  1.05   665  1.00
a[7]  1.98 0.43  1.29  2.65   683  1.01
b[1] -0.06 0.29 -0.50  0.41   602  1.00
b[2]  0.46 0.30 -0.01  0.95   669  1.00
b[3] -0.41 0.30 -0.89  0.08   586  1.01
b[4]  0.35 0.29 -0.10  0.82   651  1.00
```
"

# ╔═╡ 41ccd42e-8db0-11eb-1ed5-9f897b54a7cc
begin
	nt11_4s = read_samples(m11_4s, :namedtuple)
	p_left = [logistic.(nt11_4s.a[i]) for i in 1:7]
	mean.([p_left[i] for i in 1:7])
end

# ╔═╡ 5830c0b0-9001-11eb-1a21-b9b059a0e0a0
begin
	name = "m11.4s"
	a_pars = Symbol.(["a.$i" for i in 1:7])
	s_a, p_a = plot_logistic_coef(post11_4s_df, a_pars, name)
	p_a
end

# ╔═╡ eab67364-8fff-11eb-3dee-f55af5f7b21c
s_a[1]

# ╔═╡ d40b6242-0331-4d6b-9c40-e37f1d06e718
begin
	dfb4 = DataFrame()
	rowlabs = Symbol.(["R/N", "L/N", "R/P", "L/P"])
	for i in 1:length(rowlabs)
		dfb4[!, rowlabs[i]] = post11_4s_df[:, "b.$i"]
	end
	s_b4, p_b4 = plot_model_coef(dfb4, rowlabs)
	p_b4
end

# ╔═╡ 997c1663-9ec3-4bb9-ad2a-23b5539b8fb6
begin
	dfb = DataFrame()
	diff_b_pars = [:db13, :db24]
	dfb[!, :db13] = post11_4s_df[:, "b.1"] - post11_4s_df[:, "b.3"]
	dfb[!, :db24] = post11_4s_df[:, "b.2"] - post11_4s_df[:, "b.4"]
	s_b_diff1, p_b_diff1 = plot_model_coef(dfb, diff_b_pars;
		mname = "m11.4s")
	p_b_diff1
end

# ╔═╡ 2456f812-8db1-11eb-2e37-8f274b4509cc
md" ## End of clip-11-15-24s.jl"

# ╔═╡ Cell order:
# ╠═3cb90c0e-8db1-11eb-324a-0f66762c31f6
# ╠═79789782-8d97-11eb-112c-fd8c2c294527
# ╠═dd81850e-8d97-11eb-0cff-8bf4f38f0660
# ╠═dd81af5c-8d97-11eb-10e4-73daebcd8875
# ╠═dd82254a-8d97-11eb-3f3d-59b7642304f5
# ╠═dd8c8ce4-8d97-11eb-1249-03382bfe3feb
# ╠═dd96b924-8d97-11eb-0d47-ffa72b39a875
# ╟─83d6ef06-8e48-11eb-3cf2-f93f08c47e5d
# ╟─75bc9c60-8e48-11eb-2eaa-5fac58b91570
# ╠═41ccd42e-8db0-11eb-1ed5-9f897b54a7cc
# ╠═5830c0b0-9001-11eb-1a21-b9b059a0e0a0
# ╠═eab67364-8fff-11eb-3dee-f55af5f7b21c
# ╠═d40b6242-0331-4d6b-9c40-e37f1d06e718
# ╠═997c1663-9ec3-4bb9-ad2a-23b5539b8fb6
# ╟─2456f812-8db1-11eb-2e37-8f274b4509cc
