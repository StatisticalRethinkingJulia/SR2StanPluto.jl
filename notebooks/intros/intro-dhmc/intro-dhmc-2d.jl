### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 9e6dfb4a-f7c4-11ea-0371-03ff747c9f61
using Pkg, DrWatson

# ╔═╡ 9e6e3ad6-f7c4-11ea-0980-81a920a19f14
begin
  @quickactivate "StatisticalRethinkingStan"
  using DynamicHMC
  using LogDensityProblems, TransformVariables
  using DynamicHMC
  using StatisticalRethinking
end

# ╔═╡ f385d68a-f7c3-11ea-3fc2-ad7453c86414
md"## Intro-dhmc-2d.jl"

# ╔═╡ 9e6ec7aa-f7c4-11ea-37b6-c30c9bc9b70b
md"### snippet 9.3"

# ╔═╡ 9e7cb554-f7c4-11ea-3a22-5d7dca89f1ce
md"##### Construct the logdensity problem."

# ╔═╡ 9e7d4954-f7c4-11ea-37ec-a53f2a326de6
Base.@kwdef mutable struct clip_9_3_1_model{
  TY <: AbstractVector, TX <: AbstractVector}
    "Observations."
    y::TY
    "Covariate"
    x::TX
end

# ╔═╡ 9e8a56c8-f7c4-11ea-1b9c-f1874c10c04b
md"##### Write a function to return properly dimensioned transformation."

# ╔═╡ 9e8af36e-f7c4-11ea-0bc2-c770176975d7
function make_transformation(model::clip_9_3_1_model)
  as((muy = asℝ, mux = asℝ))
end

# ╔═╡ 9e97b33e-f7c4-11ea-17f0-cf849e4a1164
md"##### Instantiate the model with data and inits."

# ╔═╡ 9e9ff8c8-f7c4-11ea-1e71-c7f189d3f5ed
Random.seed!(1234591);

# ╔═╡ 9eaa03c4-f7c4-11ea-2b34-89e2f92810cc
begin
	N = 100
	x = rand(Normal(0, 1), N)
	y = rand(Normal(0, 1), N)
	model1 = clip_9_3_1_model(;y=y, x=x)
end

# ╔═╡ 9eac4c1c-f7c4-11ea-1fd4-4573a58933a7
θ = (muy = 0.0, mux=0.0)

# ╔═╡ 9ebc38fa-f7c4-11ea-2456-933dc993b6ab
md"##### Make the type callable with the parameters *as a single argument*."

# ╔═╡ 9ebe4348-f7c4-11ea-1ac0-8dd4036acfef
function (model:: clip_9_3_1_model)(θ)
    @unpack y, x, = model    # extract the data
    @unpack muy, mux = θ     # works on the named tuple too
    ll = 0.0
    ll += loglikelihood(Normal(mux, 1), x)
    ll += loglikelihood(Normal(muy, 1), y)
    ll += logpdf(Normal(0, 1), mux) 
    ll += logpdf(Normal(0, 1), muy)
    ll
end

# ╔═╡ 9ec7d1e4-f7c4-11ea-0c8a-e36dbaa21dd7
model1(θ)

# ╔═╡ 9ed0a3c6-f7c4-11ea-1857-1bfa81bb165b
md"##### Wrap the problem with a transformation, then use Flux for the gradient."

# ╔═╡ 9edac1f8-f7c4-11ea-2964-b56a3c28fb3c
begin
	P = TransformedLogDensity(make_transformation(model1), model1)
	∇P = ADgradient(:ForwardDiff, P);
end

# ╔═╡ 9ee47d1a-f7c4-11ea-0353-157e1b36e02e
md"##### Tune and sample."

# ╔═╡ 9eecc290-f7c4-11ea-101e-0d4097815b8f
results = mcmc_with_warmup(Random.GLOBAL_RNG, ∇P, 1000);

# ╔═╡ 9ef6da32-f7c4-11ea-3f73-a5617190ffd2
md"##### We use the transformation to obtain the posterior from the chain."

# ╔═╡ 9effe6ae-f7c4-11ea-19cd-6d79b43b4278
posterior = P.transformation.(results.chain)

# ╔═╡ e3ae2806-2b90-11eb-070f-39ddd6208ccd
typeof(posterior)

