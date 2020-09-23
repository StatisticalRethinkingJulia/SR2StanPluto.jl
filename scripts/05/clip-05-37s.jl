
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-37s.jl"

md"### snippet 5.29"

begin
	df = CSV.read(sr_datadir("milk.csv"), delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	df.lmass = log.(df.mass)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

md"### snippet 5.1"

m5_6 = "
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

md"## Define the SampleModel, etc."

begin
	m5_6s = SampleModel("m5.6", m5_6);
	m5_6_data = Dict("N" => size(df, 1), "M" => df.lmass_s, "K" => df.kcal_per_g_s);
	rc = stan_sample(m5_6s, data=m5_6_data);
end;

if success(rc)

  # Describe the draws

  dfa6 = read_samples(m5_6s; output_format=:dataframe)

  title = "Kcal_per_g vs. log mass" * "\nshowing 89% predicted and hpd range"
  plotbounds(
    df, :lmass, :kcal_per_g,
    dfa6, [:a, :bM, :sigma];
    title=title
  )
end

md"## End of clip-05-37s.jl"

