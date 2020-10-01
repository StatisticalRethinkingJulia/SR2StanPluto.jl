### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 55da2efe-fd40-11ea-1fb2-237b206602b5
using Pkg, DrWatson

# ╔═╡ 55da724c-fd40-11ea-3868-3baa56009723
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using GLM
	using StatisticalRethinking
end

# ╔═╡ 55e7d3f6-fd40-11ea-14c5-21a0ef390e6d
include(projectdir("models", "05", "m5.3.As.jl"))

# ╔═╡ c46bb522-fd3b-11ea-1165-63af86a6f974
md"## Clip-05-19-24s.jl"

# ╔═╡ 55e74cfe-fd40-11ea-20b3-1519e2e34159
md"##### Include snippets 5.19-5.21."

# ╔═╡ 55f30276-fd40-11ea-3e70-d1600cb0f556
# Rethinking results

rethinking_results = "
           mean   sd  5.5% 94.5%
  a        0.00 0.10 -0.16  0.16
  bM      -0.07 0.15 -0.31  0.18
  bA      -0.61 0.15 -0.85 -0.37
  sigma    0.79 0.08  0.66  0.91
  aM       0.00 0.09 -0.14  0.14
  bAM     -0.69 0.10 -0.85 -0.54
  sigma_M  0.68 0.07  0.57  0.79
";

# ╔═╡ 55f8123e-fd40-11ea-375c-6df3d346a96f
part5_3_As = Particles(dfa5_3_As)

# ╔═╡ 55fefeaa-fd40-11ea-2c88-a910f049dcf0
md"## Snippet 5.22"

# ╔═╡ 55fff1b6-fd40-11ea-38e0-3b694162f66e
a_seq = range(-2, stop=2, length=100);

# ╔═╡ 560a4aa6-fd40-11ea-1103-7191fff677fb
md"## Snippet 5.23"

# ╔═╡ 560dcb42-fd40-11ea-0b2e-f14e70a7425a
m_sim, d_sim = simulate(dfa5_3_As, [:aM, :bAM, :sigma_M], a_seq, [:bM, :sigma]);

# ╔═╡ 5618ec0c-fd40-11ea-3a0f-85fb3e33f1b1
md"## Snippet 5.24"

# ╔═╡ 5621e8fc-fd40-11ea-2f52-095b7196c40c
begin
	fig1 = plot(xlab="Manipulated A", ylab="Counterfactual D",
		title="Total counterfactual effect of A on D")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

# ╔═╡ 56236592-fd40-11ea-2be2-b9b04f0ce30c
begin
	fig2 = plot(xlab="Manipulated A", ylab="Counterfactual M",
		title="Counterfactual effect of A on M")
	plot!(a_seq, mean(m_sim, dims=1)[1, :], leg=false)
	hpdi_array1 = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array1[i, :] =  hpdi(m_sim[i, :])
	end
	plot!(a_seq, mean(m_sim, dims=1)[1, :]; ribbon=(hpdi_array1[:, 1], -hpdi_array1[:, 2]))
end

# ╔═╡ 5631855a-fd40-11ea-173a-a187c5976832
md"##### M -> D"

# ╔═╡ 56339584-fd40-11ea-3c75-4f679d500b1c
begin
	m_seq = range(-2, stop=2, length=100)
	md_sim = zeros(size(dfa5_3_As, 1), length(m_seq))
	for j in 1:size(dfa5_3_As, 1)
		for i in 1:length(m_seq)
			d = Normal(dfa5_3_As[j, :a] + dfa5_3_As[j, :bM] * m_seq[i], dfa5_3_As[j, :sigma])
			md_sim[j, i] = rand(d, 1)[1]
		end
	end
	fig3 = plot(xlab="Manipulated M", ylab="Counterfactual D",
		title="Counterfactual effect of M on D")
	plot!(m_seq, mean(md_sim, dims=1)[1, :], leg=false)
	hpdi_array2 = zeros(length(m_seq), 2)
	for i in 1:length(m_seq)
		hpdi_array2[i, :] =  hpdi(md_sim[i, :])
	end
	plot!(m_seq, mean(md_sim, dims=1)[1, :]; ribbon=(hpdi_array2[:, 1], -hpdi_array2[:, 2]))
end

# ╔═╡ 563b3f8c-fd40-11ea-1d4b-3fc4eec893fa
plot(fig1, fig2, fig3, layout=(3, 1))

# ╔═╡ 56426262-fd40-11ea-22a7-5bbc6089cb07
md"## End of clip-05-19-24s.jl"

# ╔═╡ Cell order:
# ╟─c46bb522-fd3b-11ea-1165-63af86a6f974
# ╠═55da2efe-fd40-11ea-1fb2-237b206602b5
# ╠═55da724c-fd40-11ea-3868-3baa56009723
# ╟─55e74cfe-fd40-11ea-20b3-1519e2e34159
# ╠═55e7d3f6-fd40-11ea-14c5-21a0ef390e6d
# ╠═55f30276-fd40-11ea-3e70-d1600cb0f556
# ╠═55f8123e-fd40-11ea-375c-6df3d346a96f
# ╟─55fefeaa-fd40-11ea-2c88-a910f049dcf0
# ╠═55fff1b6-fd40-11ea-38e0-3b694162f66e
# ╟─560a4aa6-fd40-11ea-1103-7191fff677fb
# ╠═560dcb42-fd40-11ea-0b2e-f14e70a7425a
# ╟─5618ec0c-fd40-11ea-3a0f-85fb3e33f1b1
# ╠═5621e8fc-fd40-11ea-2f52-095b7196c40c
# ╠═56236592-fd40-11ea-2be2-b9b04f0ce30c
# ╠═5631855a-fd40-11ea-173a-a187c5976832
# ╠═56339584-fd40-11ea-3c75-4f679d500b1c
# ╠═563b3f8c-fd40-11ea-1d4b-3fc4eec893fa
# ╟─56426262-fd40-11ea-22a7-5bbc6089cb07
