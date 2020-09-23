
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.2s.jl"))

md"## Clip-05-06-09s.jl"

if success(rc)
	dfs = read_samples(m5_2s; output_format=:dataframe)
	p_m_5_2 = Particles(dfs) 
	p_m_5_2
end

success(rc) && quap(dfs)


rethinking_results = "
	  mean   sd  5.5% 94.5%
a     0.00 0.11 -0.17  0.17
bM    0.35 0.13  0.15  0.55
sigma 0.91 0.09  0.77  1.05
";

if success(rc)
	begin
		title = "Divorce rate vs. Marriage rate" * "\nshowing sample and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			dfs, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey]
		)
	end
end

md"## End of clip-05-06-10s.jl"

