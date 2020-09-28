### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 9e7c03f0-f771-11ea-37c6-7bb5bdfee6b3
using Pkg, DrWatson

# ╔═╡ 9e7c4612-f771-11ea-18ab-53b0327f84f9
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ da886344-f770-11ea-2dce-c32c5b634485
md"## Fig2.9s.jl"

# ╔═╡ 730ca458-f772-11ea-37b7-3b1c57b1cf3c
md"##### Detailed comparisons between different quap estimates."

# ╔═╡ 9e7cd226-f771-11ea-16ff-5f359383d3df
md"##### Grid of 1001 steps."

# ╔═╡ 9e8b4d24-f771-11ea-13d9-53d4d897b6f9
p_grid = range(0, step=0.001, stop=1);

# ╔═╡ 9e8bebee-f771-11ea-19bb-45a7a7d0d1c7
md"##### Set all priors = 1.0."

# ╔═╡ 9e9831d8-f771-11ea-1f51-0f8f67412b1a
prior = ones(length(p_grid));

# ╔═╡ 9e98c88c-f771-11ea-1b71-6954d845ece0
md"##### Binomial pdf."

# ╔═╡ 9ea43208-f771-11ea-0928-596e88c658ae
likelihood = pdf.(Binomial.(9, p_grid), 6);

# ╔═╡ 9ea4dfbe-f771-11ea-38dc-9f3b1e72cf4c
md"##### As Uniform prior has been used, unstandardized posterior is equal to likelihood."

# ╔═╡ 9eb26684-f771-11ea-2f72-9158a703be12
begin
	posterior = likelihood .* prior
	
	# Scale posterior such that they become probabilities."
	
	posterior = posterior / sum(posterior)
end;

# ╔═╡ 9eca0c1a-f771-11ea-267d-519ccb35777e
md"##### Sample using the computed posterior values as weights."

# ╔═╡ 9ed22960-f771-11ea-03aa-dfe49b859ac9
begin
	N = 10000
	samples = sample(p_grid, Weights(posterior), N);
	chn = MCMCChains.Chains(reshape(samples, N, 1, 1), ["toss"]);
end;

# ╔═╡ 9eda9df2-f771-11ea-2b33-0d04da6b3b8e
md"##### Describe the chain."

# ╔═╡ 9ee2b730-f771-11ea-0cb3-4380b1093306
chn

# ╔═╡ 9ee425c0-f771-11ea-1eec-2966da179664
md"##### Compute the MAP (maximum_a_posteriori) estimate."

# ╔═╡ 9eebf08e-f771-11ea-0b37-e39eae2dfac4
function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), repeat([6], 1))))
  -ll
end

# ╔═╡ 9ef4614c-f771-11ea-1e8f-1d0aa4f1abdf
opt = optimize(loglik, 0.0, 1.0)

# ╔═╡ 9efcc1ac-f771-11ea-0d80-f96d420ba180
qmap = Optim.minimizer(opt)

# ╔═╡ 9f1c1638-f771-11ea-3c94-b7c61d2d946d
md"##### Fit quadratic approximation."

# ╔═╡ 9f1fd692-f771-11ea-20d4-1f85875e38e3
quapfit = [qmap[1], std(samples, mean=qmap[1])]

# ╔═╡ 9f2aa07c-f771-11ea-1725-1134b6105e6a
figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4);

# ╔═╡ 9f3619ca-f771-11ea-24c4-39ec211debfc
md"##### Analytical calculation."

# ╔═╡ 9f405a8e-f771-11ea-2df4-914745947f38
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

# ╔═╡ 9f4b6bae-f771-11ea-0e74-832e38739a30
plot(figs..., layout=(2, 2))

# ╔═╡ 9f55638e-f771-11ea-348b-1b39f9b07e41
md"## End of Fig2.9s.jl"

# ╔═╡ Cell order:
# ╟─da886344-f770-11ea-2dce-c32c5b634485
# ╟─730ca458-f772-11ea-37b7-3b1c57b1cf3c
# ╠═9e7c03f0-f771-11ea-37c6-7bb5bdfee6b3
# ╠═9e7c4612-f771-11ea-18ab-53b0327f84f9
# ╟─9e7cd226-f771-11ea-16ff-5f359383d3df
# ╠═9e8b4d24-f771-11ea-13d9-53d4d897b6f9
# ╟─9e8bebee-f771-11ea-19bb-45a7a7d0d1c7
# ╠═9e9831d8-f771-11ea-1f51-0f8f67412b1a
# ╟─9e98c88c-f771-11ea-1b71-6954d845ece0
# ╠═9ea43208-f771-11ea-0928-596e88c658ae
# ╟─9ea4dfbe-f771-11ea-38dc-9f3b1e72cf4c
# ╠═9eb26684-f771-11ea-2f72-9158a703be12
# ╟─9eca0c1a-f771-11ea-267d-519ccb35777e
# ╠═9ed22960-f771-11ea-03aa-dfe49b859ac9
# ╟─9eda9df2-f771-11ea-2b33-0d04da6b3b8e
# ╠═9ee2b730-f771-11ea-0cb3-4380b1093306
# ╟─9ee425c0-f771-11ea-1eec-2966da179664
# ╠═9eebf08e-f771-11ea-0b37-e39eae2dfac4
# ╠═9ef4614c-f771-11ea-1e8f-1d0aa4f1abdf
# ╠═9efcc1ac-f771-11ea-0d80-f96d420ba180
# ╟─9f1c1638-f771-11ea-3c94-b7c61d2d946d
# ╠═9f1fd692-f771-11ea-20d4-1f85875e38e3
# ╠═9f2aa07c-f771-11ea-1725-1134b6105e6a
# ╟─9f3619ca-f771-11ea-24c4-39ec211debfc
# ╠═9f405a8e-f771-11ea-2df4-914745947f38
# ╠═9f4b6bae-f771-11ea-0e74-832e38739a30
# ╟─9f55638e-f771-11ea-348b-1b39f9b07e41
