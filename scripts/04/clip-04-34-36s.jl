
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-34-36s.jl"

md"### Snippet 4.26"

begin
	df = CSV.read(sr_datadir("..", "data", "Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

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
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

md"### Snippet 4.31"

m4_1s = SampleModel("m4_1", m4_1);

m4_1_data = Dict("N" => length(df.height), "h" => df.height);

rc4_1s = stan_sample(m4_1s, data=m4_1_data);

if success(rc4_1s)
	part4_1s = read_samples(m4_1s; output_format=:particles)
end

md"##### Stan quap estimate."

begin
  dfa4_1s = read_samples(m4_1s; output_format=:dataframe)
  quap4_1s = quap(dfa4_1s)
end

md"##### Check equivalence of Stan samples and Particles."

begin
	mu_range = 152.0:0.01:157.0
	plot(mu_range, ecdf(sample(dfa4_1s.mu, 10000))(mu_range),
		xlabel="ecdf", ylabel="mu", lab="Stan samples")
end

md"##### Sampling from quap result:"

quap4_1s

begin
	d = Normal(mean(quap4_1s.mu), std(quap4_1s.mu))
	plot!(mu_range, ecdf(rand(d, 10000))(mu_range), lab="Quap samples")
	plot!(mu_range, ecdf(sample(dfa4_1s.mu, 10000))(mu_range), lab="Particles samples")
end

begin
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
end

plot(figs..., layout=(2,1))

md"## End of clip-04-34-36s.jl"

