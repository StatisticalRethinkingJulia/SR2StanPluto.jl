### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 837951f4-68ec-11eb-048d-6b27b9055428
using Pkg, DrWatson

# ╔═╡ 91489170-68ec-11eb-3611-150d5febf223
begin
	using ParetoSmoothedImportanceSampling
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ 7046ea12-68ec-11eb-18ae-a724ca79a21f
md" ## Clip-07-32-34s.jl"

# ╔═╡ d603e8be-8381-11eb-1c62-8d87639fc38b
versioninfo()

# ╔═╡ ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
end;

# ╔═╡ 4c47f312-68ed-11eb-37de-ff782118d258
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

# ╔═╡ 4c482dfa-68ed-11eb-2db9-a54ab816beb7
begin
	m5_1s = SampleModel("m5.1s", stan5_1)
	rc5_1s = stan_sample(m5_1s; data)
	if success(rc5_1s)
		post5_1s_df = read_samples(m5_1s, :dataframe)
		PRECIS(post5_1s_df[:, [:a, :bA, :sigma]])
	end
end

# ╔═╡ 8f107504-68ed-11eb-002b-372884f598b0
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

# ╔═╡ cbb9ef56-68ed-11eb-387b-252ff6dc5b21
begin
	m5_2s = SampleModel("m5.2s", stan5_2);
	rc5_2s = stan_sample(m5_2s; data)
	if success(rc5_2s)
		post5_2s_df = read_samples(m5_2s, :dataframe)
		PRECIS(post5_2s_df[:, [:a, :bM, :sigma]])
	end
end

# ╔═╡ 71a48f7a-68ee-11eb-1b0e-331393e95551
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
	mu = a + + bA * A + bM * M;
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

# ╔═╡ b5b487ec-68ee-11eb-3ee7-0d98367028ff
begin
	init = (a = 0.0, bA = -1.0, bM = 0.0, sigma = 1.0)
	q5_3s, m5_3s, o5_3s = stan_quap("m5.3s", stan5_3; data, init)

	if !isnothing(m5_3s)
		post5_3s_df = read_samples(m5_3s, :dataframe)
		PRECIS(post5_3s_df[:, [:a, :bA, :bM, :sigma]])
	end
end

# ╔═╡ 7310fa28-7132-11eb-32dc-e9aae12b4f9e
md" ### Compare the model cofficients."

# ╔═╡ 84d0ef98-7132-11eb-1d64-3d911674a004
begin
	plot_models([m5_1s, m5_2s, m5_3s], [:a, :bA, :bM, :sigma])
end

# ╔═╡ 8501f844-69b3-11eb-24f8-d3b87b745be7
if !isnothing(m5_3s)
	waic(m5_3s)
end

