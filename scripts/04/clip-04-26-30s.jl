
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-26-30s.jl"

md"### Snippet 4.26"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

md"### Snippet 4.27"

stan4_1 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform(0 , 50);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

md"### Snippet 4.28 & 4.29"

 md"##### Quadratic approximation vs. Stan samples vs. Normal distribution."

begin
	m4_1_data = Dict("N" => length(df.height), "h" => df.height)
	m4_1_init = Dict(:mu => 180.0, :sigma => 10.0)
	q4_1s, m4_1s, om = quap("m4_1_s", stan4_1; data=m4_1_data, init=m4_1_init)
	quap4_1s_df = sample(q4_1s)
	PRECIS(quap4_1s_df)
end

begin
	post4_1s_df = read_samples(m4_1s; output_format=:dataframe)
	e = ecdf(post4_1s_df.mu)
	f = ecdf(quap4_1s_df.mu)
	g = ecdf(rand(Normal(mean(post4_1s_df.mu), std(post4_1s_df.mu)), 4000))
	r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
	plot(r, e(r), lab = "ECDF mu (Stan samples)", leg = :bottomright)
	plot!(r, f(r), lab = "ECDF mu (quap approx.)")
	plot!(r, g(r), lab = "ECDF mu (Normal distr.)")
end

md"##### Look at individual chains."

if !isnothing(m4_1s)

	# Array of DataFrames, 1 Dataframe/chain
	
	dfs4_1s = read_samples(m4_1s; output_format=:dataframes)
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, size(dfs4_1s[1], 2))

	for (indx, par) in enumerate(names(dfs4_1s[1]))
		for i in 1:size(dfs4_1s,1)
			if i == 1
				figs[indx] = plot()
			end
			e = ecdf(dfs4_1s[i][:, par])
			r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
			figs[indx] = plot!(figs[indx], r, e(r), lab = "ECDF $(par) in chain $i")
		end
	end
	plot(figs..., layout=(2,1))
end

md"##### Particle summary."

if !isnothing(m4_1s)
	part4_1s = read_samples(m4_1s; output_format=:particles)
end

md"# End of clip-04-26-30s.jl"

