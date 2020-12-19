
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
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

stan4_8 = "
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
	data = Dict(:N => size(df, 1), :height => df.height, :weight => df.weight, :xbar => mean(df.weight));
	init = Dict(:alpha => 170.0, :beta => 2.0, :sigma => 10.0)
	q4_8s, m4_8s, _ = quap("m4.8s", stan4_8; data, init)
	quap4_8s_df = sample(q4_8s)
	PRECIS(quap4_8s_df)
end

rethinking = "
           mean     sd     5.5%    94.5%
alpha     154.60   0.27  154.17   155.03
beta       0.90    0.04    0.84     0.97
sigma      5.07    0.19    4.77     5.38
";

if !isnothing(m4_8s)
	sdf4_8s = read_summary(m4_8s)
end

md"### Snippet 4.53 - 4.56"

begin
	mu_range = 30:1:60
	xbar = mean(df[:, :weight])
	mu = link(quap4_8s_df, [:alpha, :beta], mu_range, xbar);

	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	figs[1] = plot(xlab="weight", ylab="height")
	title!(figs[1], "Predictions mu | weight")
	scatter!(figs[1], df[:, :weight], df[:, :height], markersize=2, lab="Observations")
	for (indx, mu_val) in enumerate(mu_range)
		for j in 1:length(mu_range)
			scatter!(figs[1], [mu_val], [mu[indx][j]], markersize=1, leg=false, color=:lightblue)
		end
	end
	figs[1]
end

begin
	figs[2] = plot(xlab="weight", ylab="height", legend=:topleft)
	title!(figs[2], "89% Compatibility interval mu")
	scatter!(figs[2], df[:, :weight], df[:, :height], markersize=2, lab="Observations")
	for (ind, m) in enumerate(mu_range)
		plot!(figs[2], [m, m], quantile(mu[ind], [0.055, 0.945]), color=:grey, leg=false)
	end
	plot!(figs[2], mu_range, [mean(mu[i]) for i in 1:length(mu_range)], color=:red, lab="Means of mu")
end

begin
	nms = string.(q4_8s.params)
	covm = NamedArray(Matrix(q4_8s.vcov), (nms, nms), ("Rows", "Cols"))
	covm
end 

begin
	μ = [q4_8s.coef...][1:2]
	Σ = q4_8s.vcov[1:2, 1:2]
    covellipse(μ, Σ; showaxes=true, n_std=1, n_ellipse_vertices=100, lab="q4_8s vcov")
end

q4_8s.params

md"## End of clip-04-53-58s.jl"