# ╔═╡ c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
begin
    b5_3s = post5_3s_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s = b5_3s.a .+ b5_3s.bM * df.Marriage_s' +
		b5_3s.bA * df.MedianAgeMarriage_s'
	log_lik5_3s = logpdf.(Normal.(mu5_3s, post5_3s_df.sigma),  df.Divorce_s')
	waic(log_lik5_3s)
end

# ╔═╡ 9ee34a3a-6d4e-11eb-1e6e-b191bea5527b
    df_waic = compare([m5_1s, m5_2s, m5_3s], :waic)

# ╔═╡ b05f0250-7009-11eb-0370-4969eb2fd5ce
plot_models([m5_1s, m5_2s, m5_3s], :waic)

# ╔═╡ 85a11cf4-6d40-11eb-3424-5b873aa5bc88
md"With quap():
```
      PSIS    SE   dPSIS   dSE   pPSIS   weight
 m5.1 127.6 14.69   0.0    NA     4.7    0.71
 m5.3 129.4 15.10   1.8   0.90    5.9    0.29
 m5.2 140.6 11.21  13.1  10.82    3.8    0.00
```

or, with ulam():
```
       PSIS    SE dPSIS  dSE pPSIS weight
m5.1u 126.0 12.83   0.0   NA   3.7   0.67
m5.3u 127.4 12.75   1.4 0.75   4.7   0.33
m5.2u 139.5  9.95  13.6 9.33   3.0   0.00
```
"

# ╔═╡ c6955180-6d40-11eb-0723-e55c69316f63
df_psis = compare([m5_1s, m5_2s, m5_3s], :psis)

# ╔═╡ 2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
begin
	loo5_1s, loos5_1s, pk5_1s = psisloo(m5_1s)
	pk_plot(pk5_1s)
	annotate!([(13 + 1, pk5_1s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ 3e956c3c-6ee6-11eb-2aff-d73d8c0d9dcd
waic(m5_1s)

# ╔═╡ 468ae700-6ee6-11eb-289d-8dabcdca1b7d
exp(std(loos5_1s))

# ╔═╡ aedb425c-68f4-11eb-319d-a958c2aacde1
begin
	loo5_3s, loos5_3s, pk5_3s = psisloo(m5_3s)
	pk_plot(pk5_3s)
	annotate!([(13 + 1, pk5_3s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ f3afc7c2-6d68-11eb-10a6-65ab80be96a6
waic_5_3s_pw = waic(m5_3s; pointwise=true)

# ╔═╡ bb70ce3a-6956-11eb-26ad-e19934980e11
waic_5_3s_pw.penalty[13]

# ╔═╡ eb7c7c14-6956-11eb-3c98-3b4ee223bccc
begin
	scatter(pk5_3s, waic_5_3s_pw.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	annotate!([([pk5_3s[13]], [waic_5_3s_pw.penalty[13] + 0.02],
		Plots.text(df[13, :Loc], 6, :red, :right))])
	annotate!([([pk5_3s[20]], [waic_5_3s_pw.penalty[20] + 0.02],
		Plots.text(df[20, :Loc], 6, :red, :right))])

end

# ╔═╡ c3169ed8-694e-11eb-0616-97d25d8b56e1
md" ## End of clip-07-32-34s.jl"

# ╔═╡ Cell order:
# ╟─7046ea12-68ec-11eb-18ae-a724ca79a21f
# ╠═837951f4-68ec-11eb-048d-6b27b9055428
# ╠═91489170-68ec-11eb-3611-150d5febf223
# ╠═d603e8be-8381-11eb-1c62-8d87639fc38b
# ╠═ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
# ╠═4c47f312-68ed-11eb-37de-ff782118d258
# ╠═4c482dfa-68ed-11eb-2db9-a54ab816beb7
# ╠═8f107504-68ed-11eb-002b-372884f598b0
# ╠═cbb9ef56-68ed-11eb-387b-252ff6dc5b21
# ╠═71a48f7a-68ee-11eb-1b0e-331393e95551
# ╠═b5b487ec-68ee-11eb-3ee7-0d98367028ff
# ╟─7310fa28-7132-11eb-32dc-e9aae12b4f9e
# ╠═84d0ef98-7132-11eb-1d64-3d911674a004
# ╠═8501f844-69b3-11eb-24f8-d3b87b745be7
# ╠═c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
# ╠═9ee34a3a-6d4e-11eb-1e6e-b191bea5527b
# ╠═b05f0250-7009-11eb-0370-4969eb2fd5ce
# ╟─85a11cf4-6d40-11eb-3424-5b873aa5bc88
# ╠═c6955180-6d40-11eb-0723-e55c69316f63
# ╠═2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
# ╠═3e956c3c-6ee6-11eb-2aff-d73d8c0d9dcd
# ╠═468ae700-6ee6-11eb-289d-8dabcdca1b7d
# ╠═aedb425c-68f4-11eb-319d-a958c2aacde1
# ╠═f3afc7c2-6d68-11eb-10a6-65ab80be96a6
# ╠═bb70ce3a-6956-11eb-26ad-e19934980e11
# ╠═eb7c7c14-6956-11eb-3c98-3b4ee223bccc
# ╟─c3169ed8-694e-11eb-0616-97d25d8b56e1
