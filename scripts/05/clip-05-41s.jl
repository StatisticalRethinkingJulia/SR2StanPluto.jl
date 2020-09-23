
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-41s.jl"

begin
	df1 = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';');
	df1 = filter(row -> !(row[:neocortex_perc] == "NA"), df1);

	df = DataFrame()
	df[!, :NC] = parse.(Float64, df1[:, :neocortex_perc])
	df[!, :M] = log.(df1[:, :mass])
	df[!, :K] = df1[:, :kcal_per_g]
	scale!(df, [:K, :NC, :M])
end;


m5_7_A = "
data {
  int N;
  vector[N] K;
  vector[N] M;
  vector[N] NC;
}
parameters {
  real a;
  real bN;
  real bM;
  real aNC;
  real bMNC;
  real<lower=0> sigma;
  real<lower=0> sigma_NC;
}
model {
  // M -> K <- NC
  vector[N] mu = a + bN * NC + bM * M;
  a ~ normal( 0 , 0.2 );
  bN ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  K ~ normal( mu , sigma );
  // M -> NC
  vector[N] mu_NC = aNC + bMNC * M;
  aNC ~ normal( 0 , 0.2 );
  bMNC ~ normal( 0 , 0.5 );
  sigma_NC ~ exponential( 1 );
  NC ~ normal( mu_NC , sigma_NC );
}
";

begin
	m5_7_As = SampleModel("m5.7_A", m5_7_A);
	m5_7_A_data = Dict(
	  "N" => size(df, 1), 
	  "K" => df[:, :K_s],
	  "M" => df[:, :M_s],
	  "NC" => df[:, :NC_s] 
	);
	rc = stan_sample(m5_7_As, data=m5_7_A_data);
	dfa = read_samples(m5_7_As,; output_format=:dataframe);
end;

md"### Snippet 5.22"

a_seq = range(-2, stop=2, length=100)

m_sim, d_sim = simulate(dfa, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma]);

md"### Snippet 5.24"

begin
	plot(xlab="Manipulated M", ylab="Counterfactual K",
		title="Total counterfactual effect of M on K")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

md"## End of clip-05-41s.jl"

