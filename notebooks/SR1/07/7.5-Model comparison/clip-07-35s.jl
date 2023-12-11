### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 837951f4-68ec-11eb-048d-6b27b9055428
using Pkg

# ╔═╡ 91489170-68ec-11eb-3611-150d5febf223
begin
	using Distributions
	using StatsPlots
	using StatsBase
	using LaTeXStrings
	using CSV
	using DataFrames
	using LinearAlgebra
	using Random
	using ParetoSmoothedImportanceSampling
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using RegressionAndOtherStories

end

# ╔═╡ 7046ea12-68ec-11eb-18ae-a724ca79a21f
md" ## Clip-07-35s.jl"

# ╔═╡ ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale_df_cols!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ 4c47f312-68ed-11eb-37de-ff782118d258
stan5_1_t = "
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
	vector[N] mu;
	mu = a + + bA * A;
}

model {
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ student_t( 2, mu , sigma );
}
generated quantities{
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = student_t_lpdf(D[i] | 2, mu[i], sigma);
}
";

# ╔═╡ 4c482dfa-68ed-11eb-2db9-a54ab816beb7
begin
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
	m5_1s_t = SampleModel("m5.1s_t", stan5_1_t)
	rc5_1s_t = stan_sample(m5_1s_t; data)

	if success(rc5_1s_t)
		post5_1s_t_df = read_samples(m5_1s_t, :dataframe)
		describe(post5_1s_t_df[:, [:a, :bA, :sigma]])
	end
end

# ╔═╡ 806d4352-69b7-11eb-00a5-791917fa9d45
if success(rc5_1s_t)
	nt5_1s_t = read_samples(m5_1s_t, :namedtuple)
	log_lik_1_t = nt5_1s_t.log_lik'
	waic_m5_1s_t = waic(log_lik_1_t)
end

# ╔═╡ 6210f1ba-68ef-11eb-1d55-653d1c8a147c
begin
    b5_1s_t = post5_1s_t_df[:, [:a, :bA, :sigma]]
    mu5_1s_t = b5_1s_t.a .+ b5_1s_t.bA * df.MedianAgeMarriage_s'
	lp5_1s_t = logpdf.(TDist(2), mu5_1s_t)
	waic(lp5_1s_t)
end

# ╔═╡ 3a9ff05e-6a16-11eb-2ba0-530fb4bc18f4
size(mu5_1s_t)

# ╔═╡ 8f107504-68ed-11eb-002b-372884f598b0
stan5_2_t = "
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
	mu = a + bM * M;
}
model {
  a ~ normal( 0 , 0.2 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ student_t( 2, mu , sigma );
}
generated quantities{
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = student_t_lpdf(D[i] | 2, mu[i], sigma);
}
";

# ╔═╡ cbb9ef56-68ed-11eb-387b-252ff6dc5b21
begin
	m5_2s_t = SampleModel("m5.2_t", stan5_2_t);
	rc5_2s_t = stan_sample(m5_2s_t; data)
	if success(rc5_2s_t)
		post5_2s_t_df = read_samples(m5_2s_t, :dataframe)
		describe(post5_2s_t_df[:, [:a, :bM, :sigma]])
	end
end

# ╔═╡ 5d216004-69b7-11eb-34d4-8be76d4ae47c
if success(rc5_2s_t)
	nt5_2s_t = read_samples(m5_2s_t, :namedtuple)
	log_lik_2_t = nt5_2s_t.log_lik'
	waic_m5_2s_t = waic(log_lik_2_t)
end

# ╔═╡ 87cd0b48-68f2-11eb-3704-af5e98a9c463
begin
    b5_2s_t = post5_2s_t_df[:, [:a, :bM, :sigma]]
    mu5_2s_t = b5_2s_t.a .+ b5_2s_t.bM * df.Marriage_s'
	lp5_2s_t = logpdf.(TDist.(2), mu5_2s_t)
	waic(lp5_2s_t)
end

# ╔═╡ 71a48f7a-68ee-11eb-1b0e-331393e95551
stan5_3_t = "
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
  D ~ student_t( 2, mu , sigma );
}
generated quantities{
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = student_t_lpdf(D[i] | 2, mu[i], sigma);
}
";

# ╔═╡ b5b487ec-68ee-11eb-3ee7-0d98367028ff
begin
	m5_3s_t = SampleModel("m5.3_t", stan5_3_t);
	rc5_3s_t = stan_sample(m5_3s_t; data);

	if success(rc5_3s_t)
		post5_3s_t_df = read_samples(m5_3s_t, :dataframe)
		describe(post5_3s_t_df[:, [:a, :bA, :bM, :sigma]])
	end
end

# ╔═╡ 4e7a00e8-69b4-11eb-15ef-df1a53282396
if success(rc5_3s_t)
	nt5_3s_t = read_samples(m5_3s_t, :namedtuple)
	log_lik_3_t = nt5_3s_t.log_lik'
	waic_m5_3s_t = waic(log_lik_3_t)
end

# ╔═╡ 51d570db-4ff0-49b4-b4c1-8e709a6b1564
nt5_3s_t

