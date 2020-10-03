
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-42-43s.jl"

md"### Include snippets 5.42-5.43"

begin
	n = 100
	df = DataFrame(:M => rand(Normal(), n),)
	df.NC = [rand(Normal(df[i, :M]), 1)[1] for i in 1:n]
	df.K = [rand(Normal(df[i, :NC] - df[i, :M]), 1)[1] for i in 1:n]
	scale!(df, [:K, :M, :NC])
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
	rc5_7_As = stan_sample(m5_7_As, data=m5_7_A_data);
	dfa5_7_As = read_samples(m5_7_As,; output_format=:dataframe);
end;

md"### Snippet 5.22"

a_seq = range(-2, stop=2, length=100);

md"### Snippet 5.23"

m_sim, d_sim = simulate(dfa5_7_As, [:aNC, :bMNC, :sigma_NC], a_seq, [:bM, :sigma]);

md"### Snippet 5.24"

begin
	fig1 = plot(xlab="Manipulated M", ylab="Counterfactual K",
	  title="Total counterfactual effect of M on K")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array1 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array1[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array1[:, 1], -hpdi_array1[:, 2]))
end

begin
	fig2 = plot(xlab="Manipulated M", ylab="Counterfactual NC",
	  title="Counterfactual effect of M on NC")
	plot!(a_seq, mean(m_sim, dims=1)[1, :], leg=false)
	hpdi_array2 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
	  hpdi_array2[i, :] =  hpdi(m_sim[i, :])
	end
	plot!(a_seq, mean(m_sim, dims=1)[1, :]; ribbon=(hpdi_array2[:, 1], -hpdi_array2[:, 2]))
end

md"##### NC -> K"

begin
	nc_seq = range(-2, stop=2, length=100)
	nc_k_sim = zeros(size(dfa5_7_As, 1), length(nc_seq))
	for j in 1:size(dfa5_7_As, 1)
	  for i in 1:length(nc_seq)
		d = Normal(dfa5_7_As[j, :a] + dfa5_7_As[j, :bN] * nc_seq[i], dfa5_7_As[j, :sigma])
		nc_k_sim[j, i] = rand(d, 1)[1]
	  end
	end
	fig3 = plot(xlab="Manipulated NC", ylab="Counterfactual K",
	  title="Counterfactual effect of NC on K")
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :], leg=false)
	hpdi_array3 = zeros(length(nc_seq), 2)
	for i in 1:length(nc_seq)
	  hpdi_array3[i, :] =  hpdi(nc_k_sim[i, :])
	end
	plot!(nc_seq, mean(nc_k_sim, dims=1)[1, :]; ribbon=(hpdi_array3[:, 1], -hpdi_array3[:, 2]))
end

plot(fig1, fig2, fig3, layout=(3, 1))

md"## End of clip-05-42-43s.jl"

