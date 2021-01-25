### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 265ed188-5bf6-11eb-0d29-51ea74e6c7d1
using Pkg, DrWatson

# ╔═╡ ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ a4042486-5bf5-11eb-0183-33fd00d868e4
md" ## Clip-07-18s.jl"

# ╔═╡ ac6f6634-5bf6-11eb-0929-b5ed20ab3036
function sim_train_test(;
    N = 20,
	k = 3,
    rho = [0.15, -0.4], 
    b_sigma = 100,
    WAIC = false, LOOCV=false, LOOIC=false,
    return_model=false ) 

    n_dim = 1 + length(rho)
    n_dim = n_dim < k ? k : n_dim
	
    Rho = Matrix{Float64}(I, n_dim, n_dim)
    for i in 1:length(rho)
        Rho[i+1, 1] = Rho[1, i + 1] = rho[i]
    end
	
    x_train = Matrix(rand(MvNormal(zeros(n_dim), Rho), N)')
    x_test = Matrix(rand(MvNormal(zeros(n_dim), Rho), N)')
	mm_train = hcat(ones(N, 1), x_train[:, 2:end])

    (x_train[:, 1], mm_train, x_test)
end

# ╔═╡ ac8227b2-5bf6-11eb-27dd-09924b99e6c2
stan7_9 = "
data{
    int N;
    int K;
    vector[N] y;
    matrix[N, K] x;
}
parameters{
    vector[K] b;
}
transformed parameters{
    vector[N] mu;
    mu = x * b;
}
model{
    b ~ normal(0, 1);
    y ~ normal(mu, 1);
}
generated quantities{
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(y[i] | mu[i], 1);
}
";

# ╔═╡ 00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
m7_9s = SampleModel("m7.9s", stan7_9);

# ╔═╡ ac70047c-5bf6-11eb-2568-5de8d3bbcc19
begin
	#Random.seed!(1)
	y, mm_train, x_test = sim_train_test()
	data = (N = length(y), K = size(mm_train, 2), y = y, x = mm_train)
	rc7_9s = stan_sample(m7_9s; data)
end;

# ╔═╡ 31d58d4a-5c28-11eb-2d51-a3e319d177bd
size(mm_train)

# ╔═╡ 3ed00d40-5c23-11eb-1e3c-a9acf5904186
lm(mm_train, y)

# ╔═╡ cf9f86a6-5bf7-11eb-27e6-57972b914694
if success(rc7_9s)
	nt7_9s = read_samples(m7_9s)
	post7_9s_df = read_samples(m7_9s; output_format=:dataframe)
	PRECIS(post7_9s_df[:, [Symbol("b.1"), Symbol("b.2"), Symbol("b.3")]])
end

# ╔═╡ Cell order:
# ╠═a4042486-5bf5-11eb-0183-33fd00d868e4
# ╠═265ed188-5bf6-11eb-0d29-51ea74e6c7d1
# ╠═ac6f2dfc-5bf6-11eb-3dc0-b5368b466ff7
# ╠═ac6f6634-5bf6-11eb-0929-b5ed20ab3036
# ╠═ac8227b2-5bf6-11eb-27dd-09924b99e6c2
# ╠═00ee9dc0-5c23-11eb-10c3-1dfb4f486e6f
# ╠═ac70047c-5bf6-11eb-2568-5de8d3bbcc19
# ╠═31d58d4a-5c28-11eb-2d51-a3e319d177bd
# ╠═3ed00d40-5c23-11eb-1e3c-a9acf5904186
# ╠═cf9f86a6-5bf7-11eb-27e6-57972b914694
