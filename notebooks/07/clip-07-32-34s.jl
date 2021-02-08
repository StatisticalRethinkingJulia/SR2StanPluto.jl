### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 837951f4-68ec-11eb-048d-6b27b9055428
using Pkg, DrWatson

# ╔═╡ 91489170-68ec-11eb-3611-150d5febf223
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 7046ea12-68ec-11eb-18ae-a724ca79a21f
md" ## Clip-07-32-34s.jl"

# ╔═╡ ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
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

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         //Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A;
  D ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 4c482dfa-68ed-11eb-2db9-a54ab816beb7
begin
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
	m5_1s = SampleModel("m5.1s", stan5_1)
	rc5_1s = stan_sample(m5_1s; data)

	if success(rc5_1s)
		post5_1s_df = read_samples(m5_1s; output_format=:dataframe)
		PRECIS(post5_1s_df)
	end
end

# ╔═╡ 6210f1ba-68ef-11eb-1d55-653d1c8a147c
begin
    b5_1s = post5_1s_df[:, [:a, :bA, :sigma]]
    mu5_1s = b5_1s.a .+ b5_1s.bA * df.MedianAgeMarriage_s'
	lp5_1s = logpdf.(Normal.(mu5_1s, post5_1s_df.sigma),  df.Divorce_s')
	waic_m5_1s = waic(lp5_1s)
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
model {
  vector[N] mu = a + bM * M;
  a ~ normal( 0 , 0.2 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ normal( mu , sigma );
}
";

# ╔═╡ cbb9ef56-68ed-11eb-387b-252ff6dc5b21
begin
	m5_2s = SampleModel("m5.2", stan5_2);
	rc5_2s = stan_sample(m5_2s; data)
	if success(rc5_2s)
		post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
		PRECIS(post5_2s_df)
	end
end

# ╔═╡ 87cd0b48-68f2-11eb-3704-af5e98a9c463
begin
    b5_2s = post5_2s_df[:, [:a, :bM, :sigma]]
    mu5_2s = b5_2s.a .+ b5_2s.bM * df.Marriage_s'
	lp5_2s = logpdf.(Normal.(mu5_2s, post5_2s_df.sigma),  df.Divorce_s')
	waic_m5_2s = waic(lp5_2s)
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
	m5_3s = SampleModel("m5.3", stan5_3);
	rc5_3s = stan_sample(m5_3s; data);

	if success(rc5_3s)
		post5_3s_df = read_samples(m5_3s; output_format=:dataframe)
		PRECIS(post5_3s_df[:, [:a, :bA, :bM, :sigma]])
	end
end

# ╔═╡ 8501f844-69b3-11eb-24f8-d3b87b745be7
if success(rc5_3s)
	nt5_3s = read_samples(m5_3s)
	log_lik = nt5_3s.log_lik'
	waic(log_lik)
end

# ╔═╡ c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
begin
    b5_3s = post5_3s_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s = b5_3s.a .+ b5_3s.bM * df.Marriage_s' +
		b5_3s.bA * df.MedianAgeMarriage_s'
	lp5_3s = logpdf.(Normal.(mu5_3s, post5_3s_df.sigma),  df.Divorce_s')
	waic_m5_3s = waic(lp5_3s)
end

# ╔═╡ 7b051a2e-68f3-11eb-3ee8-e77c639fc390
[waic_m5_1s.WAIC, waic_m5_3s.WAIC, waic_m5_2s.WAIC]

# ╔═╡ ed4469dc-68f3-11eb-3b0f-f54305283306
begin
	loo5_1s, loos5_1s, pk5_1s = psisloo(lp5_1s)
	loo5_2s, loos5_2s, pk5_2s = psisloo(lp5_2s)
	loo5_3s, loos5_3s, pk5_3s = psisloo(lp5_3s)
	[-2loo5_1s, -2loo5_3s, -2loo5_2s]
end

# ╔═╡ 2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
begin
	pk_plot(pk5_1s)
	annotate!([(13 + 1, pk5_1s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ aedb425c-68f4-11eb-319d-a958c2aacde1
begin
	pk_plot(pk5_3s)
	annotate!([(13 + 1, pk5_3s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ 5eae5f80-68f4-11eb-2d8e-5db775fbc1c9
pk_plot(pk5_2s)

# ╔═╡ 757b39ba-6956-11eb-28b1-e53bb19d25aa
waic_5_3s_pw = waic(lp5_2s; pointwise=true)

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
# ╠═ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
# ╠═4c47f312-68ed-11eb-37de-ff782118d258
# ╠═4c482dfa-68ed-11eb-2db9-a54ab816beb7
# ╠═6210f1ba-68ef-11eb-1d55-653d1c8a147c
# ╠═8f107504-68ed-11eb-002b-372884f598b0
# ╠═cbb9ef56-68ed-11eb-387b-252ff6dc5b21
# ╠═87cd0b48-68f2-11eb-3704-af5e98a9c463
# ╠═71a48f7a-68ee-11eb-1b0e-331393e95551
# ╠═b5b487ec-68ee-11eb-3ee7-0d98367028ff
# ╠═8501f844-69b3-11eb-24f8-d3b87b745be7
# ╠═c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
# ╠═7b051a2e-68f3-11eb-3ee8-e77c639fc390
# ╠═ed4469dc-68f3-11eb-3b0f-f54305283306
# ╠═2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
# ╠═aedb425c-68f4-11eb-319d-a958c2aacde1
# ╠═5eae5f80-68f4-11eb-2d8e-5db775fbc1c9
# ╠═757b39ba-6956-11eb-28b1-e53bb19d25aa
# ╠═bb70ce3a-6956-11eb-26ad-e19934980e11
# ╠═eb7c7c14-6956-11eb-3c98-3b4ee223bccc
# ╟─c3169ed8-694e-11eb-0616-97d25d8b56e1
