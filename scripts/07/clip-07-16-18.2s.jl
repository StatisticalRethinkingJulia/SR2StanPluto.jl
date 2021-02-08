
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-16-18as.jl"

function logprob(post_df::DataFrame, x::Matrix, y::Vector, k=k)
	b = Matrix(hcat(post_df[:, [Symbol("b.$i") for i in 1:k]]))
	mu = post_df.a .+ b * x[:, 1:k]'
    logpdf.(Normal.(mu , post_df.sigma),  y')
end

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
";

begin
	tmpdir = joinpath(projectdir(), "tmp")
	m7_9s = SampleModel("m7.9s", stan7_9; tmpdir)
end;

begin
	Ns = [20, 100] 				# Number of observations
	rho = [0.15, -0.4]			# Covariance between x1 and x2
	L = 100 					    # Number of simulations
	K = 5 						# Number of slopes
	dev_is = zeros(L, K)
	dev_os = zeros(L, K)
	res = Vector{NamedTuple}(undef, length(Ns))
end;

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
					
					post7_9s_df = read_samples(m7_9s; output_format=:dataframe)
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

md" ## End of clip-07-16-18as.jl"

