
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
end;

stan6_3 = "
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
	m6_3s = SampleModel("m6.3", stan6_3);
	m6_3_data = Dict("N" => size(df, 1), "F" => df.perc_fat_s, "K" => df.kcal_per_g_s);
	rc6_3s = stan_sample(m6_3s, data=m6_3_data);
	success(rc6_3s) && (post6_3s_df = read_samples(m6_3s; output_format=:dataframe))
end;

success(rc6_3s) && (part6_3s = Particles(post6_3s_df))

success(rc6_3s) && quap(post6_3s_df)

hpdi(part6_3s.bF.particles, alpha=0.11)

md"## End of clip-06-08s.jl"

