
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-35-37s.jl"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df);
	df[!, :neocortex_perc] = parse.(Float64, df[:, :neocortex_perc])
	df[!, :lmass] = log.(df[:, :mass])
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

md"### snippet 5.35"

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

md"## Define the SampleModel, etc."

begin
	m5_5s = SampleModel("m5.5", stan5_5);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df[!, :neocortex_perc_s],
		"K" => df[!, :kcal_per_g_s]);
	rc5_5s = stan_sample(m5_5s, data=m5_5_data);
end;

if success(rc5_5s)
  post5_5s_df = read_samples(m5_5s; output_format=:dataframe)
  title = "Kcal_per_g vs. neocortex_perc" * "\nshowing predicted and hpd range"
  plotbounds(
    df, :neocortex_perc, :kcal_per_g,
    post5_5s_df, [:a, :bN, :sigma];
    title=title
  )
end

md"## End of clip-05-35-37s.jl"

