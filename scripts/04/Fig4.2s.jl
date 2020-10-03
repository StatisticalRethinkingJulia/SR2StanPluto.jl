
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Fig4.2s.jl"

md"### snippet 4.1"

begin
	noofsteps = 20
	noofwalks = 15
	pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks))
	pos[1, :] = zeros(noofwalks)
	csum = cumsum(pos, dims=1)
end;

md"##### Plot and annotate the random walks."

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

md"##### Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)."

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

plot(fig1, fig3, layout=(2,1))

md"## End of Fig4.2.s.jl"

