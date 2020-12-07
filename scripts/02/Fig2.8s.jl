
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig2.8s.jl"

begin
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
	x = 0:0.01:1

	for (j, i) in enumerate([1, 2, 4])
		  w = i * 6
		  n = i * 9

		  p_grid = range(0, stop=1, length=1000);
		  prior = ones(length(p_grid));
		  likelihood = [pdf(Binomial(n, p), w) for p in p_grid];
		  posterior = likelihood .* prior;
		  posterior = posterior / sum(posterior);

		  N = 10000
		  samples = sample(p_grid, Weights(posterior), N);

		  # Analytical calculation

		  figs[j] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(0.0, 1.0), 
			lab="exact", leg=:topleft, title="n = $n")

		  # Quadratic approximation using StatisticalRethinking.jl quap()

		  df = DataFrame(:toss => samples)
		  q = quap(df)
		  q_df = sample(q)
		  plot!( figs[j], x, pdf.(Normal(mean(q_df.toss), std(q_df.toss) ) , x ),
			lab="quap")
	end
end

plot(figs..., layout=(1, 3))

md"## End of Fig2.8s.jl"