# ╔═╡ 9f087fbc-f7c4-11ea-3264-9b235c4757c8
md"##### Extract the posterior means,"

# ╔═╡ 9f145896-f7c4-11ea-1104-b3a151572004
begin
	[mean(first, posterior), mean(last, posterior)]
	a3d = Array{Float64, 3}(undef, 1000, 2, 1)
	for j in 1:1
	  for i in 1:1000
		a3d[i, 1, j] = values(posterior[i].muy)
		a3d[i, 2, j] = values(posterior[i].mux)
	  end
	end
end

# ╔═╡ 9f1eba20-f7c4-11ea-278e-8b535e3f4fe5
begin
	pnames = ["muy", "mux"]
	sections = Dict(:parameters =>pnames,)
	chn = MCMCChains.Chains(a3d, pnames, sections, start=1)
	CHNS(chn)
end

# ╔═╡ 9f282556-f7c4-11ea-2b1d-6d19a869b9bf
# Draw 200 samples:

function draw_n_samples(model, grad;
  epsilon = 0.03, # Step size
  L = 11, # No of leapfrog steps
  n_samples = 1000, # No of samples
  q = [-0.1, 0.2]) # Initial position
  
  samples = zeros(n_samples, 2)
  for i in 1:n_samples
    q, ptraj, qtraj, accept, 
      dH = StatisticalRethinking.HMC(model, grad, 0.03, 11, q)
    samples[i, :] = q
  end
  
  samples
end

# ╔═╡ 9f33c5ca-f7c4-11ea-394c-59b681e11b40
begin
	samples = draw_n_samples(model1, ∇P; n_samples=200);
	mean(samples, dims=1)
end

# ╔═╡ 9f49119e-f7c4-11ea-1d55-dfcf0d3f164a
md"## End of intro-dhmc-2d.jl"

# ╔═╡ Cell order:
# ╟─f385d68a-f7c3-11ea-3fc2-ad7453c86414
# ╠═9e6dfb4a-f7c4-11ea-0371-03ff747c9f61
# ╠═9e6e3ad6-f7c4-11ea-0980-81a920a19f14
# ╟─9e6ec7aa-f7c4-11ea-37b6-c30c9bc9b70b
# ╟─9e7cb554-f7c4-11ea-3a22-5d7dca89f1ce
# ╠═9e7d4954-f7c4-11ea-37ec-a53f2a326de6
# ╟─9e8a56c8-f7c4-11ea-1b9c-f1874c10c04b
# ╠═9e8af36e-f7c4-11ea-0bc2-c770176975d7
# ╟─9e97b33e-f7c4-11ea-17f0-cf849e4a1164
# ╠═9e9ff8c8-f7c4-11ea-1e71-c7f189d3f5ed
# ╠═9eaa03c4-f7c4-11ea-2b34-89e2f92810cc
# ╠═9eac4c1c-f7c4-11ea-1fd4-4573a58933a7
# ╠═9ebc38fa-f7c4-11ea-2456-933dc993b6ab
# ╠═9ebe4348-f7c4-11ea-1ac0-8dd4036acfef
# ╠═9ec7d1e4-f7c4-11ea-0c8a-e36dbaa21dd7
# ╟─9ed0a3c6-f7c4-11ea-1857-1bfa81bb165b
# ╠═9edac1f8-f7c4-11ea-2964-b56a3c28fb3c
# ╟─9ee47d1a-f7c4-11ea-0353-157e1b36e02e
# ╠═9eecc290-f7c4-11ea-101e-0d4097815b8f
# ╠═9ef6da32-f7c4-11ea-3f73-a5617190ffd2
# ╠═9effe6ae-f7c4-11ea-19cd-6d79b43b4278
# ╠═e3ae2806-2b90-11eb-070f-39ddd6208ccd
# ╠═9f087fbc-f7c4-11ea-3264-9b235c4757c8
# ╠═9f145896-f7c4-11ea-1104-b3a151572004
# ╠═9f1eba20-f7c4-11ea-278e-8b535e3f4fe5
# ╠═9f282556-f7c4-11ea-2b1d-6d19a869b9bf
# ╠═9f33c5ca-f7c4-11ea-394c-59b681e11b40
# ╟─9f49119e-f7c4-11ea-1d55-dfcf0d3f164a
