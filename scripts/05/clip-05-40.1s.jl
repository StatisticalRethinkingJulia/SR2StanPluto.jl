
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

if success(rc)
	dfa5 = read_samples(m5_5s; output_format=:dataframe)
	title5 = "Kcal_per_g vs. neocortex_perc" * "\n89% predicted and mean rangep1 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		dfa5, [:a, :bN, :sigma];
		title=title5
	)
end

if success(rc)
	dfa6 = read_samples(m5_6s; output_format=:dataframe)
	title6 = "Kcal_per_g vs. log mass" * "\n89% predicted and mean range"
	p2 = plotbounds(
		df, :lmass, :kcal_per_g,
		dfa6, [:a, :bM, :sigma];
		title=title6
	)
end

if success(rc)
	dfa7 = read_samples(m5_7s; output_format=:dataframe)
	title7 = "Counterfactual,\nholding M=0.0"
	p3 = plotbounds(
		df, :neocortex_perc, :kcal_per_g,
		dfa7, [:a, :bN, :sigma];
		title=title7
	)
end

if success(rc)
	title8 = "Counterfactual,\nholding N=0.0"
	p4 = plotbounds(
		df, :lmass, :kcal_per_g,
		dfa7, [:a, :bM, :sigma];
		title=title8,
		xlab="log(mass)"
	)
end

plot(p1, p2, p3, p4, layout=(2, 2))

md"## End of clip-05-40.1s.jl"

