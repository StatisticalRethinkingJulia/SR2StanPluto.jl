### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 71a70a62-28fb-11eb-2092-7d3640b6ddf5
using Pkg, DrWatson

# ╔═╡ 71d2cdaa-28fb-11eb-3826-cf35b99cde1f
begin
	#@quickactivate "SR2StanPluto"
	using Distributions
	using StatisticalRethinking
end

# ╔═╡ d31428e6-85d2-11eb-396b-c9d6da91e9ae
md" ### Clip-10-05-13s.jl"

# ╔═╡ a53d874e-8cd2-11eb-3b71-211732d6f4de
md" ### Snippet 10.5"

# ╔═╡ ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
p = [
	1/4 1/4 1/4 1/4;
	2/6 1/6 1/6 2/6;
	1/6 2/6 2/6 1/6;
	1/8 4/8 2/8 1/8
]

# ╔═╡ af15068e-8cd2-11eb-1389-af62bfdfaab8
md" ### Snippet 10.6"

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


# ╔═╡ b5d131fa-8cd2-11eb-2302-456dde8b349f
md" ### Snippet 10.7"

# ╔═╡ c5dbfbae-8c12-11eb-2174-c9794a1c39d0
begin
	pr = 0.7
	a = [(1-pr)^2, pr*(1-pr), (1-pr)*pr, pr^2]
end

# ╔═╡ 99f30866-8cd2-11eb-30c8-4f54788620c2
md" ### Snippet 10.8"

# ╔═╡ 0c763214-8c13-11eb-3acb-35a54497de6c
-sum(a .* log.(a))

# ╔═╡ 87fa5676-8cd2-11eb-3a6b-b563dae2ae8d
md" ### Snippet 10.9"

# ╔═╡ 35ef080a-8c13-11eb-24ed-0d9e65e13069
function sim_p(g = 1.4)
	x123 = rand(Uniform(), 3)
	x4 = (g .* sum(x123) .- x123[2] .- x123[3]) ./ (2 - g)
	z = sum(vcat(x123, x4))
	p = vcat(x123, x4) ./ z
	(h = -sum(p .* log.(p)), p = p,)
end

# ╔═╡ 7499df52-8cd2-11eb-3490-6dc28108d33d
md" ### Snippet 10.11"

# ╔═╡ d4beaeba-8c13-11eb-2801-23af8049ca4a
begin
	h2 = [sim_p() for i in 1:100000]
	df = sort(DataFrame(NamedTuple{keys(h2[1])}.(h2), copycols=false), :h)
end

# ╔═╡ cc3bb1ea-8cd2-11eb-20f6-8176bc9783a9
md" ### Snippet 10.10"

# ╔═╡ f39459c6-8cad-11eb-242a-e3f110056f13
begin
	res = df[[91000, 12000, 700, 5], :]
	fig2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, size(res,1))
	xlabels = ["ww", "wb", "bw", "bb"]
	titles = [:A, :B, :C, :D]
	xs = [xlabels[i] for i = 1:4]
	for i in 1:size(res,1)
		fig2[i] = plot(leg=false)
		plot!(xs, res[i, :p], title=titles[i])
	end
end

# ╔═╡ 13ac6c8e-8cb7-11eb-37f7-e7221773fb74
begin
	fig1 = density(df.h, xlab="Entropy", ylab="Density", leg=false)
	for i in 1:size(res, 1)
		vline!([res[i, :h]], lab=String(titles[i]))
		annotate!([(res[i, :h]-0.01, 2,
			Plots.text(titles[i], 10, :red, :right))])
	end
	fig3 = plot(fig2..., layout=(2, 2))
	plot(fig1, fig3, layout=(1, 2))
end

# ╔═╡ 4df0844e-8cd2-11eb-0c08-519ceb986561
md" ### Snippet 10.12"

# ╔═╡ 8b76cf64-8caa-11eb-10e9-3962fa03da68
findmax(df.h)

# ╔═╡ 29e01bac-8cd2-11eb-1613-11110d0bb1c8
md" ### Snippet 10.13"

# ╔═╡ f4dc21e2-8cd1-11eb-1f5f-5950f5c2c812
df[end, :p]

# ╔═╡ 22d43054-8661-11eb-0dd7-fb846edb81c4
md" ### End clip-10-05-13s.jl"

# ╔═╡ Cell order:
# ╟─d31428e6-85d2-11eb-396b-c9d6da91e9ae
# ╠═71a70a62-28fb-11eb-2092-7d3640b6ddf5
# ╠═71d2cdaa-28fb-11eb-3826-cf35b99cde1f
# ╟─a53d874e-8cd2-11eb-3b71-211732d6f4de
# ╠═ed43435a-85d2-11eb-0aea-2ffa1acc2cc5
# ╟─af15068e-8cd2-11eb-1389-af62bfdfaab8
# ╠═5480e430-876a-11eb-0c63-aff9c5cf17d2
# ╟─b5d131fa-8cd2-11eb-2302-456dde8b349f
# ╠═c5dbfbae-8c12-11eb-2174-c9794a1c39d0
# ╟─99f30866-8cd2-11eb-30c8-4f54788620c2
# ╠═0c763214-8c13-11eb-3acb-35a54497de6c
# ╟─87fa5676-8cd2-11eb-3a6b-b563dae2ae8d
# ╠═35ef080a-8c13-11eb-24ed-0d9e65e13069
# ╟─7499df52-8cd2-11eb-3490-6dc28108d33d
# ╠═d4beaeba-8c13-11eb-2801-23af8049ca4a
# ╟─cc3bb1ea-8cd2-11eb-20f6-8176bc9783a9
# ╠═f39459c6-8cad-11eb-242a-e3f110056f13
# ╠═13ac6c8e-8cb7-11eb-37f7-e7221773fb74
# ╟─4df0844e-8cd2-11eb-0c08-519ceb986561
# ╠═8b76cf64-8caa-11eb-10e9-3962fa03da68
# ╟─29e01bac-8cd2-11eb-1613-11110d0bb1c8
# ╠═f4dc21e2-8cd1-11eb-1f5f-5950f5c2c812
# ╟─22d43054-8661-11eb-0dd7-fb846edb81c4
