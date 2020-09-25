### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 66368ab4-ff5b-11ea-11f4-ad34524aa659
using Pkg, DrWatson

# ╔═╡ 6636c524-ff5b-11ea-1cdc-458faf68f551
begin
	@quickactivate "StatisticalRethinkingStan"
	using DynamicHMC, Parameters
	using TransformVariables, LogDensityProblems
	using StatisticalRethinking 
end

# ╔═╡ 47f3e088-ff5b-11ea-033f-573e13956713
md"## Clip-09-03d.jl"

# ╔═╡ 66374e18-ff5b-11ea-3e4f-ed01da7ccf4f
md"### snippet 9.3"

# ╔═╡ 663dfcfe-ff5b-11ea-30f3-d7ce1a69f351
md"##### Construct the logdensity problem."

# ╔═╡ 664fa592-ff5b-11ea-1852-13135de62837
struct clip_9_3_model{TY <: AbstractVector, TX <: AbstractVector}
    "Observations."
    y::TY
    "Covariate"
    x::TX
end

# ╔═╡ 66506f7e-ff5b-11ea-2b80-0d40b56d40df
md"##### Make the type callable with the parameters *as a single argument*."

# ╔═╡ 665ba830-ff5b-11ea-3483-07fccf403fe4
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

# ╔═╡ 2c21e464-ff5a-11ea-1786-81348a9bd7c3
md"##### Instantiate the model with data and inits."

# ╔═╡ 814aae02-ff5b-11ea-2551-4ddbc8cc7290
begin
	Random.seed!(1234591)
	N = 100
	x = rand(Normal(0, 1), N)
	y = rand(Normal(0, 1), N)

	p = clip_9_3_model(y, x)
	θ = (muy = 0.0, mux=0.0)
	p(θ)
end

# ╔═╡ 814aefd4-ff5b-11ea-17b7-094af36740c3
md"##### Write a function to return properly dimensioned transformation."

# ╔═╡ 814b731e-ff5b-11ea-2fc4-9d3b3a48e82a
problem_transformation(p::clip_9_3_model) = as((muy = asℝ, mux = asℝ))

# ╔═╡ 815def08-ff5b-11ea-1464-fd9ed7306be7
md"##### Wrap the problem with a transformation, then use Flux for the gradient."

# ╔═╡ 815eade4-ff5b-11ea-3d15-bdaebd138d89
P = TransformedLogDensity(problem_transformation(p), p)

# ╔═╡ 816ac336-ff5b-11ea-0ba8-09a46f99b9b9
∇P = ADgradient(:ForwardDiff, P)

# ╔═╡ 816b7f74-ff5b-11ea-0287-f1c6e72dd350
md"##### Generate and show fig 9.3."

# ╔═╡ 8171f0fc-ff5b-11ea-3b97-2f07c9a9acdc
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

# ╔═╡ 817f7d8c-ff5b-11ea-293d-2b2aad2823b2
generate_n_samples(p, ∇P; pr=0.5)

# ╔═╡ 818812e0-ff5b-11ea-361c-21dfc2292fd3
md"## End of clip-09-03d.jl"

# ╔═╡ Cell order:
# ╟─47f3e088-ff5b-11ea-033f-573e13956713
# ╠═66368ab4-ff5b-11ea-11f4-ad34524aa659
# ╠═6636c524-ff5b-11ea-1cdc-458faf68f551
# ╟─66374e18-ff5b-11ea-3e4f-ed01da7ccf4f
# ╟─663dfcfe-ff5b-11ea-30f3-d7ce1a69f351
# ╠═664fa592-ff5b-11ea-1852-13135de62837
# ╟─66506f7e-ff5b-11ea-2b80-0d40b56d40df
# ╠═665ba830-ff5b-11ea-3483-07fccf403fe4
# ╟─2c21e464-ff5a-11ea-1786-81348a9bd7c3
# ╠═814aae02-ff5b-11ea-2551-4ddbc8cc7290
# ╟─814aefd4-ff5b-11ea-17b7-094af36740c3
# ╠═814b731e-ff5b-11ea-2fc4-9d3b3a48e82a
# ╟─815def08-ff5b-11ea-1464-fd9ed7306be7
# ╠═815eade4-ff5b-11ea-3d15-bdaebd138d89
# ╠═816ac336-ff5b-11ea-0ba8-09a46f99b9b9
# ╟─816b7f74-ff5b-11ea-0287-f1c6e72dd350
# ╠═8171f0fc-ff5b-11ea-3b97-2f07c9a9acdc
# ╠═817f7d8c-ff5b-11ea-293d-2b2aad2823b2
# ╟─818812e0-ff5b-11ea-361c-21dfc2292fd3
