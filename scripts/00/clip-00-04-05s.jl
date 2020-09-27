
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## clip-00-04-05s.jl"

md"##### Load packages."

md"### snippet 0.4"

begin
	df = (CSV.read(sr_path("..", "data", "Howell1.csv"), DataFrame; delim=';'))
	howell1 = filter(row -> row[:age] >= 18, df);
end

Text(precis(howell1; io = String))

md"##### Fit a linear regression of weight on height."

m = lm(@formula(height ~ weight), howell1)

md"##### Plot residuals against height."

scatter( howell1.height, residuals(m), xlab="Height",
  ylab="Model residual values", lab="Model residuals", leg=:bottomright)

md"## End of clip-00-04-05s.jl"

