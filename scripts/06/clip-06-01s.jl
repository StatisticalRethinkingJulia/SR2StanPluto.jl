
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-01s.jl"

begin
	N = 200
	prob = 0.1

	df = DataFrame(
	  nw = rand(Normal(), N),
	  tw = rand(Normal(), N)
	)
	df.s = df.tw + df.nw
	scale!(df, [:s, :nw, :tw])

	q = quantile(df.s, 1-prob)

	selected_df = filter(row -> row.s > q, df)
	unselected_df = filter(row -> row.s <= q, df)

	cor(selected_df.nw, selected_df.tw)
end

m6_0 = "
data {
  int <lower=1> N;
  vector[N] nw;
  vector[N] tw;
}
parameters {
  real a;
  real aS;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + aS * nw;
  a ~ normal(0, 5.0);
  aS ~ normal(0, 1.0);
  sigma ~ exponential(1);
  tw ~ normal(mu, sigma);
}
";

begin
	m6_0s = SampleModel("m6.0s", m6_0)
	m_6_0_data = Dict(
	  :nw => selected_df.nw_s,
	  :tw => selected_df.tw_s,
	  :N => size(selected_df, 1)
	)
	rc6_0s = stan_sample(m6_0s, data=m_6_0_data)
	success(rc6_0s) && (part6_0s = read_samples(m6_0s, output_format=:particles))
end

if success(rc6_0s)
  x = -2.0:0.01:3.0
  plot(xlabel="newsworthiness", ylabel="trustworthiness",
    title="Science distortion")
  scatter!(selected_df[:, :nw], selected_df[:, :tw], color=:blue, lab="selected")
  scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, lab="unselected")
  plot!(x, mean(part6_0s.a) .+ mean(part6_0s.aS) .* x, lab="Regression line")
end

if success(rc6_0s)
  dfa6_0s = read_samples(m6_0s, output_format=:dataframe)
  fig1 = plotbounds(df, :nw, :tw, dfa6_0s , [:a, :aS, :sigma])
  scatter!(unselected_df[:, :nw], unselected_df[:, :tw], color=:lightgrey, lab="unselected")
end

md"## End of clip-06-01s.jl"

