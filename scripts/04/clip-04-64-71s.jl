
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"# Clip-04-64-68s.jl"

md"### Preliminary snippets."

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	scale!(df, [:height, :weight])
	df.weight_sq_s = df.weight_s.^2
	#scale!(df, [:weight_sq])
end;

md"##### Define the Stan language model."

stan4_5 = "
data{
    int N;
    vector[N] height;
    vector[N] weight;
    vector[N] weight_sq;
}
parameters{
    real alpha;
    real beta1;
    real beta2;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta1 ~ lognormal( 0 , 1 );
    beta2 ~ normal( 0 , 1 );
    alpha ~ normal( 178 , 20 );
    mu = alpha + beta1 * weight + beta2 * weight_sq;
    height ~ normal( mu , sigma );
}
";

md"##### Define the SampleModel, etc,"

begin
	m4_5s = SampleModel("m4.5s", stan4_5);
	data = Dict(
		:N => size(df, 1), 
		:height => df.height, 
		:weight => df.weight_s,
		:weight_sq => df.weight_sq_s
	)
	init = Dict(:alpha => 140.0, :beta1 => 15.0, :beta2 => -5.0, :sigma => 10.0)
	q4_5s, m4_5s, _ = quap("m4.5s", stan4_5; data, init)
	quap4_5s_df = sample(q4_5s)
	PRECIS(quap4_5s_df)
end

rethinking = "
        mean   sd   5.5%  94.5%
a     146.06 0.37 145.47 146.65
b1     21.73 0.29  21.27  22.19
b2     -7.80 0.27  -8.24  -7.36
sigma   5.77 0.18   5.49   6.06
";

if !isnothing(m4_5s)
  sdf4_5s = read_summary(m4_5s)
end

md"### Snippet 4.64 - 4.67"

if !isnothing(q4_5s)
	begin
		function link_poly(dfa::DataFrame, xrange)
			vars = Symbol.(names(dfa))
			[dfa[:, vars[1]] + dfa[:, vars[2]] * x +  dfa[:, vars[3]] * x^2 for x in xrange]
		end

		mu_range = -2:0.1:2

		xbar = mean(df[:, :weight])
		mu = link_poly(quap4_5s_df, mu_range);

		plot(xlab="weight_s", ylab="height")
		for (indx, mu_val) in enumerate(mu_range)
		for j in 1:length(mu_range)
			scatter!([mu_val], [mu[indx][j]], leg=false, color=:darkblue)
		end
		end
		scatter!(df.weight_s, df.height, color=:lightblue)
	end
end

if !isnothing(q4_5s)
	plot(xlab="weight_s", ylab="height", leg=:bottomright)
	fheight(weight, a, b1, b2) = a + weight * b1 + weight^2 * b2
	testweights = -2:0.01:2
	arr = [fheight.(w, quap4_5s_df.alpha, quap4_5s_df.beta1, quap4_5s_df.beta2) for w in testweights]
	m = [mean(v) for v in arr]
	quantiles = [quantile(v, [0.055, 0.945]) for v in arr]
	lower = [q[1] - m for (q, m) in zip(quantiles, m)]
	upper = [q[2] - m for (q, m) in zip(quantiles, m)]
	scatter!(df[:, :weight_s], df[:, :height], lab="Observations")
	plot!(testweights, m, ribbon = [lower, upper], lab="(0.055, 0.945) quantiles of mean")
end

md"## End of clip-04-64-68s.jl"

