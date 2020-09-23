
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
end

md"### Snippet 4.27"

heightsmodel = "
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

sm = SampleModel("heights", heightsmodel);

heightsdata = Dict("N" => length(df.height), "h" => df.height);

rc = stan_sample(sm, data=heightsdata);

if success(rc)

	# Array od DataFrames, 1 Dataframe/chain
	
	dfas = read_samples(sm; output_format=:dataframes)
	plts = Vector{Plots.Plot{Plots.GRBackend}}(undef, size(dfas[1], 2))

	for (indx, par) in enumerate(names(dfas[1]))
		for i in 1:size(dfas,1)
			if i == 1
				plts[indx] = plot()
			end
			e = ecdf(dfas[i][:, par])
			r = range(minimum(e), stop=maximum(e), length=length(e.sorted_values))
			plts[indx] = plot!(plts[indx], r, e(r), lab = "ECDF $(par) in chain $i")
		end
	end
	plot(plts..., layout=(2,1))
end

success(rc) && (p = read_samples(sm; output_format=:particles))

md"### Snippet 4.28 & 4.29"

begin
	
	# Append all chains in a single DataFrame

	dfa = read_samples(sm; output_format=:dataframe)
	
	# Stan quap estimate
	
	q = quap(dfa)
end

md"### Snippet 4.30"

md"##### If required, starting values can be passed in to `stan_sample()`.
Open `Live docs` and click on `stan_sample` in a cell."

md"# End of clip-04-26-30s.jl"

