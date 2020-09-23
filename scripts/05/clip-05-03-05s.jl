
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## clip-05-03-05s.jl"

md"### snippet 5.1"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

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
	  //D ~ normal(mu , sigma);   // Likelihood
	}
";

md"### snippet 5.3 - 5.4"

md"## Define the SampleModel, etc."

m5_1s = SampleModel("MedianAgeMarriage", m5_1);

m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s);

rc = stan_sample(m5_1s, data=m5_1_data);

md"### snippet 5.5"

if success(rc)
	begin

		# Plot regression line using means and observations

		dfa = read_samples(m5_1s; output_format=:dataframe)
		xi = -3.0:0.1:3.0
		plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
			title="Showing 50 regression lines")
		for i in 1:50
			local yi = mean(dfa[i, :a]) .+ dfa[i, :bA] .* xi
			plot!(xi, yi, color=:lightgrey, leg=false)
		end

		scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)

	end

end

md"## End of clip-05-03-05.jl"

