
using Markdown
using InteractiveUtils

using DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Clip-04-06s.jl"

md"## snippet 4.6"

md"###### Grid of 1001 steps."

p_grid = range(0, step=0.001, stop=1);

md"###### All priors = 1.0."

prior = ones(length(p_grid));

md"###### Binomial pdf."

likelihood = [pdf(Binomial(9, p), 6) for p in p_grid];

md"###### A Uniform prior has been used, unstandardized posterior is equal to likelihood."

posterior = likelihood .* prior;

md"###### Scale posterior such that they become probabilities."

posterior2 = posterior / sum(posterior);

md"###### Sample using the computed posterior values as weights. In this example we keep the number of samples equal to the length of p_grid, but that is not required."

begin
	samples = sample(p_grid, Weights(posterior), length(p_grid));
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	figs[1] = scatter(1:length(p_grid), samples, markersize = 2, ylim=(0.0, 1.3), lab="Draws")
end

md"###### Analytical calculation."

begin
	w = 6
	n = 9
	x = 0:0.01:1
	figs[2] = density(samples, ylim=(0.0, 3.0), lab="Sample density", leg=:topleft)
	figs[2] = plot!( x, pdf.(Beta( w+1 , n-w+1 ) , x ), lab="Conjugate solution")
end

md"###### Quadratic approximation."

begin
	figs[2] = density(samples, ylim=(0.0, 4.0), lab="Sample density")
	figs[2] = plot!( x, pdf.(Beta( w+1 , n-w+1 ) , x ), lab="Conjugate solution", leg=:topright)

	plot!( figs[2], x, pdf.(Normal( 0.67 , 0.16 ) , x ), lab="Normal approximation",
		fill=(0, .5,:orange))
	plot(figs..., layout=(1, 2))
end

md"## End of clip-04-06s.jl"

