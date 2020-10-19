
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Fig2.9s.jl"

md"##### Detailed comparisons between different quap estimates."

md"##### Grid of 1001 steps."

p_grid = range(0, step=0.001, stop=1);

md"##### Set all priors = 1.0."

prior = ones(length(p_grid));

md"##### Binomial pdf."

likelihood = pdf.(Binomial.(9, p_grid), 6);

md"##### As Uniform prior has been used, unstandardized posterior is equal to likelihood."

begin
	posterior = likelihood .* prior
	
	# Scale posterior such that they become probabilities."
	
	posterior = posterior / sum(posterior)
end;

md"##### Sample using the computed posterior values as weights."

begin
	N = 10000
	samples = sample(p_grid, Weights(posterior), N);
	chn = MCMCChains.Chains(reshape(samples, N, 1, 1), ["toss"]);
end;

md"##### Describe the chain."

chn

md"##### Compute the MAP (Maximum A Posteriori) estimate."

function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), repeat([6], 1))))
  -ll
end

opt = optimize(loglik, 0.0, 1.0)

qmap = Optim.minimizer(opt)

md"##### Fit quadratic approximation."

quapfit = [qmap[1], std(samples, mean=qmap[1])]

figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4);

md"##### Analytical calculation."

begin
	w = 6
	n = 9
	x = 0:0.01:1
	figs[1] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0), 
	  lab="Conjugate solution", leg=:topleft)
	density!(figs[1], samples, lab="Sample density")

	# Distribution estimates copied from a Turing quap()
	
	d = Normal{Float64}(0.6666666666666666, 0.15713484026367724)

	# quadratic approximation using Optim

	figs[2] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
	  lab="Conjugate solution", leg=:topleft)
	plot!( figs[2], x, pdf.(Normal( quapfit[1], quapfit[2] ) , x ),
	  lab="Optim logpdf approx.")
	plot!(figs[2], x, pdf.(d, x), lab="Turing quap approx.")

	# quadratic approximation using StatisticalRethinking.jl quap()

	df = DataFrame(:toss => samples)
	q = quap(df)
	figs[3] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
	  lab="Conjugate solution", leg=:topleft)
	plot!( figs[3], x, pdf.(Normal(mean(q.toss), std(q.toss) ) , x ),
	  lab="Stan quap approx.")
	plot!(figs[3], x, pdf.(d, x), lab="Turing quap approx.")

	# ### snippet 2.7

	w = 6; n = 9; x = 0:0.01:1
	figs[4] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
	  lab="Conjugate solution", leg=:topleft)
	f = fit(Normal, samples)
	plot!(figs[4], x, pdf.(Normal( f.μ , f.σ ) , x ), lab="Normal MLE approx.")
end

plot(figs..., layout=(2, 2))

md"## End of Fig2.9s.jl"

