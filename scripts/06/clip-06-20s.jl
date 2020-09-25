
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "06", "m6.7s.jl"))

include(projectdir("models", "06", "m6.8s.jl"))

md"## Clip-06-20s.jl"

begin
	N = 1000
	df = DataFrame(
	  :h0 => rand(Normal(10,2 ), N),
	  :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2))),
	  :M => rand(Bernoulli(), N)
	);

	d(i) = Binomial(1, 0.5 - 0.4 * df[i, :treatment] + 0.4 * df[i, :M])
	df.fungus = [rand(d(i), 1)[1] for i in 1:N]
	df.h1 = [df[i, :h0] + rand(Normal(5 + 3 * df[i, :M]), 1)[1] for i in 1:N]
end

md"##### Execute m6.7s & m6.8s."

begin
	(s, p) = plotcoef([m6_7s, m6_8s], [:a, :bt, :bf], "")
	p
end

s


