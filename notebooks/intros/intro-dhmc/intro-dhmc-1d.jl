### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 33616748-f796-11ea-1c1d-2dae00de8c6e
using Pkg, DrWatson

# ╔═╡ 33619e36-f796-11ea-0b36-bda68b9a5e2f
begin
	@quickactivate "StatisticalRethinkingStan"
	using Random, DynamicHMC, Distributions
	using TransformVariables, LogDensityProblems
	using StatisticalRethinking
end

# ╔═╡ 97cf3b66-f795-11ea-18b2-d9e9689a0b20
md"# Intro-dhmc-1d.jl"

# ╔═╡ 336211e8-f796-11ea-3d91-fbe93bfeafb3
md"### snippet 9.3"

# ╔═╡ 33705476-f796-11ea-0972-edddcf5fc6de
md"##### Construct the logdensity problem."

# ╔═╡ 3370fc94-f796-11ea-02d3-1f9c5c37c18f
struct clip_9_3_model{TY <: AbstractVector, TX <: AbstractVector}
    "Observations."
    y::TY
    "Covariate"
    x::TX
end

# ╔═╡ 337c7ccc-f796-11ea-372d-03b0e499af83
md"##### Make the type callable with the parameters *as a single argument*."

# ╔═╡ 337d0f3e-f796-11ea-1afe-978a61c7cf51
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

# ╔═╡ 3387db1c-f796-11ea-3c9b-912fb0729b97
md"##### Instantiate the model with data and inits."

# ╔═╡ 33888ca4-f796-11ea-3137-cf3d79ddeb9b
Random.seed!(1234591);

# ╔═╡ c40363d8-f7c2-11ea-33ab-bdf7b5f51496
d = rand(Normal(0,1), 10)

# ╔═╡ 3394ced0-f796-11ea-026a-c5e2f92cd86c
begin
	N = 100
	x = rand(Normal(0, 1), N)
	y = rand(Normal(0, 1), N)

	p = clip_9_3_model(y, x)
	θ = (muy = 0.0, mux=0.0)
	p(θ)
end;

# ╔═╡ 339bdb26-f796-11ea-263a-c52b4b4acce2
md"##### Write a function to return properly dimensioned transformation."

# ╔═╡ 339d8368-f796-11ea-28d5-cf374f141754
problem_transformation(p::clip_9_3_model) =
    as((muy = asℝ, mux = asℝ));

# ╔═╡ 33aa58b8-f796-11ea-0f79-173450a7276c
md"##### Wrap the problem with a transformation, then use Flux for the gradient."

# ╔═╡ 33abb8a2-f796-11ea-3bc9-319850bbeb9b
begin
	P = TransformedLogDensity(problem_transformation(p), p)
	∇P = ADgradient(:ForwardDiff, P);
end

# ╔═╡ 33b2a428-f796-11ea-01e4-93e8d05c759d
md"##### Generate and show fig 9.3."

# ╔═╡ 33bb5ece-f796-11ea-1ed2-1f9c93c1c9ac
function generate_n_samples(model, grad;
  epsilon = 0.03, # Step size
  L = 11, # No of leapfrog steps
  pr = 0.3, # Plot range
  n_samples = 4, # No of samples
  q = [-0.1, 0.2]) # Initial position
  
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

# ╔═╡ 33c2b99e-f796-11ea-0fde-89c09665dda0
fig = generate_n_samples(p, ∇P; pr=0.5)

# ╔═╡ 33cbd4ac-f796-11ea-2dbe-510c35a57460
md"## End of clip-09-03d.jl"

# ╔═╡ Cell order:
# ╟─97cf3b66-f795-11ea-18b2-d9e9689a0b20
# ╠═33616748-f796-11ea-1c1d-2dae00de8c6e
# ╠═33619e36-f796-11ea-0b36-bda68b9a5e2f
# ╟─336211e8-f796-11ea-3d91-fbe93bfeafb3
# ╟─33705476-f796-11ea-0972-edddcf5fc6de
# ╠═3370fc94-f796-11ea-02d3-1f9c5c37c18f
# ╟─337c7ccc-f796-11ea-372d-03b0e499af83
# ╠═337d0f3e-f796-11ea-1afe-978a61c7cf51
# ╟─3387db1c-f796-11ea-3c9b-912fb0729b97
# ╠═33888ca4-f796-11ea-3137-cf3d79ddeb9b
# ╠═c40363d8-f7c2-11ea-33ab-bdf7b5f51496
# ╠═3394ced0-f796-11ea-026a-c5e2f92cd86c
# ╟─339bdb26-f796-11ea-263a-c52b4b4acce2
# ╠═339d8368-f796-11ea-28d5-cf374f141754
# ╟─33aa58b8-f796-11ea-0f79-173450a7276c
# ╠═33abb8a2-f796-11ea-3bc9-319850bbeb9b
# ╟─33b2a428-f796-11ea-01e4-93e8d05c759d
# ╠═33bb5ece-f796-11ea-1ed2-1f9c93c1c9ac
# ╠═33c2b99e-f796-11ea-0fde-89c09665dda0
# ╟─33cbd4ac-f796-11ea-2dbe-510c35a57460
