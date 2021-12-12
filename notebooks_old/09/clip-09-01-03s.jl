### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 34d2b0f6-ff65-11ea-05bc-c1a781f7bd7d
using Pkg, DrWatson

# ╔═╡ 34d2e742-ff65-11ea-35e7-6dba8cede1d5
begin
  using Distributions
  using StatsPlots
  using StatsBase
  using LaTeXStrings
  using CSV
  using DataFrames
  using LinearAlgebra
  using Random
	using StatisticalRethinking
end

# ╔═╡ a63d2808-ff64-11ea-037d-f58c33309a6d
md"## Clip-09-01s.jl"

# ╔═╡ 34d76984-ff65-11ea-36f9-c1fe6d3edf77
md"### snippet 9.1"

# ╔═╡ 34e18818-ff65-11ea-327d-37ab359d53e7
md"##### Metropolis algorithm."

# ╔═╡ 34e21e60-ff65-11ea-12d2-bd654991499b
function generate_walk(N::Int64)
  num_weeks = N
  positions = zeros(Int64, num_weeks);
  current = 10
  d = Uniform(0, 1)

  for i in 1:N
    positions[i] = current  # Record current position
    proposal = current + sample([-1, 1], 1)[1] # Generate proposal
    proposal = proposal < 1  ? 10 : proposal
    proposal = proposal > 10  ? 1 : proposal  
    prob_move = proposal/current  # Move?
    current = rand(d, 1)[1] <  prob_move ? proposal : current
  end

  positions
  
end

# ╔═╡ 34ee57d4-ff65-11ea-10a4-e3ee18d27928
md"##### Generate the visits ."

# ╔═╡ 34eefa9a-ff65-11ea-269d-3b6d166ebf54
begin
	N = 100000
	walk = generate_walk(N)
end;

# ╔═╡ 34f96ab6-ff65-11ea-3f24-bfe0191b164d
# Plot the first 100 weeks and a histogram of weeks per iosland

begin
	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	fig[1] = plot(walk[1:100], leg=false, xlabel="Week", 
		ylabel="Island", title="First 100 steps")
	fig[2] = histogram(walk, leg=false, xlabel="Island", ylabel="Number of weeks",
	  title="$N steps")
	plot(fig..., layout=(1, 2))
end

# ╔═╡ 34fa3306-ff65-11ea-395b-5b35170d0099
md"## End of clip-09-01s.jl"

# ╔═╡ Cell order:
# ╟─a63d2808-ff64-11ea-037d-f58c33309a6d
# ╠═34d2b0f6-ff65-11ea-05bc-c1a781f7bd7d
# ╠═34d2e742-ff65-11ea-35e7-6dba8cede1d5
# ╟─34d76984-ff65-11ea-36f9-c1fe6d3edf77
# ╟─34e18818-ff65-11ea-327d-37ab359d53e7
# ╠═34e21e60-ff65-11ea-12d2-bd654991499b
# ╟─34ee57d4-ff65-11ea-10a4-e3ee18d27928
# ╠═34eefa9a-ff65-11ea-269d-3b6d166ebf54
# ╠═34f96ab6-ff65-11ea-3f24-bfe0191b164d
# ╟─34fa3306-ff65-11ea-395b-5b35170d0099
