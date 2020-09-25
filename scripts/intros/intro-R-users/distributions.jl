
using Markdown
using InteractiveUtils

using DrWatson

using StatisticalRethinking

md"## Distributions.jl"

@quickactivate "StatisticalRethinkingStan"

begin
	ways = [0, 3, 8, 9, 0]
	ways = ways / sum(ways)
end

md"##### Working with distributions is a little different between Julia and R.

Instead of having `rbinom`, `dbinom` and `pbinom` we just
have the `Binomial` distribution which to work with:"

d = Binomial(9, 0.5)

md"##### Parameters of Binomial."

fieldnames(Binomial)

md"##### Number of trials parameter."

d.n

md"##### Singe random draw."

rand(d)

md"##### 9 draws."

rand(d, 9)                          # 

pdf(d, 6)                        # probability density of getting a 6

cdf(d, 6)                        # cumulative probability of getting 6

md"## End of distributions.jl"

