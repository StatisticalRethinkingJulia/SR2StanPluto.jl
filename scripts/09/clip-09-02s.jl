
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using LinearAlgebra
	using StatisticalRethinking
end

md"## clip-09-02s.jl"

md"### Snippet 9.2"

md"##### Number of samples."

T = 1000

md"##### Compute radial distance."

rad_dist(x) = sqrt(sum(x .^ 2))

md"##### Plot densities."

begin
	p = density(xlabel="Radial distance from mode", ylabel="Density")
	for d in [1, 10, 100, 1000]
		m = MvNormal(zeros(d), Diagonal(ones(d)))
		local y = rand(m, T)
		rd = [rad_dist( y[:, i] ) for i in 1:T] 
		density!(p, rd, lab="d=$d")
	end
	p
end

md"## End of clip-09-02s.jl"

