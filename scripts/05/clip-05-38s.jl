
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

for i in 5:6
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

md"## Clip-05-38s.jl"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	df = filter(row -> !(row[:neocortex_perc] == "NA"), df)
	df.neocortex_perc = parse.(Float64, df.neocortex_perc)
	df.lmass = log.(df.mass)
	scale!(df, [:kcal_per_g, :neocortex_perc, :lmass])
end;

m5_7 = "
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

md"##### Define the SampleModel, etc."

begin
	m5_7s = SampleModel("m5.7", m5_7);
	m5_7_data = Dict("N" => size(df, 1), "M" => df[!, :lmass_s],
		"K" => df[!, :kcal_per_g_s], "NC" => df[!, :neocortex_perc_s]);
	rc = stan_sample(m5_7s, data=m5_7_data);
	success(rc) && (dfa7 = read_samples(m5_7s; output_format=:dataframe))
end;

success(rc) && Particles(dfa7)

success(rc) && quap(dfa7)

(s1, p1) = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM], "",
  "Masked relationships: bN & bM Normal estimates")

plot(p1)

(s2, p2) = plotcoef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM], "",
	"Masked relationships: bN & bM Quap estimates", quap)

plot(p2)

md"## End of clip-05-38s.jl"

