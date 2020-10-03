
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

for i in 5:7
	include(projectdir("models", "05", "m5.$(i)s.jl"))
end

md"## Clip-05-40.1s.jl"

md"### snippet 5.39"

if success(rc5_5s)
	dfa5_5s = read_samples(m5_5s; output_format=:dataframe)
	title5 = "Kcal_per_g vs. neocortex_perc" * "\n89% predicted and mean range"
	fig1 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		dfa5_5s, [:a, :bN, :sigma];
		title=title5
	)
end

if success(rc5_6s)
	dfa5_6s = read_samples(m5_6s; output_format=:dataframe)
	title6 = "Kcal_per_g vs. log mass" * "\n89% predicted and mean range"
	fig2 = plotbounds(
		df, :lmass, :kcal_per_g,
		dfa5_6s, [:a, :bM, :sigma];
		title=title6
	)
end

if success(rc5_7s)
	dfa5_7s = read_samples(m5_7s; output_format=:dataframe)
	title7 = "Counterfactual,\nholding M=0.0"
	fig3 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		dfa5_7s, [:a, :bN, :sigma];
		title=title7
	)
end

if success(rc5_7s)
	title8 = "Counterfactual,\nholding N=0.0"
	fig4 = plotbounds(
		df, :lmass, :kcal_per_g,
		dfa5_7s, [:a, :bM, :sigma];
		title=title8,
		xlab="log(mass)"
	)
end

plot(fig1, fig2, fig3, fig4, layout=(2, 2))

md"## End of clip-05-40.1s.jl"

