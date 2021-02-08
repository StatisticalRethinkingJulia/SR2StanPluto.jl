
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md" ## Clip-07-35s.jl"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

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

begin
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
	m5_1s_t = SampleModel("m5.1s_t", stan5_1_t)
	rc5_1s_t = stan_sample(m5_1s_t; data)

	if success(rc5_1s_t)
		post5_1s_t_df = read_samples(m5_1s_t; output_format=:dataframe)
		PRECIS(post5_1s_t_df[:, [:a, :bA, :sigma]])
	end
end

if success(rc5_1s_t)
	nt5_1s_t = read_samples(m5_1s_t)
	log_lik_1_t = nt5_1s_t.log_lik'
	waic_m5_1s_t = waic(log_lik_1_t)
end

begin
    b5_1s_t = post5_1s_t_df[:, [:a, :bA, :sigma]]
    mu5_1s_t = b5_1s_t.a .+ b5_1s_t.bA * df.MedianAgeMarriage_s'
	lp5_1s_t = logpdf.(TDist(2), mu5_1s_t)
	waic(lp5_1s_t)
end

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

begin
	m5_2s_t = SampleModel("m5.2_t", stan5_2_t);
	rc5_2s_t = stan_sample(m5_2s_t; data)
	if success(rc5_2s_t)
		post5_2s_t_df = read_samples(m5_2s_t; output_format=:dataframe)
		PRECIS(post5_2s_t_df[:, [:a, :bM, :sigma]])
	end
end

if success(rc5_2s_t)
	nt5_2s_t = read_samples(m5_2s_t)
	log_lik_2_t = nt5_2s_t.log_lik'
	waic_m5_2s_t = waic(log_lik_2_t)
end

begin
    b5_2s_t = post5_2s_t_df[:, [:a, :bM, :sigma]]
    mu5_2s_t = b5_2s_t.a .+ b5_2s_t.bM * df.Marriage_s'
	lp5_2s_t = logpdf.(TDist.(2), mu5_2s_t)
	waic(lp5_2s_t)
end

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

begin
	m5_3s_t = SampleModel("m5.3_t", stan5_3_t);
	rc5_3s_t = stan_sample(m5_3s_t; data);

	if success(rc5_3s_t)
		post5_3s_t_df = read_samples(m5_3s_t; output_format=:dataframe)
		PRECIS(post5_3s_t_df[:, [:a, :bA, :bM, :sigma]])
	end
end

if success(rc5_3s_t)
	nt5_3s_t = read_samples(m5_3s_t)
	log_lik_3_t = nt5_3s_t.log_lik'
	waic_m5_3s_t = waic(log_lik_3_t)
end

begin
    b5_3s_t = post5_3s_t_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s_t = b5_3s_t.a .+ b5_3s_t.bM * df.Marriage_s' +
		b5_3s_t.bA * df.MedianAgeMarriage_s'
	lp5_3s_t = logpdf.(TDist.(2), mu5_3s_t)
	waic(lp5_3s_t)
end

[waic_m5_1s_t.WAIC, waic_m5_2s_t.WAIC, waic_m5_3s_t.WAIC]

begin
	loo5_1s_t, loos5_1s_t, pk5_1s_t = psisloo(log_lik_1_t)
	loo5_2s_t, loos5_2s_t, pk5_2s_t = psisloo(log_lik_2_t)
	loo5_3s_t, loos5_3s_t, pk5_3s_t = psisloo(log_lik_3_t)
	[-2loo5_1s_t, -2loo5_2s_t, -2loo5_3s_t]
end


begin
	pk_plot(pk5_1s_t)
	annotate!([(13 + 1, pk5_1s_t[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

begin
	waic_5_1s_pw_t = waic(lp5_1s_t; pointwise=true)
	scatter(pk5_1s_t, waic_5_1s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_1s_t[state] + 0.12], [waic_5_1s_pw_t.penalty[state] + 0.3],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

begin
	pk_plot(pk5_3s_t)
	annotate!([(13 + 1, pk5_3s_t[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

begin
	waic_5_3s_pw_t = waic(lp5_3s_t; pointwise=true)
	scatter(pk5_3s_t, waic_5_3s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_3s_t[state] + 0.15], [waic_5_3s_pw_t.penalty[state] + 0.02],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

waic_5_3s_pw_t

pk5_3s_t

pk_plot(pk5_2s_t)

begin
	waic_5_2s_pw_t = waic(lp5_2s_t; pointwise=true)
	scatter(pk5_2s_t, waic_5_2s_pw_t.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	for state in [13, 20, 34, 44, 50]
		annotate!([([pk5_2s_t[state] + 0.1], [waic_5_2s_pw_t.penalty[state] + 0.02],
			Plots.text(df[state, :Loc], 6, :red, :right))])
	end
	plot!()
end

md" ## End of clip-07-35s.jl"

