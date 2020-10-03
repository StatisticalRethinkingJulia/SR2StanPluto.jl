
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-03-10s.jl"

md"##### Define the Stan language model."

m3_1 = "
// Inferring a Rate
data {
  int N;
  int<lower=0> k[N];
  int<lower=1> n[N];
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> thetaprior;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);
  thetaprior ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

md"##### Define the SampleModel."

m3_1s = SampleModel("m3_1ss", m3_1);

md"##### Use 4 observations."

begin
	N2 = 4
	n2 = Int.(9 * ones(Int, N2))
	k2 = [6, 5, 7, 6]
end

md"##### Input data for stan_sample()."

m3_1_data = Dict("N" => length(n2), "n" => n2, "k" => k2);

md"##### Sample using stan_sample()."

rc3_1s = stan_sample(m3_1s, data=m3_1_data);

if success(rc3_1s)
  chn = read_samples(m3_1s; output_format=:mcmcchains)
end

chn

md"##### Plot the chains."

begin
	mixeddensity(chn)
	bnds = MCMCChains.hpd(chn)
	vline!([bnds[:theta, :lower]], line=:dash)
	vline!([bnds[:theta, :upper]], line=:dash)
end

md"##### Look at area of hpd."

MCMCChains.hpd(chn)

md"## End of clip-03-10s.jl"

