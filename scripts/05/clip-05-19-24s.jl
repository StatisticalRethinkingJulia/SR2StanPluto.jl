
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using GLM
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.3.As.jl"))

md"## Clip-05-19-24s.jl"

md"##### Include snippets 5.19-5.21."


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

part5_3_As = Particles(dfa5_3_As)

md"## Snippet 5.22"

a_seq = range(-2, stop=2, length=100);

md"## Snippet 5.23"

m_sim, d_sim = simulate(dfa5_3_As, [:aM, :bAM, :sigma_M], a_seq, [:bM, :sigma]);

md"## Snippet 5.24"

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

md"##### M -> D"

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

plot(fig1, fig2, fig3, layout=(3, 1))

md"## End of clip-05-19-24s.jl"

