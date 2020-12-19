
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanOptimize
	using StatisticalRethinking
end

md"## Intro-stan-04s.jl"

	stan1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}";

begin
	N = 25                              	# 25 experiments
	d = Binomial(9, 0.66)               	# 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      	# Simulate 15 trial results
	n = 9                               	# Each experiment has 9 tosses
	data = Dict("N" => N, "n" => n, "k" => k)
	init = Dict(:theta => 0.5)
end

begin
	q1_1s, m1_1s, om = quap("m1.1s", stan1_1; data, init)
	if !isnothing(m1_1s)
		post1_1s_df = read_samples(m1_1s, output_format=:dataframe)
	end
	PRECIS(post1_1s_df)
end

begin
	quap1_1s_df = sample(q1_1s)
	PRECIS(quap1_1s_df)
end

md"##### This scripts shows a number of different ways to estimate a quadratic approximation."

md"##### Compare with MLE."

part1_1s = Particles(post1_1s_df)

md"###### MLE estimate"

mle_fit = fit_mle(Normal, post1_1s_df.theta)

md"###### Using optim (compare with quap() result above)."

function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), k)))
  -ll
end

begin
	res = optimize(loglik, 0.0, 1.0)
	mu_optim = Optim.minimizer(res)[1]
	sigma_optim = std(post1_1s_df[:, :theta], mean=mu_optim)
	[mu_optim, sigma_optim]
end

md"###### Show the hpd region"

bnds_hpd = hpdi(post1_1s_df.theta, alpha=0.11)

begin
	x = 0.5:0.001:0.8
	plot( x, pdf.(Normal( mean(mle_fit) , std(mle_fit)) , x ),
		xlim=(0.5, 0.8), lab="MLE approximation",
		legend=:topleft, line=:dash)
	plot!( x, pdf.(Normal( mean(part1_1s.theta), std(part1_1s.theta)), x ),
		lab="Particle approximation", line=:dash)
	plot!( x, pdf.(Normal( q1_1s.coef.theta, √q1_1s.vcov[1]), x ),
		lab="quap approximation")
	density!(post1_1s_df.theta, lab="StanSample chain")
	vline!([bnds_hpd[1]], line=:dash, lab="hpd lower bound")
	vline!([bnds_hpd[2]], line=:dash, lab="hpd upper bound")
end

md"In this example usually most approximations are similar. Other examples are less clear."

md"## End of intro-stan/intro-stan-04s.jl"

