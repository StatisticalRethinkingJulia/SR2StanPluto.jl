
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-59-63s.jl"

md"### Preliminary snippets."

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	scale!(df, [:height, :weight])
end;

md"##### Define the Stan language model."

weightsmodel = "
data{
    int N;
    real xbar;
    vector[N] height;
    vector[N] weight;
}
parameters{
    real a;
    real b;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    b ~ normal( 0 , 1 );
    a ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = a + b * weight[i];
    }
    height ~ normal( mu , sigma );
}
";

md"##### Define the SampleModel, input data and samples."

begin
	sm = SampleModel("weights", weightsmodel);
	heightsdata = Dict(
	  "N" => size(df, 1), 
	  "height" => df.height_s, 
	  "weight" => df.weight_s,
	  "xbar" => mean(df.weight)
	);
	rc = stan_sample(sm, data=heightsdata)
end;

rethinking = "
        mean   sd   5.5%  94.5%
a     154.60 0.27 154.17 155.03
b       0.90 0.04   0.84   0.97
sigma   5.07 0.19   4.77   5.38
";

if success(rc)
  sdf = read_summary(sm)
end

md"### Snippet 4.53"

begin
	dfs = read_samples(sm; output_format=:dataframe)

	title = "Height vs. Weight, regions are" * "\nshowing 89% of predicted heights (lightgrey)" *
		"\nand 89% hpd interval around the mean line (darkgrey)"
	plotbounds(
		df, :weight, :height,
		dfs, [:a, :b, :sigma];
		bounds=[:predicted, :hpdi],
		#fig=plotsdir("04", "Fig-56-63.png"),
		title=title,
		colors=[:lightblue, :darkgrey]
	)
end

md"## End of clip-04-53-58s.jl"