# ╔═╡ c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
begin
    b5_3s_t = post5_3s_t_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s_t = b5_3s_t.a .+ b5_3s_t.bM * df.Marriage_s' +
		b5_3s_t.bA * df.MedianAgeMarriage_s'
	lp5_3s_t = logpdf.(TDist.(2), mu5_3s_t)
	waic(lp5_3s_t)
end

# ╔═╡ 7b051a2e-68f3-11eb-3ee8-e77c639fc390
[waic_m5_1s_t.WAIC, waic_m5_2s_t.WAIC, waic_m5_3s_t.WAIC]

# ╔═╡ ed4469dc-68f3-11eb-3b0f-f54305283306
begin
	loo5_1s_t, loos5_1s_t, pk5_1s_t = psisloo(log_lik_1_t)
	loo5_2s_t, loos5_2s_t, pk5_2s_t = psisloo(log_lik_2_t)
	loo5_3s_t, loos5_3s_t, pk5_3s_t = psisloo(log_lik_3_t)
	[-2loo5_1s_t, -2loo5_2s_t, -2loo5_3s_t]
end


# ╔═╡ 2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
begin
	pk_plot(pk5_1s_t)
	annotate!([(13 + 1, pk5_1s_t[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ 3766d148-695b-11eb-19dc-0b25e6704b3d
begin
	waic_5_1s_pw_t = waic(lp5_1s_t; pointwise=true)
	scatter(pk5_1s_t, waic_5_1s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_1s_t[state] + 0.02], [waic_5_1s_pw_t.penalty[state]],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ aedb425c-68f4-11eb-319d-a958c2aacde1
begin
	pk_plot(pk5_3s_t)
	annotate!([(13 + 1, pk5_3s_t[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

# ╔═╡ 75ce4e64-6958-11eb-333e-dbee637ecdf2
begin
	waic_5_3s_pw_t = waic(lp5_3s_t; pointwise=true)
	scatter(pk5_3s_t, waic_5_3s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_3s_t[state] + 0.02], [waic_5_3s_pw_t.penalty[state]],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ 8ec864f0-697d-11eb-029b-93e11b2e247b
waic_5_3s_pw_t

# ╔═╡ eb6b3ee8-697d-11eb-3380-a99e3c132720
pk5_3s_t

# ╔═╡ 5eae5f80-68f4-11eb-2d8e-5db775fbc1c9
pk_plot(pk5_2s_t)

# ╔═╡ 56735994-695b-11eb-28dd-21ff7dfa325d
begin
	waic_5_2s_pw_t = waic(lp5_2s_t; pointwise=true)
	scatter(pk5_2s_t, waic_5_2s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_2s_t[state] + 0.01], [waic_5_2s_pw_t.penalty[state] + 0.01],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ c3169ed8-694e-11eb-0616-97d25d8b56e1
md" ## End of clip-07-35s.jl"

# ╔═╡ Cell order:
# ╟─7046ea12-68ec-11eb-18ae-a724ca79a21f
# ╠═837951f4-68ec-11eb-048d-6b27b9055428
# ╠═91489170-68ec-11eb-3611-150d5febf223
# ╠═ace5ed4c-68ec-11eb-05ed-1f1ff2d72e1b
# ╠═4c47f312-68ed-11eb-37de-ff782118d258
# ╠═4c482dfa-68ed-11eb-2db9-a54ab816beb7
# ╠═806d4352-69b7-11eb-00a5-791917fa9d45
# ╠═6210f1ba-68ef-11eb-1d55-653d1c8a147c
# ╠═3a9ff05e-6a16-11eb-2ba0-530fb4bc18f4
# ╠═8f107504-68ed-11eb-002b-372884f598b0
# ╠═cbb9ef56-68ed-11eb-387b-252ff6dc5b21
# ╠═5d216004-69b7-11eb-34d4-8be76d4ae47c
# ╠═87cd0b48-68f2-11eb-3704-af5e98a9c463
# ╠═71a48f7a-68ee-11eb-1b0e-331393e95551
# ╠═b5b487ec-68ee-11eb-3ee7-0d98367028ff
# ╠═4e7a00e8-69b4-11eb-15ef-df1a53282396
# ╠═51d570db-4ff0-49b4-b4c1-8e709a6b1564
# ╠═c2ba84b0-68f2-11eb-3c5a-17e03541dcb1
# ╠═7b051a2e-68f3-11eb-3ee8-e77c639fc390
# ╠═ed4469dc-68f3-11eb-3b0f-f54305283306
# ╠═2c4b5ffc-68f4-11eb-21d6-7d2db834d3f8
# ╠═3766d148-695b-11eb-19dc-0b25e6704b3d
# ╠═aedb425c-68f4-11eb-319d-a958c2aacde1
# ╠═75ce4e64-6958-11eb-333e-dbee637ecdf2
# ╠═8ec864f0-697d-11eb-029b-93e11b2e247b
# ╠═eb6b3ee8-697d-11eb-3380-a99e3c132720
# ╠═5eae5f80-68f4-11eb-2d8e-5db775fbc1c9
# ╠═56735994-695b-11eb-28dd-21ff7dfa325d
# ╟─c3169ed8-694e-11eb-0616-97d25d8b56e1
