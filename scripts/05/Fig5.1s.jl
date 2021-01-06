
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig5.1s.jl"

begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame)
	
	# Use WaffleHouses/Populations = Waffle houses per million
	
	df.WaffleHouses = df.WaffleHouses ./ df.Population
	scale!(df, [:WaffleHouses, :Divorce])
end;

	PRECIS(df[:, 3:15])

stan5_0 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] D; // Outcome (Divorce rate)
 vector[N] W; // Predictor ()
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         //Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * W;
  D ~ normal(mu , sigma);     // Likelihood
}
";

md"##### Define the SampleModel."

m5_0s = SampleModel("Fig5.1", stan5_0);

md"##### Input data."

wd_data = Dict("N" => size(df, 1), "D" => df[:, :Divorce_s],
    "W" => df[:, :WaffleHouses_s]);

md"##### Sample using StanSample."

rc5_0s = stan_sample(m5_0s, data=wd_data);

if success(rc5_0s)
	begin

	  # Plot regression line using means and observations

	  post5_0s_df = read_samples(m5_0s; output_format=:dataframe)
	  part5_0s = Particles(post5_0s_df)
	end
end

if success(rc5_0s)
	q5_0s = quap(m5_0s)
	quap5_0s_df = sample(q5_0s)
	PRECIS(quap5_0s_df)
end

md"##### Figure out which annotations we want."

df[[1, 4, 11, 20, 30, 40], [1, 2, 7, 9]]

df[:,1]

if success(rc5_0s)
	begin
		p2 = plotbounds(
			df, :WaffleHouses, :Divorce,
			post5_0s_df, [:a, :bA, :sigma];
			bounds=[:predicted, :hpdi],
			title="Divorce rate vs. waffle houses per million" * "\nshowing predicted and hpd range",
			xlab="Waffle houses per million",
			ylab="Divorce rate"
		)
		for i in [1, 4, 11, 20, 30, 40]
			annotate!(p2, [(df[i, :WaffleHouses]+01.5, df[i, :Divorce], Plots.text(df[i, 2],
				6, :red, :right))])
		end
	end
	plot(p2)
end

md"## End of Fig5.1s.jl"

