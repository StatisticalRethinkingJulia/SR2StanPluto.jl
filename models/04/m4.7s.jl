using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingTuring"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

df = CSV.read(sr_datadir("cherry_blossoms.csv"), DataFrame; missingstring = "NA")
df = dropmissing(df, :doy)

num_knots = 15
knot_list = quantile(df.year, range(0, 1, length = num_knots))
basis = BSplineBasis(4, knot_list)
B = basismatrix(basis, df.year)

stan4_7 = "
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

data = Dict(:n => size(B, 1), :k => size(B, 2), :doy => df.doy, :B => B)
init = Dict(:mu => ones(17) * 100, :sigma => 20.0)
q4_7s, m4_7s, om = quap("m4.7s", stan4_7; data, init)
if !isnothing(q4_7s)
	quap4_7s_df = sample(q4_7s)
	precis(quap4_7s_df)
end

