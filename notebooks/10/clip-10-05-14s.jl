### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 71a70a62-28fb-11eb-2092-7d3640b6ddf5
using Pkg, DrWatson

# ╔═╡ 71d2cdaa-28fb-11eb-3826-cf35b99cde1f
begin
	@quickactivate "StatisticalRethinkingStan"
	using Distributions
	using StatisticalRethinking
end

# ╔═╡ d31428e6-85d2-11eb-396b-c9d6da91e9ae
md" ### Clip-10-05-13s.jl"

# ╔═╡ ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
p = [
	1/4 1/4 1/4 1/4;
	2/6 1/6 1/6 2/6;
	1/6 2/6 2/6 1/6;
	1/8 4/8 2/8 1/8
]

# ╔═╡ 5480e430-876a-11eb-0c63-aff9c5cf17d2
begin
	r, c = size(p)
	h = zeros(c)
	for i in 1:r
		s = [p[i, j] == 0 ? 0 : p[i, j] * log(p[i, j]) for j in 1:c]
		h[i] = -sum(s)
	end
	h
end


# ╔═╡ d964488a-8a8b-11eb-286d-952030dd9e0f
rand(Binomial(10, 0.6), 4)

# ╔═╡ 22d43054-8661-11eb-0dd7-fb846edb81c4
md" ### End clip-10-05-13s.jl"

# ╔═╡ Cell order:
# ╟─d31428e6-85d2-11eb-396b-c9d6da91e9ae
# ╠═71a70a62-28fb-11eb-2092-7d3640b6ddf5
# ╠═71d2cdaa-28fb-11eb-3826-cf35b99cde1f
# ╠═ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
# ╠═5480e430-876a-11eb-0c63-aff9c5cf17d2
# ╠═d964488a-8a8b-11eb-286d-952030dd9e0f
# ╟─22d43054-8661-11eb-0dd7-fb846edb81c4
