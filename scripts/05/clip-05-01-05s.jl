
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## clip-05-01-05s.jl"

md"### snippet 5.1"

md"##### Notice that in below Stan language model we ignore the observed data (the likelihood is commented out). The draws show sampled regression lines implied by the priors. This is an alternative to the formulation chosen in clip-04-01-05s.jl"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

stan5_1_alt_priors = "
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
	  //D ~ normal(mu , sigma);   // Likelihood
	}
";

md"### snippet 5.3 - 5.4"

md"## Define the SampleModel, etc."

begin
	m5_1s = SampleModel("MedianAgeMarriage", stan5_1_alt_priors)
	m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s)
	rc5_1s = stan_sample(m5_1s, data=m5_1_data)
	success(rc5_1s) && (post5_1s_df = read_samples(m5_1s; output_format=:dataframe))
end;

PRECIS(post5_1s_df)

md"### snippet 5.5"

md"##### Plot priors of the intercept (`:a`) and the slope (`:bA`)."

if success(rc5_1s)
	xi = -3.0:0.1:3.0
	plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
		title="Showing 50 regression lines")
	for i in 1:50
		local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
		plot!(xi, yi, color=:lightgrey, leg=false)
	end
	scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)
end

md"## End of clip-05-01-05.jl"

