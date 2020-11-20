
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Clip-02-01-02s.jl"

md"### snippet 2.1"

begin
	ways = [0, 3, 8, 9, 0];
	p = ways/sum(ways)
end

begin
	previous_counts = [ 0, 3, 16, 27, 0]
	bags = [0, 3, 2, 1, 0]
	p_updated = previous_counts .* bags / sum(previous_counts .* bags)
end

md"### snippet 2.2"

md"##### Create a distribution with n = 9 (e.g. tosses) and p = 0.5."

d = Binomial(9, 0.5)

md"##### Probability density for 6 `waters` holding n = 9 and p = 0.5."

pdf(d, 6)

md"## End of clip-02-01-02s.jl"

