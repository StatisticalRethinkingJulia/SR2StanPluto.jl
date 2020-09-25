
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-08s.jl"

begin
df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end

m6_3 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] F;
}
parameters{
  real a;
  real bF;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bF ~ normal( 0 , 0.5 );
  mu = a + bF * F;
  K ~ normal( mu , sigma );
}
";


begin
	m6_3s = SampleModel("m6.3", m6_3);
	m6_3_data = Dict("N" => size(df, 1), "F" => df.perc_fat_s, "K" => df.kcal_per_g_s);
	rc = stan_sample(m6_3s, data=m6_3_data);
	success(rc) && (dfa6_3 = read_samples(m6_3s; output_format=:dataframe))
end

success(rc) && (p = Particles(dfa6_3))

success(rc) && quap(dfa6_3)

hpdi(p.bF.particles, alpha=0.11)

md"## End of clip-06-08s.jl"

