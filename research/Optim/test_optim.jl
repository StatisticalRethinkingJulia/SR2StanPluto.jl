using Distributions, Optim

x0 = [0.5]
lower = [0.0]
upper = [1.0]

function loglik(x)
  println(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), repeat([6], 1))))
  -ll
end

optimize(loglik, 0.0, 1.0)

