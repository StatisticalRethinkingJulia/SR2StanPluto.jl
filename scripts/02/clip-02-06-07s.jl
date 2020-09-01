# Clip-02-06-07.jl

cd(@__DIR__)
using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking
using Optim

include(projectdir("src", "quap.jl"))

# ### snippet 2.6

# Grid of 1001 steps

p_grid = range(0, step=0.001, stop=1);

# all priors = 1.0

prior = ones(length(p_grid));

# Binomial pdf

likelihood = [pdf(Binomial(9, p), 6) for p in p_grid];

# As Uniform prior has been used, unstandardized posterior is equal to likelihood

posterior = likelihood .* prior;

# Scale posterior such that they become probabilities

posterior = posterior / sum(posterior);

# ### snippet 3.3

# Sample using the computed posterior values as weights

N = 10000
samples = sample(p_grid, Weights(posterior), N);
chn = MCMCChains.Chains(reshape(samples, N, 1, 1), ["toss"]);

# Describe the chain

chn |> display

# Compute the MAP (maximum_a_posteriori) estimate

x0 = [0.5]
lower = [0.0]
upper = [1.0]

function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), repeat([6], 1))))
  -ll
end

opt = optimize(loglik, lower, upper, x0, Fminbox(GradientDescent()))
qmap = Optim.minimizer(opt)

# Show optimization results

opt |> display

# Fit quadratic approcimation

quapfit = [qmap[1], std(samples, mean=qmap[1])]

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)

# analytical calculation

w = 6
n = 9
x = 0:0.01:1
p[1] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0), 
  lab="Conjugate solution", leg=:topleft)
density!(p[1], samples, lab="Sample density")

# Distribution estimates copied from Turing quap()
d = Normal{Float64}(0.6666666666666666, 0.15713484026367724)

# quadratic approximation using Optim

p[2] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
  lab="Conjugate solution", leg=:topleft)
plot!( p[2], x, pdf.(Normal( quapfit[1], quapfit[2] ) , x ),
  lab="Optim logpdf approx.")
plot!(p[2], x, pdf.(d, x), lab="Turing quap approx.")

# quadratic approximation using StatisticalRethinking.jl quap()

df = DataFrame(:toss => samples)
q = quap(df)
p[3] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
  lab="Conjugate solution", leg=:topleft)
plot!( p[3], x, pdf.(Normal(mean(q.toss), std(q.toss) ) , x ),
  lab="Stan quap approx.")
plot!(p[3], x, pdf.(d, x), lab="Turing quap approx.")

# ### snippet 2.7

w = 6; n = 9; x = 0:0.01:1
p[4] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), xlims=(-0.5, 1.0),
  lab="Conjugate solution", leg=:topleft)
f = fit(Normal, samples)
plot!(p[4], x, pdf.(Normal( f.μ , f.σ ) , x ), lab="Normal MLE approx.")
plot(p..., layout=(2, 2))
savefig(plotsdir("02", "Fig2.8.png"))

# End of clip-02-06-07.jl
