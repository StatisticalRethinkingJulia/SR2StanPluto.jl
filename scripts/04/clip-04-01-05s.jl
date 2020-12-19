
using Markdown
using InteractiveUtils

macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

using DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
	using PlutoUI
end

md"## Clip-04-01-05s.jl"

md"### snippet 4.1"

md"###### No attempt has been made to condense this too fewer lines of code."

@bind noofwalks Slider(5:200, default=9)

begin
	noofsteps = 20;
	pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks));
	pos[1, :] = zeros(noofwalks);
	csum = cumsum(pos, dims=1);
	mx = minimum(csum) * 0.9
end;

md"###### Plot and annotate the random walks."

md"###### Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)."

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

	fig2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3);
	plt = 1
	for step in [4, 8, 16]
		indx = step + 1 								# We added the first line of zeros
		global plt
	  	fitl = fit_mle(Normal, csum[indx, :])
	  	lx = (fitl.μ-4*fitl.σ):0.01:(fitl.μ+4*fitl.σ)
	  	fig2[plt] = density(csum[indx, :], legend=false, title="$(step) steps")
	 	plot!( fig2[plt], lx, pdf.(Normal( fitl.μ , fitl.σ ) , lx ), fill=(0, .5,:orange))
	  	plt += 1
	end
	fig3 = plot(fig2..., layout=(1, 3))
	plot(fig1, fig3, layout=(2,1))
end

md"## snippet 4.2"

prod(1 .+ rand(Uniform(0, 0.1), 12))

md"## snippet 4.3"

begin
	growth = [prod(1 .+ rand(Uniform(0, 0.1), 12)) for i in 1:10000];
	fit2 = fit_mle(Normal, growth)
	plot(Normal(fit2.μ , fit2.σ ), fill=(0, .5,:orange), lab="Normal distribution")
	density!(growth, lab="'sample' distribution")
end

md"## snippet 4.4"

begin
	big = [prod(1 .+ rand(Uniform(0, 0.5), 12)) for i in 1:10000];
	small = [prod(1 .+ rand(Uniform(0, 0.01), 12)) for i in 1:10000];
	fitb = fit_mle(Normal, big)
	fits = fit_mle(Normal, small)
	p5 = plot(Normal(fitb.μ , fitb.σ ), lab="Big normal distribution", fill=(0, .5,:orange))
	p4 = plot(Normal(fits.μ , fits.σ ), lab="Small normal distribution", fill=(0, .5,:orange))
	density!(p5, big, lab="'big' distribution")
	density!(p4, small, lab="'small' distribution")
	plot(p5, p4, layout=(1, 2))
end

md"## snippet 4.5"

begin
	log_big = [log(prod(1 .+ rand(Uniform(0, 0.5), 12))) for i in 1:10000];
	fit3 = fit_mle(Normal, log_big)
	plot(Normal(fit3.μ , fit3.σ ), fill=(0, .5,:orange), lab="Normal distribution")
	density!(log_big, lab="'sample' distribution")
end

md"## End of clip-04-01-05s.jl"

