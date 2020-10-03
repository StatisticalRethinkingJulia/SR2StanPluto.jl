
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Clip-09-01s.jl"

md"### snippet 9.1"

md"##### Metropolis algorithm."

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

md"##### Generate the visits ."

begin
	N = 100000
	walk = generate_walk(N)
end;


begin
	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	fig[1] = plot(walk[1:100], leg=false, xlabel="Week", ylabel="Island", title="First 100 steps")
	fig[2] = histogram(walk, leg=false, xlabel="Island", ylabel="Number of weeks",
	  title="$N steps")
	plot(fig..., layout=(1, 2))
end

md"## End of clip-09-01s.jl"

