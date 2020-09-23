
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.1s.jl"))

include(projectdir("models", "05", "m5.2s.jl"))

md"## Clip-05-01-02s.jl"

md"### snippet 5.1"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:MedianAgeMarriage, :Marriage])
end;

md"##### The model m5.1s represents a regression of Divorce on MedianAgeMarriage and is defined as:"

md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * A;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

md"##### Both D (Divorce rate) and A (MediumAgeMarriage) are standardized."

md"##### The model m5.2s represents a regression of Divorce on Marriage and is defined as:"

md"
```
model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         // Priors
  bM ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bM * M;
  D ~ normal(mu , sigma);     // Likelihood
}
```
"

md"##### Both D (Divorce rate) and A (Marriage rate) are standardized."

md"### snippet 5.2"

std(df.MedianAgeMarriage)

if success(rc)

	# Compute quap approximation.

	dfa1 = read_samples(m5_1s; output_format=:dataframe)
	q_m_5_1 = quap(dfa1)
end

md"##### Result rethinking:"

rethinking = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bA    -0.57 0.11 -0.74 -0.39
sigma  0.79 0.08  0.66  0.91
";

if success(rc)

	# Plot regression line D on A

	title1 = "Divorce rate vs. median age at marriage" * "\nshowing predicted and quantile range"
	p1 = plotbounds(
		df, :MedianAgeMarriage, :Divorce,
		dfa1, [:a, :bA, :sigma];
		title=title1,
		colors=[:lightblue, :darkgrey]
	)
end

if success(rc)

	# Compute quap approximation.

	dfa2 = read_samples(m5_2s; output_format=:dataframe)
	q_m_5_2 = quap(dfa2)
end

if success(rc)

	# Plot regression line D on M


	title2 = "Divorce rate vs. marriage rate" * "\nshowing predicted and hpdi range"
	p2 = plotbounds(
		df, :Marriage, :Divorce,
		dfa2, [:a, :bM, :sigma];
		title=title2,
		colors=[:lightblue, :darkgrey]
	)

end

	plot(p2, p1, layout=(1,2), title="")

md"## End of clip-05-01-02s.jl"

