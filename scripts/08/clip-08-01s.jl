
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

using RDatasets

md" ## Clip-08-01s.jl"

md"
!!! tip
	Packages RDatasets is obtained from primary environment.
"

begin
	df = dataset("datasets", "iris")
end

describe(df)



md" ## End of clip-08-01s.jl"

