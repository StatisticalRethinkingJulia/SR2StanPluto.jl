
using Markdown
using InteractiveUtils

using Pkg, DrWatson

md"## Clip-00-01-03s.jl"

@quickactivate "StatisticalRethinkingStan"

md"### snippet 0.1"

"All models are wrong, but some are useful."

md"### snippet 0.2"

md"##### This is a StepRange, not a vector."

x1 = 1:3

md"##### Below still preserves the StepRange."

x2 = x1*10

typeof(x2)

x2[end]

md"##### `Broadcast` log to steprange elements in x2, this returms a vector! Notice the log.(x2) notation."

x3 = log.(x2)

typeof(x3)

md"##### We can sum the vector x3."

x4 = sum(x3)


begin
	x = exp(x4)
	x = x*10
	x = log(x)
	x = sum(x)
	x = exp(x)
end

md"### snippet 0.3"

[log(0.01^200) 200 * log(0.01)]

md"## End of clip-00-01-03s.jl"

