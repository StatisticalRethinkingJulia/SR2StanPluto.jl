
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-26-30s.jl"

md"### Snippet 4.26"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

md"### Snippet 4.27"

m4_1 = "
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

begin
	m4_1s = SampleModel("m4_1s", m4_1)
	m4_1_data = Dict("N" => length(df.height), "h" => df.height)
	rc4_1s = stan_sample(m4_1s, data=m4_1_data)
end;

if success(rc4_1s)

	# Array od DataFrames, 1 Dataframe/chain
	
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

success(rc4_1s) && (part4_1s = read_samples(m4_1s; output_format=:particles))

md"### Snippet 4.28 & 4.29"

begin
	q4_1s = quap(m4_1s)
	quap4_1s = sample(q4_1s)
	Text(precis(quap4_1s; io=String))
end

md"# End of clip-04-26-30s.jl"

