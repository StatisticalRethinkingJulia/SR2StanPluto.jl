
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
	data = (N=size(df, 1), D=df.Divorce_s, A=df.MedianAgeMarriage_s,
		M=df.Marriage_s)
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

begin
	m5_1s = SampleModel("m5.1s", stan5_1)
	rc5_1s = stan_sample(m5_1s; data)
	if success(rc5_1s)
		post5_1s_df = read_samples(m5_1s; output_format=:dataframe)
		PRECIS(post5_1s_df[:, [:a, :bA, :sigma]])
	end
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

begin
	m5_2s = SampleModel("m5.2", stan5_2);
	rc5_2s = stan_sample(m5_2s; data)
	if success(rc5_2s)
		post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
		PRECIS(post5_2s_df[:, [:a, :bM, :sigma]])
	end
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
	waic(m5_3s)
end

begin
    b5_3s = post5_3s_df[:, [:a, :bA, :bM, :sigma]]
    mu5_3s = b5_3s.a .+ b5_3s.bM * df.Marriage_s' +
		b5_3s.bA * df.MedianAgeMarriage_s'
	log_lik5_3s = logpdf.(Normal.(mu5_3s, post5_3s_df.sigma),  df.Divorce_s')
	waic(log_lik5_3s)
end

df_waic = compare([m5_1s, m5_2s, m5_3s], :waic)

md"
```
      PSIS    SE   dPSIS   dSE   pPSIS   weight
 m5.1 127.6 14.69   0.0    NA     4.7    0.71
 m5.3 129.4 15.10   1.8   0.90    5.9    0.29
 m5.2 140.6 11.21  13.1  10.82    3.8    0.00
```
"

df_psis = compare([m5_1s, m5_2s, m5_3s], :psis)

begin
	loo5_1s, loos5_1s, pk5_1s = psisloo(m5_1s)
	pk_plot(pk5_1s)
	annotate!([(13 + 1, pk5_1s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

begin
	loo5_3s, loos5_3s, pk5_3s = psisloo(m5_3s)
	pk_plot(pk5_3s)
	annotate!([(13 + 1, pk5_3s[13] + 0.02, Plots.text(df[13, :Loc],
		6, :red, :right))])
end

waic_5_3s_pw = waic(m5_3s; pointwise=true)

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

