
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig2.7s.jl"

begin
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
	N = [5, 20, 50]

	for i in 1:3                                         # Decrease p_grip step size
		p_grid = range( 0 , stop=1 , length=N[i] )
		prior = pdf.(Uniform(0, 1), p_grid)
		likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid]
		post = (prior .* likelihood) / sum(prior .* likelihood)
		figs[i] = plot(p_grid, post, leg=false, title="$(N[i]) points")
		figs[i] = scatter!(p_grid, post, leg=false)
	end
end

plot(figs..., layout=(1, 3))

md"## End of Fig2.7s.jl"

