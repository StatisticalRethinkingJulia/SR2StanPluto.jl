### A Pluto.jl notebook ###
# v0.12.20

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
md" ## Clip-07-16-18.2s.jl"

# ╔═╡ 5f749200-6757-11eb-0345-6b094802c649
function logprob(post_df::DataFrame, x::Matrix, y::Vector, k=k)
	b = Matrix(hcat(post_df[:, [Symbol("b.$i") for i in 1:k]]))
	mu = post_df.a .+ b * x[:, 1:k]'
    logpdf.(Normal.(mu , post_df.sigma),  y')
end

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
	L = 100 					    # Number of simulations
	K = 5 						# Number of slopes
	dev_is = zeros(L, K)
	dev_os = zeros(L, K)
	res = Vector{NamedTuple}(undef, length(Ns))
end;

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
					loo_lp_is, _, _ = psisloo(lp_train)
					dev_is[i, j] = -2loo_lp_is
					lp_test = logprob(post7_9s_df, x_test, y, j)
					loo_lp_is, _, _ = psisloo(lp_test)
					dev_os[i, j] = -2loo_lp_is

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
		ylims = i == 1 ? (0,170) : (200, 400)
		fig[i] = scatter(xcoord, ycoord, xlab = "No of b parameters",
			ylab = "Deviance", ylims = ylims, leg=:bottomleft,
			lab = "In sample", markersize=2)
		for j in 1:K
			plot!([xcoord[j], xcoord[j]],
				[ycoord[j]-res[i].std_dev_is[j], ycoord[j]+res[i].std_dev_is[j]],
				lab=false, color=:darkblue)
		end
		title!("N = $(Ns[i])")
		xcoord = collect(1:K) .+ 0.05
		ycoord = res[i].mean_dev_os[1,:]
		scatter!(xcoord, ycoord, lab = "Out of sample", markersize=2)
		for j in 1:K
			plot!([xcoord[j], xcoord[j]],
				[ycoord[j]-res[i].std_dev_os[j], ycoord[j]+res[i].std_dev_os[j]],
				lab=false, color=:red)
		end
		title!("N = $(Ns[i])")
	end
	plot(fig..., layout=(1,2))
end

# ╔═╡ 67d8698e-6faf-11eb-18f7-318ec55c1c7a
begin
	devs = Vector{Float64}(undef, 2)
	y, x_train, x_test = sim_train_test(;N=100, K=5, rho)
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

# ╔═╡ 08703112-6fb0-11eb-28d7-83dcab6b1998
md"
!!! note
	In some runs, out-of-sample deviance can be much larger than PSIS and WAIC estimates. In-sample deviance is always lower than PSIS and WAIC estimates. Re-run above cell several times to see this.
"

# ╔═╡ 8ffcd37a-6faf-11eb-329f-fb9ddfe5247c
Text("In-sample deviance = $(devs[1]), out-of-sample deviance = $(devs[2])")

# ╔═╡ 8ffd04ee-6faf-11eb-1e4b-f13d4d3bfe9c
if success(rc7_9s)
	waic(m7_9s)
end

# ╔═╡ 8ffdaed0-6faf-11eb-36fc-47790fcae672
if success(rc7_9s)
	loo7_9s, loos7_9s, pk7_9s = psisloo(m7_9s)
	-2loo7_9s
end

# ╔═╡ 74d4016e-6563-11eb-0c3b-b7c4f81baca6
md" ## End of clip-07-16-18.2s.jl"

# ╔═╡ Cell order:
# ╟─a4042486-5bf5-11eb-0183-33fd00d868e4
# ╠═265ed188-5bf6-11eb-0d29-51ea74e6c7d1
# ╠═ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
# ╠═5f749200-6757-11eb-0345-6b094802c649
# ╠═ac8227b2-5bf6-11eb-27dd-09924b99e6c2
# ╠═00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
# ╠═5d5b8982-64b2-11eb-0ca9-b94e3197ff31
# ╠═f253787c-64c3-11eb-2cd4-9322707100b7
# ╠═7eb8b028-657f-11eb-0abf-37c3819aea78
# ╠═67d8698e-6faf-11eb-18f7-318ec55c1c7a
# ╟─08703112-6fb0-11eb-28d7-83dcab6b1998
# ╠═8ffcd37a-6faf-11eb-329f-fb9ddfe5247c
# ╠═8ffd04ee-6faf-11eb-1e4b-f13d4d3bfe9c
# ╠═8ffdaed0-6faf-11eb-36fc-47790fcae672
# ╟─74d4016e-6563-11eb-0c3b-b7c4f81baca6
