
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-28-34s.jl"

md"### snippet 5.28 - 5.31"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df.lmass = log.(df.mass)
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

stan_5_5_draft = "
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
  a ~ normal(0, 1);           //Priors
  bN ~ normal(0, 1);
  sigma ~ exponential(1);
  mu = a + bN * NC;
  K ~ normal(mu , sigma);     // Likelihood
}
";

md"##### Define the SampleModel, etc."

begin
	m5_5_drafts = SampleModel("m5.5.draft", stan_5_5_draft);
	m5_5_data = Dict("N" => size(df, 1), "NC" => df.neocortex_perc_s,
		"K" => df.kcal_per_g_s);
	rc5_5_drafts = stan_sample(m5_5_drafts, data=m5_5_data)
end;

if success(rc5_5_drafts)
  post5_5_drafts_df = read_samples(m5_5_drafts; output_format=:dataframe)
end;

md"## Result rethinking."

rethinking = "
        mean   sd  5.5% 94.5%
  a     0.09 0.24 -0.28  0.47
  bN    0.16 0.24 -0.23  0.54
  sigma 1.00 0.16  0.74  1.26
";

Particles(post5_5_drafts_df)

if success(rc5_5_drafts)
  p = plot(title="m5.5.drafts: a ~ Normal(0, 1), bN ~ Normal(0, 1)")
  x = -2:0.01:2
  for j in 1:100
    y = post5_5_drafts_df[j, :a] .+ post5_5_drafts_df[j, :bN]*x
    plot!(p, x, y, color=:lightgrey, leg=false)
  end
	plot(p)
end

md"## End of clip-05-28-34s.jl"

