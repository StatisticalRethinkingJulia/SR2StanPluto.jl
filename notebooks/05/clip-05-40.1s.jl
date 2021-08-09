### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 629c1314-fdb8-11ea-0810-73f40ec50097
using Pkg, DrWatson

# ╔═╡ 629c6026-fdb8-11ea-222c-01752dee3679
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 62a90e5c-fdb8-11ea-2748-a31802543587
for i in 5:7
	include(projectdir("models", "05", "m5.$(i)s.jl"))
end

# ╔═╡ 4ce0616e-fdb7-11ea-0474-63cb801384f5
md"## Clip-05-40.1s.jl"

# ╔═╡ 629ccafc-fdb8-11ea-1012-d11648fe79d0
md"### snippet 5.39"

# ╔═╡ ed7b94dc-8346-11eb-0644-69bf473d42e2
md"
!!! note
	Restart this notebook to re-execute below `include()`.
"

# ╔═╡ 62a988b4-fdb8-11ea-0cdd-1759b8567402
if success(rc5_5s)
	post5_5s_df = read_samples(m5_5s, :dataframe)
	title5 = "Kcal_per_g vs. neocortex_perc" * "\n89% predicted and mean range"
	fig1 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		post5_5s_df, [:a, :bN, :sigma];
		title=title5
	)
end

# ╔═╡ 62b4472e-fdb8-11ea-3bf0-8b453a2872a9
if success(rc5_6s)
	post5_6s_df = read_samples(m5_6s, :dataframe)
	title6 = "Kcal_per_g vs. log mass" * "\n89% predicted and mean range"
	fig2 = plotbounds(
		df, :lmass, :kcal_per_g,
		post5_6s_df, [:a, :bM, :sigma];
		title=title6
	)
end

# ╔═╡ 62b4cd64-fdb8-11ea-38d9-8d6810b1a4d4
if success(rc5_7s)
	post5_7s_df = read_samples(m5_7s, :dataframe)
	title7 = "Counterfactual,\nholding M=0.0"
	fig3 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		post5_7s_df, [:a, :bN, :sigma];
		title=title7
	)
end

# ╔═╡ 62be59ce-fdb8-11ea-2278-8732aa168e50
if success(rc5_7s)
	title8 = "Counterfactual,\nholding N=0.0"
	fig4 = plotbounds(
		df, :lmass, :kcal_per_g,
		post5_7s_df, [:a, :bM, :sigma];
		title=title8,
		xlab="log(mass)"
	)
end

# ╔═╡ 62beccba-fdb8-11ea-32e6-0fff022ac3fe
plot(fig1, fig2, fig3, fig4, layout=(2, 2))

# ╔═╡ 62c8c1fc-fdb8-11ea-32c1-b9d03576a104
md"## End of clip-05-40.1s.jl"

# ╔═╡ Cell order:
# ╟─4ce0616e-fdb7-11ea-0474-63cb801384f5
# ╠═629c1314-fdb8-11ea-0810-73f40ec50097
# ╠═629c6026-fdb8-11ea-222c-01752dee3679
# ╟─629ccafc-fdb8-11ea-1012-d11648fe79d0
# ╟─ed7b94dc-8346-11eb-0644-69bf473d42e2
# ╠═62a90e5c-fdb8-11ea-2748-a31802543587
# ╠═62a988b4-fdb8-11ea-0cdd-1759b8567402
# ╠═62b4472e-fdb8-11ea-3bf0-8b453a2872a9
# ╠═62b4cd64-fdb8-11ea-38d9-8d6810b1a4d4
# ╠═62be59ce-fdb8-11ea-2278-8732aa168e50
# ╠═62beccba-fdb8-11ea-32e6-0fff022ac3fe
# ╟─62c8c1fc-fdb8-11ea-32c1-b9d03576a104
