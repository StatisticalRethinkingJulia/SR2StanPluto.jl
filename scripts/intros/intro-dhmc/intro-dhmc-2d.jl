
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
  @quickactivate "StatisticalRethinkingStan"
  using DynamicHMC
  using LogDensityProblems, TransformVariables
  using DynamicHMC
  using StatisticalRethinking
end

md"## Intro-dhmc-2d.jl"

md"### snippet 9.3"

md"##### Construct the logdensity problem."

Base.@kwdef mutable struct clip_9_3_1_model{
  TY <: AbstractVector, TX <: AbstractVector}
    "Observations."
    y::TY
    "Covariate"
    x::TX
end

md"##### Write a function to return properly dimensioned transformation."

function make_transformation(model::clip_9_3_1_model)
  as((muy = asℝ, mux = asℝ))
end

md"##### Instantiate the model with data and inits."

Random.seed!(1234591);

begin
	N = 100
	x = rand(Normal(0, 1), N)
	y = rand(Normal(0, 1), N)
	model1 = clip_9_3_1_model(;y=y, x=x)
end

θ = (muy = 0.0, mux=0.0)

md"##### Make the type callable with the parameters *as a single argument*."

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

model1(θ)

md"##### Wrap the problem with a transformation, then use Flux for the gradient."

begin
	P = TransformedLogDensity(make_transformation(model1), model1)
	∇P = ADgradient(:ForwardDiff, P);
end

md"##### Tune and sample."

results = mcmc_with_warmup(Random.GLOBAL_RNG, ∇P, 1000);

md"##### We use the transformation to obtain the posterior from the chain."

posterior = P.transformation.(results.chain)

typeof(posterior)

md"##### Extract the posterior means,"

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

begin
	pnames = ["muy", "mux"]
	sections = Dict(:parameters =>pnames,)
	chn = MCMCChains.Chains(a3d, pnames, sections, start=1)
	CHNS(chn)
end


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

begin
	samples = draw_n_samples(model1, ∇P; n_samples=200);
	mean(samples, dims=1)
end

md"## End of intro-dhmc-2d.jl"

