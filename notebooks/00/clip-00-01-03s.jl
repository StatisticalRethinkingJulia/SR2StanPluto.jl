### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9941173e-f2dc-11ea-0f91-4ff7401d7d2c
using Pkg, DrWatson

# ╔═╡ 0b2c7f06-f2dc-11ea-0434-cdc3e04decae
md"## Clip-00-01-03s.jl"

# ╔═╡ 9941ddcc-f2dc-11ea-1311-09c5aa4ae090
@quickactivate "StatisticalRethinkingStan"

# ╔═╡ 9948d1f4-f2dc-11ea-225d-992c7e2f825f
md"### snippet 0.1"

# ╔═╡ 99496f10-f2dc-11ea-21f9-7fd3bcbdf477
"All models are wrong, but some are useful."

# ╔═╡ 9956c73c-f2dc-11ea-1620-13786d3d33e4
md"### snippet 0.2"

# ╔═╡ 9957701a-f2dc-11ea-18d6-55adda75b7d4
md"##### This is a StepRange, not a vector."

# ╔═╡ 9960bc1a-f2dc-11ea-3a7b-4181c9fa8fe8
x1 = 1:3

# ╔═╡ 996156d4-f2dc-11ea-10e4-4fc246187dd3
md"##### Below still preserves the StepRange."

# ╔═╡ 996b40ea-f2dc-11ea-3814-15033114a487
x2 = x1*10

# ╔═╡ e04af122-f2dc-11ea-2a23-33f8632dbed9
typeof(x2)

# ╔═╡ fbc13db2-f2dc-11ea-1368-9387b64be726
x2[end]

# ╔═╡ 996be34c-f2dc-11ea-2f8f-c389bca0896e
md"##### `Broadcast` log to steprange elements in x2, this returms a vector! Notice the log.(x2) notation."

# ╔═╡ 99780bae-f2dc-11ea-0af3-6157b75c5288
x3 = log.(x2)

# ╔═╡ ed4ea62a-f2dc-11ea-3bed-0ff984265c52
typeof(x3)

# ╔═╡ 9979b86e-f2dc-11ea-3cb9-291cec8627a2
md"##### We can sum the vector x3."

# ╔═╡ 9988b358-f2dc-11ea-1f2d-139af6ac6699
x4 = sum(x3)

# ╔═╡ 998df810-f2dc-11ea-0415-a33278120eac
# Etc.

begin
	x = exp(x4)
	x = x*10
	x = log(x)
	x = sum(x)
	x = exp(x)
end

# ╔═╡ 9991cfc6-f2dc-11ea-0322-f908d09388e7
md"### snippet 0.3"

# ╔═╡ 999f513c-f2dc-11ea-3917-2390217ae1ad
[log(0.01^200) 200 * log(0.01)]

# ╔═╡ 99a096fa-f2dc-11ea-2c15-bd83f1acacf9
md"## End of clip-00-01-03s.jl"

# ╔═╡ Cell order:
# ╟─0b2c7f06-f2dc-11ea-0434-cdc3e04decae
# ╠═9941173e-f2dc-11ea-0f91-4ff7401d7d2c
# ╠═9941ddcc-f2dc-11ea-1311-09c5aa4ae090
# ╟─9948d1f4-f2dc-11ea-225d-992c7e2f825f
# ╟─99496f10-f2dc-11ea-21f9-7fd3bcbdf477
# ╟─9956c73c-f2dc-11ea-1620-13786d3d33e4
# ╟─9957701a-f2dc-11ea-18d6-55adda75b7d4
# ╠═9960bc1a-f2dc-11ea-3a7b-4181c9fa8fe8
# ╟─996156d4-f2dc-11ea-10e4-4fc246187dd3
# ╠═996b40ea-f2dc-11ea-3814-15033114a487
# ╠═e04af122-f2dc-11ea-2a23-33f8632dbed9
# ╠═fbc13db2-f2dc-11ea-1368-9387b64be726
# ╟─996be34c-f2dc-11ea-2f8f-c389bca0896e
# ╠═99780bae-f2dc-11ea-0af3-6157b75c5288
# ╠═ed4ea62a-f2dc-11ea-3bed-0ff984265c52
# ╟─9979b86e-f2dc-11ea-3cb9-291cec8627a2
# ╠═9988b358-f2dc-11ea-1f2d-139af6ac6699
# ╠═998df810-f2dc-11ea-0415-a33278120eac
# ╟─9991cfc6-f2dc-11ea-0322-f908d09388e7
# ╠═999f513c-f2dc-11ea-3917-2390217ae1ad
# ╟─99a096fa-f2dc-11ea-2c15-bd83f1acacf9
