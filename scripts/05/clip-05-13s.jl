
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.3s.jl"))

md"## Clip-05-13s.jl"

if success(rc5_3s)
	begin
		post5_3s_df = read_samples(m5_3s; output_format=:dataframe)

		# Rethinking results

		rethinking_results = "
			   mean   sd  5.5% 94.5%
		a      0.00 0.10 -0.16  0.16
		bM    -0.07 0.15 -0.31  0.18
		bA    -0.61 0.15 -0.85 -0.37
		sigma  0.79 0.08  0.66  0.91
		";

		title = "Divorce rate vs. Marriage rate" * "\nshowing predicted and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			post5_3s_df, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey],
			bounds=[:predicted, :hpdi]
		)
	end
end

md"## End of clip-05-13s.jl"

