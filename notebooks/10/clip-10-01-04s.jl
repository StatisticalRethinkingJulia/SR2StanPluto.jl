### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 71a70a62-28fb-11eb-2092-7d3640b6ddf5
using Pkg, DrWatson

# ╔═╡ 71d2cdaa-28fb-11eb-3826-cf35b99cde1f
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ d31428e6-85d2-11eb-396b-c9d6da91e9ae
md" ### Clip-10-01-04s.jl"

# ╔═╡ ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
m = [0 0 10 0 0;
	0 1 8 1 0;
	0 2 6 2 0;
	1 2 4 2 1;
	2 2 2 2 2];

# ╔═╡ c65f5f04-8770-11eb-2407-05dbb86e82b7
begin
	pr_m = float.(deepcopy(m))
	r, c = size(pr_m)
	for row in 1:r
		pr_m[row, :] = [pr_m[row, i] / sum(pr_m[row, :]) for i in 1:c]
	end
	pr_m
end

# ╔═╡ 8b5eb0ee-881a-11eb-022c-adf0d7440e84
function factorial_fraction(m)
	w = []
	for i in 1:size(m, 1)
		n = m[i,:]
		append!(w, [factorial(sum(n))/prod(factorial, n)])
	end
	w
end

# ╔═╡ 2b2c55a8-8821-11eb-0176-91dca1254a8b
ways = factorial_fraction(m)

# ╔═╡ edac53be-881a-11eb-1dbd-a189c57ac336
begin
	N = 10
	logwayspp = (1/N) * log.(factorial_fraction(m))
end

# ╔═╡ 5480e430-876a-11eb-0c63-aff9c5cf17d2
begin
	h = zeros(c)
	for i in 1:r
		s = [pr_m[i, j] == 0 ? 0 : pr_m[i, j] * log(pr_m[i, j]) for j in 1:c]
		h[i] = -sum(s)
	end
	h
end


# ╔═╡ ae0c69d8-85d6-11eb-2db9-01a3f56c9a65
begin
	fig = plot(logwayspp, h, ylims=(-0.1, 1.75),
		xlab="log(ways) per pebble", ylab="Entropy", leg=false)
	scatter!(logwayspp, h)
	for (ind, sym) in enumerate([:A, :B, :C, :D, :E])
		annotate!([(logwayspp[ind], h[ind] + 0.1,
			Plots.text(sym, 10, :red, :right))])
	end
	fig
end

# ╔═╡ 22d43054-8661-11eb-0dd7-fb846edb81c4
md" ### End clip-10-01-04s.jl"

# ╔═╡ Cell order:
# ╟─d31428e6-85d2-11eb-396b-c9d6da91e9ae
# ╠═71a70a62-28fb-11eb-2092-7d3640b6ddf5
# ╠═71d2cdaa-28fb-11eb-3826-cf35b99cde1f
# ╠═ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
# ╠═c65f5f04-8770-11eb-2407-05dbb86e82b7
# ╠═8b5eb0ee-881a-11eb-022c-adf0d7440e84
# ╠═2b2c55a8-8821-11eb-0176-91dca1254a8b
# ╠═edac53be-881a-11eb-1dbd-a189c57ac336
# ╠═5480e430-876a-11eb-0c63-aff9c5cf17d2
# ╠═ae0c69d8-85d6-11eb-2db9-01a3f56c9a65
# ╟─22d43054-8661-11eb-0dd7-fb846edb81c4
