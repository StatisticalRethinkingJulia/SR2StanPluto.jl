
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

for i in 1:3
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

md"## Clip-05-12s.jl"

md"##### Include models [`m5_1s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.1s.jl), [`m5_2s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.2s.jl) and [`m5_3s`](https://github.com/StatisticalRethinkingJulia/StatisticalRethinkingStan.jl/blob/master/models/05/m5.3s.jl):"

md"##### Normal estimates:"

if success(rc5_3s)
	(s1, p1) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM]; 
		title="Particles (Normal) estimates")
	p1
end

s1

md"##### Quap estimates:"

if success(rc5_3s)
	(s2, p2) = plotcoef([m5_1s, m5_2s, m5_3s], [:bA, :bM];
		title="Quap estimates", func=quap)
	p2
end

s2

md"## End of clip-05-12s.jl"

