
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

md"## Intro-logpdf-2s.jl"

md"##### This script shows clip-04-26-29s.jl using Optim and a loglik function."

md"## snippet 4.26"

begin
	df = DataFrame(CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';'))
	df2 = filter(row -> row[:age] >= 18, df)
end;

md"## snippet 4.27"


stan4_1 = "
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
";

md"## snippet 4.28"

function loglik(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 20), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(logpdf.(Normal(x[1], x[2]), df2.height))
  -ll
end

md"## snippet 4.29"


begin
	lower = [0.0, 0.0]
	upper = [250.0, 50.0]
	x0 = [170.0, 10.0]
end

res = optimize(loglik, lower, upper, x0)

Optim.minimizer(res)


stan4_2 = "
  μ ~ Normal(178, 0.1) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
";

function loglik2(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 0.1), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(logpdf.(Normal(x[1], x[2]), df2.height))
  -ll
end

x1 = [178.0, 40.0] # Initial values can't be outside the the box.

res2 = optimize(loglik2, lower, upper, x1)

Optim.minimizer(res2)

md"##### Notice the increase of σ."

md"## End of intro-logpdfs-2.jl"

