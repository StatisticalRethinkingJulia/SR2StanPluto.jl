### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 30fce022-fdb3-11ea-1059-f97f38c19c0f
using Pkg, DrWatson

# ╔═╡ 30fd1a06-fdb3-11ea-2118-a1facb5194e2
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 3105a0f4-fdb3-11ea-22d8-8b6e68afa993
for i in 5:7
	include(projectdir("models", "05", "m5.$(i)s.jl"))
end

# ╔═╡ 50bbda36-fdb2-11ea-0702-a7ae407a74a7
md"## Clip-05-39s.jl"

# ╔═╡ 30fda02a-fdb3-11ea-2037-6f772dd59330
md"### snippet 5.39"

# ╔═╡ 8f2d61f8-8346-11eb-12a0-c5989da2d4db
md"
!!! note
	In below cell `include()` is used. If this cell needs to be executed again, the notebook needs to be restarted.
"

# ╔═╡ 3108f92a-fdb3-11ea-0959-9b1b6d094a4c
begin
	(s1, p1) = plot_model_coef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	plot(p1;dpi = 460)
end

# ╔═╡ 310f3100-fdb3-11ea-0c35-b3014ae7e73d
s1

# ╔═╡ 3115a60c-fdb3-11ea-16d2-75f8753f7f0f
begin
	(s2, p2) = plot_model_coef([m5_5s, m5_6s, m5_7s], [:a, :bN, :bM];
		title="Masked relationships: bN & bM Normal estimates")
	plot(p2; dpi=460)
 end

# ╔═╡ 31163fc2-fdb3-11ea-03a4-9dc90236e2d6
s2

# ╔═╡ 312018a0-fdb3-11ea-171d-49ed6fe7bbcb
md"## End of clip-05-39s.jl"

# ╔═╡ Cell order:
# ╟─50bbda36-fdb2-11ea-0702-a7ae407a74a7
# ╠═30fce022-fdb3-11ea-1059-f97f38c19c0f
# ╠═30fd1a06-fdb3-11ea-2118-a1facb5194e2
# ╟─30fda02a-fdb3-11ea-2037-6f772dd59330
# ╟─8f2d61f8-8346-11eb-12a0-c5989da2d4db
# ╠═3105a0f4-fdb3-11ea-22d8-8b6e68afa993
# ╠═3108f92a-fdb3-11ea-0959-9b1b6d094a4c
# ╠═310f3100-fdb3-11ea-0c35-b3014ae7e73d
# ╠═3115a60c-fdb3-11ea-16d2-75f8753f7f0f
# ╠═31163fc2-fdb3-11ea-03a4-9dc90236e2d6
# ╟─312018a0-fdb3-11ea-171d-49ed6fe7bbcb
