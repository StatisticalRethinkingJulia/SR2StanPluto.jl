
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-44-46s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df)
	mean_weight = mean(df.weight)
	df.weight_c = df.weight .- mean_weight
end

PRECIS(df)

md"##### Define the Stan language model."

stan4_3 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] height; // Predictor
 vector[N] weight; // Outcome
}

parameters {
 real alpha; // Intercept
 real beta; // Slope (regression coefficients)
 real < lower = 0 > sigma; // Error SD
}

model {
 height ~ normal(alpha + weight * beta , sigma);
}
";

md"## snippet 4.44"

md"##### Quadratic approximation."

begin
	data = Dict(:N => length(df.height), :height => df.height, :weight => df.weight_c)
	init = Dict(:alpha => 170.0, :beta => 2.0, :sigma => 10.0)
	q4_3s, m4_3s, _ = quap("m4.3s", stan4_3; data, init)
end;

if !isnothing(q4_3s)
	quap4_3s_df = sample(q4_3s)
	PRECIS(quap4_3s_df)
end

md"##### Read the Stan samples."

if !isnothing(m4_3s)
	post4_3s = read_samples(m4_3s; output_format=:dataframe)
	part4_3s = Particles(post4_3s)
end

PRECIS(post4_3s)

md"## snippet 4.45"

begin
	nms = [string(k) for k in keys(q4_3s.coef)]
	covm = NamedArray(Matrix(q4_3s.vcov), (nms, nms), ("Rows", "Cols"))
	covm
end

md"### snippet 4.46"

if !isnothing(m4_3s)

	# Plot regression line using means and observations

	scatter(df.weight_c, df.height, lab="Observations",
	  ylab="height [cm]", xlab="weight[kg]", leg=:topleft)
	xi = -16.0:0.1:18.0
	yi = mean(post4_3s.alpha) .+ mean(post4_3s.beta)*xi;
	plot!(xi, yi, lab="Regression line")
end

md"## End of clip-04-44-46s.jl"

