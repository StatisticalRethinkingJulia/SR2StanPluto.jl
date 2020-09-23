
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-53-58s.jl"

md"### Preliminary snippets."

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame, delim=';')
	df = filter(row -> row[:age] >= 18, df);
	scale!(df, [:height, :weight])
end;

md"##### Define the Stan language model."

m4_8 = "
data{
    int N;
    real xbar;
    vector[N] height;
    vector[N] weight;
}
parameters{
    real alpha;
    real beta;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta ~ normal( 0 , 1 );
    alpha ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = alpha + beta * (weight[i] - xbar);
    }
    height ~ normal( mu , sigma );
}
";

md"##### Define the SampleModel."

begin
	m4_8s = SampleModel("weights", m4_8);
	heightsdata = Dict("N" => size(df, 1), "height" => df.height, "weight" => df.weight,
		"xbar" => mean(df.weight));
	rc = stan_sample(m4_8s, data=heightsdata);
end;

rethinking = "
        mean   sd   5.5%  94.5%
a     154.60 0.27 154.17 155.03
b       0.90 0.04   0.84   0.97
sigma   5.07 0.19   4.77   5.38
";

if success(rc)
	sdf = read_summary(m4_8s)
end

md"### Snippet 4.53 - 4.56"

begin
	dfa = read_samples(m4_8s; output_format=:dataframe)
	mu_range = 30:1:60
	xbar = mean(df[:, :weight])
	mu = link(dfa, [:alpha, :beta], mu_range, xbar);

	q = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	q[1] = plot(xlab="weight", ylab="height")
	for (indx, mu_val) in enumerate(mu_range)
		for j in 1:length(mu_range)
			scatter!(q[1], [mu_val], [mu[indx][j]], markersize=3, leg=false, color=:lightblue)
		end
	end

	mu_range = 30:0.1:60
	xbar = mean(df[:, :weight])
	mu = link(dfa, [:alpha, :beta], mu_range, xbar);
	q[2] = plot(xlab="weight", ylab="height", legend=:topleft)
	scatter!(q[2], df[:, :weight], df[:, :height], markersize=2, lab="Observations")
	for (ind, m) in enumerate(mu_range)
		plot!(q[2], [m, m], quantile(mu[ind], [0.055, 0.945]), color=:grey, leg=false)
	end
	plot!(q[2], mu_range, [mean(mu[i]) for i in 1:length(mu_range)], color=:red, lab="Means of mu")
end

plot(q..., layout=(2,1))

md"## End of clip-04-53-58s.jl"

