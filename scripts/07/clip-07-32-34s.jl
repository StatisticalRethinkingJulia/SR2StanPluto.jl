
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md" ## Clip-07-32-34s.jl"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

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

begin
    b5_1s = post5_1s_df[:, [:a, :bA, :sigma]]
    mu5_1s = b5_1s.a .+ b5_1s.bA * df.MedianAgeMarriage_s'
	lp5_1s = logpdf.(Normal.(mu5_1s, post5_1s_df.sigma),  df.Divorce_s')
	waic_m5_1s = waic(lp5_1s)
end

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

begin
	m5_2s = SampleModel("m5.2", stan5_2);
	rc5_2s = stan_sample(m5_2s; data)
	if success(rc5_2s)
		post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
		PRECIS(post5_2s_df)
	end
end

begin
    b5_2s = post5_2s_df[:, [:a, :bM, :sigma]]
    mu5_2s = b5_2s.a .+ b5_2s.bM * df.Marriage_s'
	lp5_2s = logpdf.(Normal.(mu5_2s, post5_2s_df.sigma),  df.Divorce_s')
	waic_m5_2s = waic(lp5_2s)
end

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

begin
	m5_3s = SampleModel("m5.3", stan5_3);
	rc5_3s = stan_sample(m5_3s; data);

	if success(rc5_3s)
		post5_3s_df = read_samples(m5_3s; output_format=:dataframe)
		PRECIS(post5_3s_df[:, [:a, :bA, :bM, :sigma]])
	end
end

if success(rc5_3s)
	nt5_3s = read_samples(m5_3s)
	log_lik = nt5_3s.log_lik'
	waic(log_lik)
end

begin
    b5_3s = post5_3s_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s = b5_3s.a .+ b5_3s.bM * df.Marriage_s' +
		b5_3s.bA * df.MedianAgeMarriage_s'
	lp5_3s = logpdf.(Normal.(mu5_3s, post5_3s_df.sigma),  df.Divorce_s')
	waic_m5_3s = waic(lp5_3s)
end

[waic_m5_1s.WAIC, waic_m5_3s.WAIC, waic_m5_2s.WAIC]

begin
	loo5_1s, loos5_1s, pk5_1s = psisloo(lp5_1s)
	loo5_2s, loos5_2s, pk5_2s = psisloo(lp5_2s)
	loo5_3s, loos5_3s, pk5_3s = psisloo(lp5_3s)
	[-2loo5_1s, -2loo5_3s, -2loo5_2s]
end

begin
	pk_plot(pk5_1s)
	annotate!([(13 + 1, pk5_1s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

begin
	pk_plot(pk5_3s)
	annotate!([(13 + 1, pk5_3s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

pk_plot(pk5_2s)

waic_5_3s_pw = waic(lp5_2s; pointwise=true)

waic_5_3s_pw.penalty[13]

begin
	scatter(pk5_3s, waic_5_3s_pw.penalty,
		xlab="PSIS Pareto k", ylab="WAIC penalty", leg=false)
	vline!([0.5])
	annotate!([([pk5_3s[13]], [waic_5_3s_pw.penalty[13] + 0.02],
		Plots.text(df[13, :Loc], 6, :red, :right))])
	annotate!([([pk5_3s[20]], [waic_5_3s_pw.penalty[20] + 0.02],
		Plots.text(df[20, :Loc], 6, :red, :right))])

end

md" ## End of clip-07-32-34s.jl"

