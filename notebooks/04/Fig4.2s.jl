### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 13b6e1dc-fb53-11ea-18a2-8b51ab59c52e
using Pkg, DrWatson

# ╔═╡ 13b72444-fb53-11ea-0ad1-f33e398484ec
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 4afd8eee-fb52-11ea-1228-91d8e5f03e57
md"## Fig4.2s.jl"

# ╔═╡ 13b7a96e-fb53-11ea-1bf4-23a3a36b9355
md"### snippet 4.1"

# ╔═╡ 13c3d8ce-fb53-11ea-04eb-8b2bc020e907
begin
	noofsteps = 20
	noofwalks = 15
	pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks))
	pos[1, :] = zeros(noofwalks)
	csum = cumsum(pos, dims=1)
end;

# ╔═╡ 13c4702c-fb53-11ea-39da-5dd2ba3cf37f
md"##### Plot and annotate the random walks."

# ╔═╡ 13d118a4-fb53-11ea-3052-fd14f1273273
begin
	f = Plots.font("DejaVu Sans", 6)
	xtick_pos = [5, 9, 17]
	xtick_labels = ("step 4","step 8","step 16")
	fig1 = plot(csum, leg=false, xticks=(xtick_pos,xtick_labels), 
		title="No of random walks = $(noofwalks)")
	plot!(fig1, csum[:, Int(floor(noofwalks/2))], leg=false, color=:black)
	for (i, tick_pos) in enumerate(xtick_pos)
		plot!(fig1, [tick_pos], seriestype="vline")
	end
	fig1
end

# ╔═╡ 13d28e82-fb53-11ea-1726-d19e2a45aea5
md"##### Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)."

# ╔═╡ 13dcc224-fb53-11ea-2baa-2f3bd271bac3
begin
	fig2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3)
	plt = 1
	for step in [4, 8, 16]
	  indx = step + 1 # We aadded the first line of zeros
	  global plt
	  fitl = fit_mle(Normal, csum[indx, :])
	  lx = (fitl.μ-4*fitl.σ):0.01:(fitl.μ+4*fitl.σ)
	  fig2[plt] = density(csum[indx, :], legend=false, title="$(step) steps")
	  plot!( fig2[plt], lx, pdf.(Normal( fitl.μ , fitl.σ ) , lx ), fill=(0, .5,:orange))
	  plt += 1
	end
	fig3 = plot(fig2..., layout=(1, 3))
end

# ╔═╡ 13e45362-fb53-11ea-11f1-7f4d86390826
plot(fig1, fig3, layout=(2,1))

# ╔═╡ 13e4e4c4-fb53-11ea-11af-332dabba1e3e
md"## End of Fig4.2.s.jl"

# ╔═╡ Cell order:
# ╟─4afd8eee-fb52-11ea-1228-91d8e5f03e57
# ╠═13b6e1dc-fb53-11ea-18a2-8b51ab59c52e
# ╠═13b72444-fb53-11ea-0ad1-f33e398484ec
# ╟─13b7a96e-fb53-11ea-1bf4-23a3a36b9355
# ╠═13c3d8ce-fb53-11ea-04eb-8b2bc020e907
# ╟─13c4702c-fb53-11ea-39da-5dd2ba3cf37f
# ╠═13d118a4-fb53-11ea-3052-fd14f1273273
# ╟─13d28e82-fb53-11ea-1726-d19e2a45aea5
# ╠═13dcc224-fb53-11ea-2baa-2f3bd271bac3
# ╠═13e45362-fb53-11ea-11f1-7f4d86390826
# ╟─13e4e4c4-fb53-11ea-11af-332dabba1e3e
