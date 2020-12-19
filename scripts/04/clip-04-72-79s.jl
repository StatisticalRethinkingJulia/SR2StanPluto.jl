
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingTuring"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## clip-04-72-79s"

md"### snippet 4.72"

md"### snippet 4.73"

begin
	df = CSV.read(sr_datadir("cherry_blossoms.csv"), DataFrame; missingstring = "NA")
	df = dropmissing(df, :doy)
end;

scatter(df.year, df.doy, leg=false)

describe(df)

begin
	num_knots = 15
	knot_list = quantile(df.year, range(0, 1, length = num_knots))
	basis = BSplineBasis(4, knot_list)
	B = basismatrix(basis, df.year)
end;

begin
	plot(legend = false, xlabel = "year", ylabel = "basis value")
	for y in eachcol(B)
		plot!(df.year, y)
	end
	plot!()
end

md"## snippet 4.76"

stan4_9 = "
data {
    int n;
    int k;
    int doy[n];
    matrix[n, k] B;
}
parameters {
    real a;
    vector[k] w;
    real<lower=0> sigma;
}
transformed parameters {
    vector[n] mu;
    mu = a + B * w;
}
model {
    for (i in 1:n) {
        doy[i] ~ normal(mu[i], sigma);
    }
    a ~ normal(100, 10);
    w ~ normal(0, 10);
    sigma ~ exponential(1);
}
";

begin
	m4_9s = SampleModel("m4.9s", stan4_9)
	data = Dict(:n => size(B, 1), :k => size(B, 2), :doy => df.doy, :B => B)
	init = Dict(:mu => ones(17) * 100, :sigma => 20.0)
	rc4_9s = stan_sample(m4_9s; data)
	if success(rc4_9s)
		post4_9s_df = read_samples(m4_9s; output_format=:dataframe)
		PRECIS(post4_9s_df)
	end
end

md"### snippet 4.77"

begin
	w_str = ["w.$i" for i in 1:length(basis)]
	post_3 = post4_9s_df[:, ["a"; w_str; "sigma"]]
	w_3 = mean.(eachcol(post_3[:, w_str]))              # either
	w_3 = [mean(post_3[:, col]) for col in w_str]       # or
	plot(legend = false, xlabel = "year", ylabel = "basis * weight")
	for y in eachcol(B .* w_3')
		plot!(df.year, y)
	end
	plot!()
end	

md"### snippet 4.78"

begin
	mu_3 = post_3.a' .+ B * Array(post_3[!, w_str])'
	mu_3 = meanlowerupper(mu_3)
	scatter(df.year, df.doy, alpha = 0.3)
	plot!(df.year, mu_3.mean, ribbon = (mu_3.mean .- mu_3.lower, mu_3.upper .- mu_3.mean))
end

md"## End of clip-04-72-79s.jl"

