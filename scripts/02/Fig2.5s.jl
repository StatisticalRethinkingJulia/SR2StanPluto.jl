
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig 2.5s"

md"##### This clip is only intended to generate Fig 2.5. It is not intended to show how to use Stan!"

m2_0 = "
// Inferring a rate
data {
  int n;
  int k;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

md"##### Create a SampleModel object:"

m2_0s = SampleModel("m2.0s", m2_0);

md"##### In below loop, n will go from 1:9"

begin
	k = [1,0,1,1,1,0,1,0,1]               # Sequence actually observed is in k[1:n]
	x = range(0, stop=9, length=10)
end;

begin
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
	dens = Vector{DataFrame}(undef, 10)
	for n in 1:9

		figs[n] = plot(xlims=(0.0, 1.0), ylims=(0.0, 3.0), leg=false)
		m2_0_data = Dict("n" => n, "k" => sum(k[1:n]));
		rc = stan_sample(m2_0s, data=m2_0_data);
		dfs = read_samples(m2_0s; output_format=:dataframe)
		if n == 1
			hline!([1.0], line=(:dash))
		else
			density!(dens[n][:, :theta], line=(:dash))
		end
		density!(dfs[:, :theta])
		dens[n+1] = dfs

	end
end

plot(figs..., layout=(3, 3))

md"## End of Fig2.5s.jl"

