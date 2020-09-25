
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

m6_5 = "
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
	m6_5s = SampleModel("m6.5s", m6_5);
	m6_5_data = Dict("N" => size(df, 1), "L" => df.perc_lactose_s, "F" => df.perc_fat_s,
		"K" => 	df.kcal_per_g_s);
	rc = stan_sample(m6_5s, data=m6_5_data)
	success(rc) && (dfa6_5 = read_samples(m6_5s; output_format=:dataframe))
end;

success(rc) && (p = Particles(dfa6_5))

if success(rc)
	(r1, p1) = plotcoef([m6_3s, m6_4s, m6_5s], [:a, :bF, :bL, :sigma], "",
		"Multicollinearity for milk model using quap()", quap)
	p1
end

success(rc) && r1

md"### Snippet 6.11"

pairsplot(df, [:kcal_per_g, :perc_fat, :perc_lactose], "")

md"### Snippet 6.12"

cor(df.perc_fat, df.perc_lactose)

md"## End of clip-06-10-12s.jl"

