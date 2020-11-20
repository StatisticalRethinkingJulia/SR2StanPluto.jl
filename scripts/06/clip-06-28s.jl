
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "06", "m6.11s.jl"));

md"## Clip-06-28s.jl"

begin
	N = 200
	b_GP = 1                               # Direct effect of G on P
	b_GC = 0                               # Direct effect of G on C
	b_PC = 1                               # Direct effect of P on C
	b_U = 2                                # Direct effect of U on P and C
	df = DataFrame(
	  :u => 2 * rand(Bernoulli(0.5), N) .- 1,
	  :g => rand(Normal(), N)
	)
	df[!, :p] = [rand(Normal(b_GP * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]
	df[!, :c] = [rand(Normal(b_PC * df[i, :p] + b_GC * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]
	Text(precis(df; io=String))
end

stan6_12 = "
data {
  int <lower=0> N;
  vector[N] C;
  vector[N] P;
  vector[N] G;
  vector[N] U;
}
parameters {
  real <lower=0> sigma;
  real a;
  real b_PC;
  real b_GC;
  real b_U;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  b_PC ~ normal(0, 1);
  b_GC ~ normal(0, 1);
  b_U ~ normal(0, 1);
  mu = a + b_PC * P + b_GC * G + b_U * U;
  C ~ normal(mu, sigma);
}
";

begin
	m6_12s = SampleModel("m6.12s", stan6_12)
	m6_12_data = Dict(
	  :N => nrow(df),
	  :C => df[:, :c],
	  :P => df[:, :p],
	  :G => df[:, :g],
	  :U => df[:, :u]
	)
	rc6_12s = stan_sample(m6_12s, data=m6_12_data)
	post6_12s_df = read_samples(m6_12s, output_format=:dataframe)
	Text(precis(post6_12s_df; io=String))
end

if success(rc6_12s)
	(s6_12s, p6_12s) = plotcoef([m6_11s, m6_12s], [:a, :b_PC, :b_GC, :b_U])
	p6_12s
end

s6_12s

if success(rc6_12s)
  scale!(df, [:g, :c, :p])
  q = quantile(df[:, :p_s], [0.45, 0.60])

  function is_in(v::Vector, q::Vector)
    findall(x -> q[1] < x < q[2], v)
  end

  v = is_in(df[:, :p], q)

  df1 = DataFrame(
    :c_s => df[v, :c_s],
    :g_s => df[v, :g_s]
  )

  ols = lm(@formula(c_s ~ g_s), df1)

  plot(xlab="grandparent education (g)", ylab="grandchild education (c)", leg=false)
  for i in 1:nrow(df)
    if df[i, :u] == -1
      if df[i, :p] >= q[1] && df[i, :p] <= q[2]
        scatter!([df[i, :g_s]], [df[i, :c_s]], color=:blue)
      else
        scatter!([df[i, :g_s]], [df[i, :c_s]], color=:lightgrey)
      end
    else
      if df[i, :p] >= q[1] && df[i, :p] <= q[2]
        scatter!([df[i, :g_s]], [df[i, :c_s]], color=:blue)
      else
        scatter!([df[i, :g_s]], [df[i, :c_s]], color=:lightblue)
      end
    end
  end

  x = -3:0.01:3
  plot!(x, coef(ols)[1] .+ coef(ols)[2] * x, color=:black)

end

md"## End of clip-06-28s.jl"

