
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-06-21s.jl"

df = sim_happiness();

Text(precis(df; io=String))

md"## End of clip-06-21s.jl"

