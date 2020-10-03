
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.2s.jl"))

md"## Clip-05-01-02s.jl"

md"### snippet 5.1"

md"##### D (Divorce rate), A (MediumAgeMarriage) and M (Marriage rate) are all standardized."

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Divorce, :MedianAgeMarriage, :Marriage])
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

md"##### The Stan language model."

m5_1 = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] D; // Outcome
	 vector[N] A; // Predictor
	}

	parameters {
	 real a; // Intercept
	 real bA; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  a ~ normal(0, 0.2);         // Priors
	  bA ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	  mu = a + bA * A;
	  D ~ normal(mu , sigma);   // Likelihood
	}
";

begin
	m5_1s = SampleModel("m5.1s", m5_1)
	m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s)
	rc5_1s = stan_sample(m5_1s, data=m5_1_data)
	success(rc5_1s) && (part5_1s = read_samples(m5_1s; output_format=:particles))
end

md"##### Compare below figure with the corresponding figure in clip-05-01-05s.jl."

if success(rc5_1s)
	begin

		# Plot regression line using means and observations

		dfa5_1s = read_samples(m5_1s; output_format=:dataframe)
		xi = -3.0:0.1:3.0
		plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
			title="Showing 50 regression lines")
		for i in 1:50
			local yi = mean(dfa5_1s[i, :a]) .+ dfa5_1s[i, :bA] .* xi
			plot!(xi, yi, color=:lightgrey, leg=false)
		end

		scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)

	end

end

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

if success(rc5_2s)

	# Compute quap approximation.

	quap5_1s = quap(dfa5_1s)
end

md"##### Result rethinking:"

rethinking = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bA    -0.57 0.11 -0.74 -0.39
sigma  0.79 0.08  0.66  0.91
";

if success(rc5_1s)

	# Plot regression line D on A

	title1 = "Divorce rate vs. median age at marriage" * "\nshowing predicted and quantile range"
	fig1 = plotbounds(
		df, :MedianAgeMarriage, :Divorce,
		dfa5_1s, [:a, :bA, :sigma];
		title=title1,
		colors=[:lightblue, :darkgrey]
	)
end

if success(rc5_2s)

	# Compute quap approximation.

	dfa5_2s = read_samples(m5_2s; output_format=:dataframe)
	quap5_2s = quap(dfa5_2s)
end

if success(rc5_2s)

	# Plot regression line D on M


	title2 = "Divorce rate vs. marriage rate" * "\nshowing predicted and hpdi range"
	fig2 = plotbounds(
		df, :Marriage, :Divorce,
		dfa5_2s, [:a, :bM, :sigma];
		title=title2,
		colors=[:lightblue, :darkgrey]
	)

end

	plot(fig2, fig1, layout=(1,2), title="")

md"## End of clip-05-01-02s.jl"

