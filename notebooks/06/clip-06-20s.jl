### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 54fc6142-ff38-11ea-2884-ed7abed903ca
using Pkg, DrWatson

# ╔═╡ 54fc9980-ff38-11ea-134f-cffec3a049e6
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 550fc4ee-ff38-11ea-0bc0-8db9a84657b2
include(projectdir("models", "06", "m6.7s.jl"))

# ╔═╡ d6c8e622-ff39-11ea-38bb-513629d16e91
include(projectdir("models", "06", "m6.8s.jl"))

# ╔═╡ 8377e266-ff34-11ea-2963-b7dce70656f5
md"## Clip-06-20s.jl"

# ╔═╡ 54fd1328-ff38-11ea-22ee-03b3cbfb8b64
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

# ╔═╡ 5509d90a-ff38-11ea-0563-a9cfe86b4e1e
md"##### Execute m6.7s & m6.8s."

# ╔═╡ 55103e56-ff38-11ea-0825-8b25859b9e32
begin
	(s, p) = plotcoef([m6_7s, m6_8s], [:a, :bt, :bf])
	p
end

# ╔═╡ 551932c2-ff38-11ea-28cd-5bfa4ad04d57
s

# ╔═╡ 5519a194-ff38-11ea-26c3-0140d22578e4
md"## End of clip-06-20s.jl"

# ╔═╡ Cell order:
# ╟─8377e266-ff34-11ea-2963-b7dce70656f5
# ╠═54fc6142-ff38-11ea-2884-ed7abed903ca
# ╠═54fc9980-ff38-11ea-134f-cffec3a049e6
# ╠═54fd1328-ff38-11ea-22ee-03b3cbfb8b64
# ╟─5509d90a-ff38-11ea-0563-a9cfe86b4e1e
# ╠═550fc4ee-ff38-11ea-0bc0-8db9a84657b2
# ╠═d6c8e622-ff39-11ea-38bb-513629d16e91
# ╠═55103e56-ff38-11ea-0825-8b25859b9e32
# ╠═551932c2-ff38-11ea-28cd-5bfa4ad04d57
# ╟─5519a194-ff38-11ea-26c3-0140d22578e4
