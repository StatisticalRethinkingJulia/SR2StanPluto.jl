
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-38s.jl"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
	df[!, :lmass] = log.(df[:, :mass])
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
	data = (N = size(df, 1), M = df[!, :lmass_s],
		K = df[!, :kcal_per_g_s], NC = df[!, :neocortex_perc_s]);
end;

stan5_5 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
}

parameters {
 real a; // Intercept
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

begin
	m5_5s = SampleModel("m5.5", stan5_5)
	rc5_5s = stan_sample(m5_5s; data)
end;

stan5_6 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  K ~ normal(mu , sigma);     // Likelihood
}
";

begin
	m5_6s = SampleModel("m5.6", stan5_6);
	rc5_6s = stan_sample(m5_6s; data)
end;

stan5_7 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] K; // Outcome
 vector[N] NC; // Predictor
 vector[N] M; // Predictor
}

parameters {
 real a; // Intercept
 real bM; // Slope (regression coefficients)
 real bN; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);           //Priors
  bN ~ normal(0, 0.5);
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

begin
	m5_7s = SampleModel("m5.7", stan5_7)
	rc5_7s = stan_sample(m5_7s; data)
end;

if success(rc5_5s) && success(rc5_6s) && success(rc5_7s)
	(s1, p1) = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	p1
end

s1

md"## End of clip-05-38s.jl"

