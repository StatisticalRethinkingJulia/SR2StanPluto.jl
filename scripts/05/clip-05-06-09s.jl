
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

if success(rc5_2s)
	post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
	part5_2s = Particles(post5_2s_df) 
end

success(rc5_2s) && quap(post5_2s_df)


rethinking_results = "
	  mean   sd  5.5% 94.5%
a     0.00 0.11 -0.17  0.17
bM    0.35 0.13  0.15  0.55
sigma 0.91 0.09  0.77  1.05
";

if success(rc5_2s)
	begin
		title = "Divorce rate vs. Marriage rate" * "\nshowing sample and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			post5_2s_df, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey]
		)
	end
end

md"## End of clip-05-06-10s.jl"

