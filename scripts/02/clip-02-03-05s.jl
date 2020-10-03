
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Clip-02-03-05s.jl"

md"### snippet 2.3"

md"###### Define a grid."

begin
	grid_length = 201
	p_grid = range( 0 , stop=1 , length=grid_length )
end;

md"### snippet 2.4"

begin
	figs1 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
	N = [5, 20, 50]

	for i in 1:3                                         # Decrease p_grip step size
		p_grid = range( 0 , stop=1 , length=N[i] )
		prior = pdf.(Uniform(0, 1), p_grid)
		likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid]
		post = (prior .* likelihood) / sum(prior .* likelihood)
		figs1[i] = plot(p_grid, post, leg=false, title="$(N[i]) points")
		figs1[i] = scatter!(p_grid, post, leg=false)
	end
end

plot(figs1..., layout=(1,3))

md"### snippet 2.5"

md"###### Compare three priors (Fig 2.7)."

begin
	prior = []
	append!(prior, [pdf.(Uniform(0, 1), p_grid)])
	append!(prior, [[p < 0.5 ? 0 : 1 for p in p_grid]])
	append!(prior, [[exp( -5*abs( p - 0.5 ) ) for p in p_grid]])
end;

likelihood = [pdf.(Binomial(9, p), 6) for p in p_grid];

begin
	figs2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9)
	for i in 1:3
  		j = (i-1)*3 + 1
  		figs2[j] = plot(p_grid, prior[i], leg=false, ylims=(0, 1), title="Prior")
  		figs2[j+1] = plot(p_grid, likelihood, leg=false, title="Likelihood")
  		figs2[j+2] = plot(p_grid, prior[i].*likelihood, leg=false, title="Posterior")
	end
	plot(figs2..., layout=(3, 3))
end

md"## End of clip-02-03-05s.jl"

