### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 265ed188-5bf6-11eb-0d29-51ea74e6c7d1
using Pkg

# ╔═╡ ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
begin
	using Distributions
	using StatsPlots
	using StatsBase
	using LaTeXStrings
	using CSV
	using DataFrames
	using LinearAlgebra
	using Random
	using ParetoSmoothedImportanceSampling
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ a4042486-5bf5-11eb-0183-33fd00d868e4
md" ## Clip-07-16-18.1s.jl"

# ╔═╡ ac8227b2-5bf6-11eb-27dd-09924b99e6c2
stan7_9 = "
data {
    int<lower=1> K;
    int<lower=0> N;
    matrix[N, K] x;
    vector[N] y;
}
parameters {
    real a;
    vector[K] b;
    real<lower=0> sigma;
}
transformed parameters {
    vector[N] mu;
    mu = a + x * b;
}
model {
	a ~ normal(0, 100);
	b ~ normal(0, 10);
	sigma ~ exponential(1);
    y ~ normal(mu, sigma);          // observed model
}
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(y[i] | mu[i], sigma);
}
";

# ╔═╡ 00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
begin
	tmpdir = joinpath(projectdir(), "tmp")
	m7_9s = SampleModel("m7.9s", stan7_9; tmpdir)
end;

# ╔═╡ 5d5b8982-64b2-11eb-0ca9-b94e3197ff31
begin
	Ns = [20, 100] 				# Number of observations
	rho = [0.15, -0.4]			# Covariance between x1 and x2
	L = 50 					    # Number of simulations
	K = 5 						# Number of slopes
	dev_is = zeros(L, K)
	dev_os = zeros(L, K)
	res = Vector{NamedTuple}(undef, length(Ns))
end;

# ╔═╡ 51b7be24-6fad-11eb-3c67-d53dcaf1ada6
md"
!!! note
	This might take some time ...
"

# ╔═╡ f253787c-64c3-11eb-2cd4-9322707100b7
begin
	for (ind, N) in enumerate(Ns)
		for i in 1:L
			for j = 1:K
				println("N = $(Ns[ind]), run = $i, no of b parms = $j")
				y, x_train, x_test = sim_train_test(;N, K, rho)
				data = (N = size(x_train, 1), K = size(x_train, 2),
					y = y, x = x_train,
					N_new = size(x_test, 1), x_new = x_test)
				rc7_9s = stan_sample(m7_9s; data)
				if success(rc7_9s)
					
					# use `logprob()`
					
					post7_9s_df = read_samples(m7_9s, :dataframe)
					lp_train = logprob(post7_9s_df, x_train, y, j)
					dev_is[i, j] = -2sum(lppd(lp_train))
					lp_test = logprob(post7_9s_df, x_test, y, j)
					dev_os[i, j] = -2sum(lppd(lp_test))

				end
			end
		end
		res[ind] = (
			mean_dev_is = mean(dev_is, dims=1),
			std_dev_is = std(dev_is, dims=1),
			mean_dev_os = mean(dev_os, dims=1),
			std_dev_os =std(dev_os, dims=1)
		)
	end
end;

# ╔═╡ 7eb8b028-657f-11eb-0abf-37c3819aea78
begin
	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
	for i in 1:2
		xcoord = collect(1:K) .- 0.05
		ycoord = res[i].mean_dev_is[1,:]
		ylims = i == 1 ? (0,100) : (200, 350)
		fig[i] = scatter(xcoord, ycoord, xlab = "No of b parameters",
			ylab = "Deviance", ylims = ylims, leg=:bottomleft,
			lab = "In sample", markersize=2)
		for j in 1:K
			plot!([xcoord[j], xcoord[j]],
				[ycoord[j]-res[i].std_dev_is[j], ycoord[j]+res[i].std_dev_is[j]],
				lab=false, color=:darkblue)
		end
		title!("N = $(Ns[i]), L = $(L)")
		xcoord = collect(1:K) .+ 0.05
		ycoord = res[i].mean_dev_os[1,:]
		scatter!(xcoord, ycoord, lab = "Out of sample", markersize=2)
		for j in 1:K
			plot!([xcoord[j], xcoord[j]],
				[ycoord[j]-res[i].std_dev_os[j], ycoord[j]+res[i].std_dev_os[j]],
				lab=false, color=:red)
		end
		title!("N = $(Ns[i]), L = $(L)")
	end
	plot(fig..., layout=(1,2))
end

# ╔═╡ 918392e8-6888-11eb-344d-8d15802cfcac
res

# ╔═╡ 3f775c58-6fa1-11eb-3c36-dd192855ec6b
md"
!!! note
	Compare waic and psis estimates to in-sample estimate
"

# ╔═╡ 73872126-6f9d-11eb-027e-e3e81ada62b7
begin
	devs = Vector{Float64}(undef, 2)
	y, x_train, x_test = sim_train_test(;N=20, K=5, rho)
	data = (N = size(x_train, 1), K = size(x_train, 2),
		y = y, x = x_train,
		N_new = size(x_test, 1), x_new = x_test)
	rc7_9s = stan_sample(m7_9s; data)
	if success(rc7_9s)

		# use `logprob()`

		post7_9s_df = read_samples(m7_9s, :dataframe)
		lp_train = logprob(post7_9s_df, x_train, y, 2)
		devs[1] = -2sum(lppd(lp_train))
		lp_test = logprob(post7_9s_df, x_test, y, 2)
		devs[2] = -2sum(lppd(lp_test))
	end
end;

# ╔═╡ 28ce4ce2-6f9e-11eb-037c-85da29a882e3
devs

# ╔═╡ 5e6d444e-6f9f-11eb-2832-558bbc4303dc
if success(rc7_9s)
	waic(m7_9s)
end

# ╔═╡ 66ceb86a-6fa2-11eb-224d-9f617f07019d
if success(rc7_9s)
	loo7_9s, loos7_9s, pk7_9s = psisloo(m7_9s)
	-2loo7_9s
end

# ╔═╡ 72523564-6f9f-11eb-1481-1f7df6e36dfb
# Use `generated quantities`

if success(rc7_9s)
	nt7_9s = read_samples(m7_9s, :namedtuple)
	-2sum(lppd(nt7_9s.log_lik'))
end

# ╔═╡ 74d4016e-6563-11eb-0c3b-b7c4f81baca6
md" ## End of clip-07-16-18.1s.jl"

# ╔═╡ Cell order:
# ╟─a4042486-5bf5-11eb-0183-33fd00d868e4
# ╠═265ed188-5bf6-11eb-0d29-51ea74e6c7d1
# ╠═ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
# ╠═ac8227b2-5bf6-11eb-27dd-09924b99e6c2
# ╠═00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
# ╠═5d5b8982-64b2-11eb-0ca9-b94e3197ff31
# ╟─51b7be24-6fad-11eb-3c67-d53dcaf1ada6
# ╠═f253787c-64c3-11eb-2cd4-9322707100b7
# ╠═7eb8b028-657f-11eb-0abf-37c3819aea78
# ╠═918392e8-6888-11eb-344d-8d15802cfcac
# ╟─3f775c58-6fa1-11eb-3c36-dd192855ec6b
# ╠═73872126-6f9d-11eb-027e-e3e81ada62b7
# ╠═28ce4ce2-6f9e-11eb-037c-85da29a882e3
# ╠═5e6d444e-6f9f-11eb-2832-558bbc4303dc
# ╠═66ceb86a-6fa2-11eb-224d-9f617f07019d
# ╠═72523564-6f9f-11eb-1481-1f7df6e36dfb
# ╟─74d4016e-6563-11eb-0c3b-b7c4f81baca6
