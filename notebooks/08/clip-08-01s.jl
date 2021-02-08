### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 63ba08cc-59a8-11eb-0a0f-27efac60d779
using Pkg, DrWatson

# ╔═╡ 6db218c6-59a8-11eb-2a8b-7107354cf590
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 8aaa4bcc-59a8-11eb-2003-f1213b116565
using RDatasets

# ╔═╡ 51fc19b8-59a8-11eb-2214-15aca59b807b
md" ## Clip-08-01s.jl"

# ╔═╡ 1b263652-59a9-11eb-141a-0774ef0683fb
md"
!!! tip
	Packages RDatasets is obtained from primary environment.
"

# ╔═╡ a0a0cfe6-59a8-11eb-0f86-c542746c814f
begin
	df = dataset("datasets", "iris")
end

# ╔═╡ b86ef03a-59a8-11eb-2e16-fd7e08f9fef9
describe(df)

# ╔═╡ 0438119a-59a9-11eb-2436-a70129e0c011


# ╔═╡ 075879c8-59a9-11eb-0177-8d904003eca6
md" ## End of clip-08-01s.jl"

# ╔═╡ Cell order:
# ╟─51fc19b8-59a8-11eb-2214-15aca59b807b
# ╠═63ba08cc-59a8-11eb-0a0f-27efac60d779
# ╠═6db218c6-59a8-11eb-2a8b-7107354cf590
# ╟─1b263652-59a9-11eb-141a-0774ef0683fb
# ╠═8aaa4bcc-59a8-11eb-2003-f1213b116565
# ╠═a0a0cfe6-59a8-11eb-0f86-c542746c814f
# ╠═b86ef03a-59a8-11eb-2e16-fd7e08f9fef9
# ╠═0438119a-59a9-11eb-2436-a70129e0c011
# ╟─075879c8-59a9-11eb-0177-8d904003eca6
