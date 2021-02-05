### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ e7c05ce8-58ef-11eb-2da6-bfffd4491883
using Pkg, DrWatson

# ╔═╡ 7fb874b8-58f0-11eb-3e17-91468135856f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ f7e9345a-58ef-11eb-347d-1b1c98f3663b
md" ## Clip-07-12s.jl"

# ╔═╡ 3c15dcca-58f3-11eb-046c-33c66612701d
md" ##### Entropy."

# ╔═╡ f7e8f63e-58ef-11eb-094b-85d2f930cbfc
H(p) = -sum(p .* log.(p))

# ╔═╡ 4a2cd688-58f3-11eb-071a-7d5191b2acc4
md" ##### Cross Entropy."

# ╔═╡ 313dbcfa-58f3-11eb-0b61-73d83a62cb76
H(p, q) = -sum(p .* log.(q))

# ╔═╡ 514bd3c4-58f3-11eb-27eb-055303c639b1
md" ##### Kullback-Leibler divergence."

# ╔═╡ 37a70450-58f0-11eb-00b1-c526f9615ff4
D(p, q) = sum(p .* log.(p ./ q))

# ╔═╡ 5e898a3a-58f4-11eb-1c3d-ef781cf3e9f0
md" ### Snippet 7.12"

# ╔═╡ 48b01fc0-58f0-11eb-10e1-8969cfc5022f
begin
	p = [0.3, 0.7]
	q = [0.25, 0.75]
	earth = [0.7, 0.3]
	mars = [0.01, 0.99]
end

# ╔═╡ 65e714ae-58f0-11eb-0f86-bb6dad500c12
H(p)

# ╔═╡ 90e27340-58f2-11eb-367e-cb2aae23b616
H([0.01, 0.99])

# ╔═╡ c0ee72a4-6668-11eb-1078-a5f09dfbecff
H([0.7, 0.15, 0.15])

# ╔═╡ 69d6127c-58f0-11eb-29c9-0ba1d12c61c2
D(p, q)

# ╔═╡ b6ffed52-58f0-11eb-1ab2-7902bd8a2b52
begin
	qrange = 0.001:0.01:1.0
	res = []
	for qstep in qrange
		qs = [qstep, 1-qstep]
		append!(res, [D(p, qs)])
	end
	plot(qrange, res, xlab="q[1]", ylab="Divergence q from p", leg=false)
	vline!([0.3])
end

# ╔═╡ edf40570-58f3-11eb-0650-03caff8b1c72
H(p, q)

# ╔═╡ 42415416-58f4-11eb-2cc3-c951f0416798
D(p, q)

# ╔═╡ 49cab272-58f4-11eb-02a8-375cce076851
H(p, q) - H(p)

# ╔═╡ 2c131646-58f6-11eb-12f2-f3b8dfb82dcb
md" ##### Divergence from earth -> mars."

# ╔═╡ 09550666-5994-11eb-3c4c-11461379f117
md"
!!! note
    Reverse arguments?
"

# ╔═╡ 755016a2-58f5-11eb-02c6-235a5d44e9c7
D(mars, earth)

# ╔═╡ 40d5189a-58f6-11eb-08c3-95d784d16c87
md" ##### Divergence from mars -> earth."

# ╔═╡ 6bc4b400-58f5-11eb-1de2-c9c8b44ae7ae
D(earth, mars)

# ╔═╡ 0ffd4f9a-58f0-11eb-1f66-236f6b48ab3f
md" ## End of clip-07-12s.jl"

# ╔═╡ Cell order:
# ╟─f7e9345a-58ef-11eb-347d-1b1c98f3663b
# ╠═e7c05ce8-58ef-11eb-2da6-bfffd4491883
# ╠═7fb874b8-58f0-11eb-3e17-91468135856f
# ╟─3c15dcca-58f3-11eb-046c-33c66612701d
# ╠═f7e8f63e-58ef-11eb-094b-85d2f930cbfc
# ╟─4a2cd688-58f3-11eb-071a-7d5191b2acc4
# ╠═313dbcfa-58f3-11eb-0b61-73d83a62cb76
# ╟─514bd3c4-58f3-11eb-27eb-055303c639b1
# ╠═37a70450-58f0-11eb-00b1-c526f9615ff4
# ╟─5e898a3a-58f4-11eb-1c3d-ef781cf3e9f0
# ╠═48b01fc0-58f0-11eb-10e1-8969cfc5022f
# ╠═65e714ae-58f0-11eb-0f86-bb6dad500c12
# ╠═90e27340-58f2-11eb-367e-cb2aae23b616
# ╠═c0ee72a4-6668-11eb-1078-a5f09dfbecff
# ╠═69d6127c-58f0-11eb-29c9-0ba1d12c61c2
# ╠═b6ffed52-58f0-11eb-1ab2-7902bd8a2b52
# ╠═edf40570-58f3-11eb-0650-03caff8b1c72
# ╠═42415416-58f4-11eb-2cc3-c951f0416798
# ╠═49cab272-58f4-11eb-02a8-375cce076851
# ╟─2c131646-58f6-11eb-12f2-f3b8dfb82dcb
# ╟─09550666-5994-11eb-3c4c-11461379f117
# ╠═755016a2-58f5-11eb-02c6-235a5d44e9c7
# ╟─40d5189a-58f6-11eb-08c3-95d784d16c87
# ╠═6bc4b400-58f5-11eb-1de2-c9c8b44ae7ae
# ╟─0ffd4f9a-58f0-11eb-1f66-236f6b48ab3f
