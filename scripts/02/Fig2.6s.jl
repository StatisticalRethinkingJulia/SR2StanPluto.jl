
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Fig2.6s.jl"

md"##### Define a grid."

begin
	N = 201
	p_grid = range( 0 , stop=1 , length=N)
end;

md"##### Define three priors."

begin
	prior = []
	append!(prior, [pdf.(Uniform(0, 1), p_grid)])
	append!(prior, [[p < 0.5 ? 0 : 1 for p in p_grid]])
	append!(prior, [[exp( -5*abs( p - 0.5 ) ) for p in p_grid]])
	likelihood = pdf.(Binomial.(9, p_grid), 6)
end;

figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 9);

for i in 1:3
  j = (i-1)*3 + 1
  figs[j] = plot(p_grid, prior[i], leg=false, ylims=(0, 1), title="Prior")
  figs[j+1] = plot(p_grid, likelihood, leg=false, title="Likelihood")
  figs[j+2] = plot(p_grid, prior[i].*likelihood, leg=false, title="Posterior")
end

plot(figs..., layout=(3, 3))

md"## End of Fig2.6s.jl"

