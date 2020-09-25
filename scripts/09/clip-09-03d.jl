
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using DynamicHMC, Parameters
	using TransformVariables, LogDensityProblems
	using StatisticalRethinking 
end

md"## Clip-09-03d.jl"

md"### snippet 9.3"

md"##### Construct the logdensity problem."

struct clip_9_3_model{TY <: AbstractVector, TX <: AbstractVector}
    "Observations."
    y::TY
    "Covariate"
    x::TX
end

md"##### Make the type callable with the parameters *as a single argument*."

function (problem:: clip_9_3_model)(θ)
    @unpack y, x, = problem    # extract the data
    @unpack muy, mux = θ     # works on the named tuple too
    ll = 0.0
    ll += loglikelihood(Normal(mux, 1), x)
    ll += loglikelihood(Normal(muy, 1), y)
    ll += logpdf(Normal(0, 1), mux) 
    ll += logpdf(Normal(0, 1), muy)
    ll
end

md"##### Instantiate the model with data and inits."

begin
	Random.seed!(1234591)
	N = 100
	x = rand(Normal(0, 1), N)
	y = rand(Normal(0, 1), N)

	p = clip_9_3_model(y, x)
	θ = (muy = 0.0, mux=0.0)
	p(θ)
end

md"##### Write a function to return properly dimensioned transformation."

problem_transformation(p::clip_9_3_model) = as((muy = asℝ, mux = asℝ))

md"##### Wrap the problem with a transformation, then use Flux for the gradient."

P = TransformedLogDensity(problem_transformation(p), p)

∇P = ADgradient(:ForwardDiff, P)

md"##### Generate and show fig 9.3."

function generate_n_samples(model, grad;
  epsilon = 0.03,						# Step size
  L = 11,								# No of leapfrog steps
  pr = 0.3,								# Plot range
  n_samples = 4,						# No of samples
  q = [-0.1, 0.2])						# Initial position
  
  fig = plot(ylab="muy", xlab="mux", xlim=(-pr, pr), ylim=(-pr, pr), leg=false)
  
  for i in 1:n_samples
    q, ptraj, qtraj, accept, dH = StatisticalRethinking.HMC(model, grad, 0.03, 11, q)
    if n_samples < 10
      for j in 1:L
        K0 = sum(ptraj[j, :] .^ 2) / 2
        plot!(fig, [qtraj[j, 1], qtraj[j+1, 1]], [qtraj[j, 2], qtraj[j+1, 2]], leg=false)
        scatter!(fig, [(qtraj[j, 1], qtraj[j, 2])])
      end
    end
  end
  fig
end

generate_n_samples(p, ∇P; pr=0.5)

md"## End of clip-09-03d.jl"

