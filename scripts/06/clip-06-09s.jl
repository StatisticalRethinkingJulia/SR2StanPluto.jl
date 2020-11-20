
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-06-09s.jl"

begin
	df = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	scale!(df, [:kcal_per_g, :perc_fat, :perc_lactose])
end;

stan6_4 = "
data{
  int <lower=1> N;              // Sample size
  vector[N] K;
  vector[N] L;
}
parameters{
  real a;
  real bL;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.2 );
  bL ~ normal( 0 , 0.5 );
  mu = a + bL * L;
  K ~ normal( mu , sigma );
}
";

md"##### Define the SampleModel, etc."

begin
	m6_4s = SampleModel("m6.3", stan6_4);
	m6_4_data = Dict("N" => size(df, 1), "L" => df.perc_lactose_s, "K" => df.kcal_per_g_s);
	rc6_4s = stan_sample(m6_4s, data=m6_4_data);
	success(rc6_4s) && (post6_4s_df = read_samples(m6_4s; output_format=:dataframe))
end;

success(rc6_4s) && (part6_4s = Particles(post6_4s_df))

success(rc6_4s) && (quap6_4s = quap(post6_4s_df))

success(rc6_4s) && hpdi(part6_4s.bL.particles, alpha=0.11)

md"## End of clip-06-06-09s.jl"

