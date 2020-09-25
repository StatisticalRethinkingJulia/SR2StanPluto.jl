
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
	using Optim
end

md"## Intro-logpdf-2s.jl"

md"##### This scirpt shows clip-04-26-29s.jl using Optim and a loglik function."


begin
	df = DataFrame(CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';'))
	df2 = filter(row -> row[:age] >= 18, df)
end;



m4_1 = "
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
"



obs = df2[:, :height]

function loglik(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 20), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(log.(pdf.(Normal(x[1], x[2]), obs)))
  -ll
end



begin
	lower = [0.0, 0.0]
	upper = [250.0, 50.0]
	x0 = [170.0, 10.0]
end

res = optimize(loglik, lower, upper, x0)

Optim.minimizer(res)


m4_2 = "
  μ ~ Normal(178, 0.1) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
";

function loglik2(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 0.1), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(log.(pdf.(Normal(x[1], x[2]), obs)))
  -ll
end

x1 = [178.0, 40.0] # Initial values can't be outside the the box.

optimize(loglik2, lower, upper, x1)

md"##### Notice the increase of σ."

md"## End of intro-logpdfs-2.jl"

