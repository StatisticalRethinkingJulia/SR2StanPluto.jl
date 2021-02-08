
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-12s.jl"

md" ##### Entropy."

H(p) = -sum(p .* log.(p))

md" ##### Cross Entropy."

H(p, q) = -sum(p .* log.(q))

md" ##### Kullback-Leibler divergence."

D(p, q) = sum(p .* log.(p ./ q))

md" ### Snippet 7.12"

begin
	p = [0.3, 0.7]
	q = [0.25, 0.75]
	earth = [0.7, 0.3]
	mars = [0.01, 0.99]
end

H(p)

H([0.01, 0.99])

H([0.7, 0.15, 0.15])

D(p, q)

begin
	qrange = 0.001:0.01:1.0
	res = []
	for qstep in qrange
		qs = [qstep, 1-qstep]
		append!(res, [D(p, qs)])
	end
	plot(qrange, res, xlab="q[1]", ylab="Divergence q from p", leg=false)
	vline!([0.3])
end

H(p, q)

D(p, q)

H(p, q) - H(p)

md" ##### Divergence from earth -> mars."

md"
!!! note
    Reverse arguments?
"

D(mars, earth)

md" ##### Divergence from mars -> earth."

D(earth, mars)

md" ## End of clip-07-12s.jl"

