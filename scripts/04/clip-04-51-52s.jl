
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-51-52s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df)
	xbar = mean(df.weight)
	df.weight_c = df.weight .- xbar
end;

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

if !isnothing(q4_3s)
	scatter(df.weight, df.height, lab="Observations",
	  ylab="height [cm]", xlab="weight[kg]", leg=:topleft)
	xi = 30.0:0.1:60.0
	yi = mean(quap4_3s_df.alpha) .+ mean(quap4_3s_df.beta) * (xi .- xbar)
	plot!(xi, yi, lab="Regression line")
end

md"### snippet 4.51"

density(quap4_3s_df.alpha + quap4_3s_df.beta * (50 - xbar), lab="mu | weight=50")

md"### snippet 4.52"

begin
	plot(xlab="Height | weight=[30, 50, 60]", ylab="Density")
	density!(quap4_3s_df.alpha + quap4_3s_df.beta * (30 - xbar), lab="mu | weight=30")
	density!(quap4_3s_df.alpha + quap4_3s_df.beta * (50 - xbar), lab="mu | weight=50")
	density!(quap4_3s_df.alpha + quap4_3s_df.beta * (70 - xbar), lab="mu | weight=70")
end

md"## End of clip-04-51-52s.jl"

