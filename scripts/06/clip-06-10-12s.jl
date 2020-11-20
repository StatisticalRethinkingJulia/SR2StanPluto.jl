
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

for f in ["m6.3s.jl", "m6.4s.jl"]
  include(projectdir("models", "06", f))
end

md"## Clip-06-10-12s.jl"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end;

stan6_5 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
  vector[N] L;
}
parameters{
  real a;
  real bL;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bL ~ normal( 0 , 0.5 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bL * L + bF * F;
  K ~ normal( mu , sigma );
}
";

md"##### Define the SampleModel, etc."

begin
	m6_5s = SampleModel("m6.5s", stan6_5);
	m6_5_data = Dict("N" => size(df, 1), "L" => df.perc_lactose_s, "F" => df.perc_fat_s,
		"K" => 	df.kcal_per_g_s);
	rc6_5s = stan_sample(m6_5s, data=m6_5_data)
	success(rc6_5s) && (post6_5s_df = read_samples(m6_5s; output_format=:dataframe))
end;

success(rc6_5s) && (p6_5s = Particles(post6_5s_df))

if success(rc6_5s)
	(s6_5s, f6_5s) = plotcoef([m6_3s, m6_4s, m6_5s], [:a, :bF, :bL, :sigma];
		title="Multicollinearity for milk model using quap()", func=quap)
	f6_5s
end

success(rc6_5s) && s6_5s

md"### Snippet 6.11"

pairsplot(df, [:kcal_per_g, :perc_fat, :perc_lactose], "")

md"### Snippet 6.12"

cor(df.perc_fat, df.perc_lactose)

md"## End of clip-06-10-12s.jl"

