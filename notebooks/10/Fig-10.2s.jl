### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 71a70a62-28fb-11eb-2092-7d3640b6ddf5
using Pkg, DrWatson

# ╔═╡ 71d2cdaa-28fb-11eb-3826-cf35b99cde1f
begin
	#@quickactivate "SR2StanPluto"
	using SpecialFunctions
	using StatisticalRethinking
end

# ╔═╡ d31428e6-85d2-11eb-396b-c9d6da91e9ae
md" ### Fig-10.2s.jl"

# ╔═╡ 1a849306-88c0-11eb-1b19-85694099f38f
function alpha(sigma, beta)
	sigma * sqrt(gamma(1/beta) / gamma(3/beta))
end

# ╔═╡ 61e6d20a-88bf-11eb-32c3-216979f1c4fb
begin
	β = [1.0, 1.5, 2.0, 2.5]
	α = [alpha(1.0, β[i]) for i in 1:length(β)]
	σ = [α[i]^2 * gamma(3/β[i]) / gamma(1/β[i]) for i in 1:length(β)]
	
	x = -4.0:0.01:4.0
	fig1 = plot(xlims=(-4,0, 4.0), xlab="x", ylab="Density")
	for i in 1:length(β)
		y = pdf(PGeneralizedGaussian(0.0, α[i], β[i]), x)
		plot!(x, y, lab = "α=$(round(α[i], digits=1)), β[$i]=$(β[i])")
	end
	plot!(x, pdf(Normal(), x), line=(:dash, 2), color=:darkblue,
		lab = "Normal(0, 1)")
	fig1
end

# ╔═╡ 864c11f0-8900-11eb-1a83-87d3d8a6297d
begin
	x2 = -4.0:0.01:4.0
	β2 = 1.0:0.01:4.0
	y2 = []
	fig2 = plot(xlims=(1.0, 4.0), leg=false)
	for i in 1:length(β2)
		α2 = alpha(1.0, β2[i])
		σ2 = α2^2 * gamma(3/β2[i]) / gamma(1/β2[i])
		local p = pdf(PGeneralizedGaussian(0.0, α2, β2[i]), x)
		h2 = -sum([p[i] * log(p[i]) for i in 1:length(p)])
		append!(y2, [h2])
	end
	plot!(β2, y2, xlab = "Shape (β2)", ylab="Entropy")
	vline!([2.0], line=:dash)
	fig2
end

# ╔═╡ deb0ea70-8901-11eb-37c6-5dc0a9b2d0dd
plot(fig1, fig2, layout=(1,2))

# ╔═╡ 22d43054-8661-11eb-0dd7-fb846edb81c4
md" ### End Fig-10.2s.jl"

# ╔═╡ Cell order:
# ╟─d31428e6-85d2-11eb-396b-c9d6da91e9ae
# ╠═71a70a62-28fb-11eb-2092-7d3640b6ddf5
# ╠═71d2cdaa-28fb-11eb-3826-cf35b99cde1f
# ╠═1a849306-88c0-11eb-1b19-85694099f38f
# ╠═61e6d20a-88bf-11eb-32c3-216979f1c4fb
# ╠═864c11f0-8900-11eb-1a83-87d3d8a6297d
# ╠═deb0ea70-8901-11eb-37c6-5dc0a9b2d0dd
# ╟─22d43054-8661-11eb-0dd7-fb846edb81c4
