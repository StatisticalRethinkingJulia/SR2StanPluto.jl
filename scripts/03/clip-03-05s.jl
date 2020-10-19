
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-03-05s.jl"

md"##### Define the Stan language model."

m3_5 = "
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

md"##### Define the Stanmodel and set the output format to :mcmcchains."

m3_5s = SampleModel("m3_5s", m3_5);

md"###### Use 16 observations."

begin
	N2 = 4^2
	d = Binomial(9, 0.66)
	n2 = Int.(9 * ones(Int, N2))
	k2 = rand(d, N2)
end

md"##### Input data for cmdstan."

m3_5_data = Dict("N" => length(n2), "n" => n2, "k" => k2);

md"##### Sample using cmdstan."

rc3_5s = stan_sample(m3_5s, data=m3_5_data);

md"##### Retrieve samples as an MCMCChains.Chain object and as a Particles summary.."

if success(rc3_5s)
  chns3_5s = read_samples(m3_5s; output_format=:mcmcchains)
  part3_5s = read_samples(m3_5s; output_format=:particles)
end;

md"##### Describe the chains."

chns3_5s

md"##### Plot the chains."

plot(chns3_5s)

md"##### Particles summary of the chains,"

part3_5s

md"##### Notice in this example that the prior theta (thetaprior), the `unconditioned-on-the data theta`, shows a mean of 0.5 and a std of 0.29."

md"## End of clip-03-05s.jl"

