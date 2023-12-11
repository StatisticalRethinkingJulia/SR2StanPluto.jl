### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg

# ╔═╡ 76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	# Notebook specific
	using GLM
	
	# Graphics related
	using CairoMakie

	# Causal inference support
	using GraphViz
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir, sim_happiness
	using RegressionAndOtherStories
end

# ╔═╡ 926ef957-0e39-403f-8eb4-a7f3824e74bc
md" ## 6.3 Collider bias."

# ╔═╡ 234d835c-b651-4b16-9f2e-986eda90a1a8
md"##### Set page layout for notebook."

# ╔═╡ fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 38%);
	}
</style>
"""


# ╔═╡ 6d0bdac8-a453-4574-841c-6dee7b99a053
md"## Julia code snippet 6.21"

# ╔═╡ 4659c3bc-9677-4703-8a68-f1bd546efa8e
function sim_happiness2(; seed=1977, n_years=1000, max_age=65, n_births=20, aom=18)
  isnothing(seed) || Random.seed!(seed)
  h = Float64[]; a = Int[]; m = Int[];
  for t in 1:min(n_years, max_age)
    a .+= 1
    append!(a, ones(Int, n_births))
    append!(h, range(-2, stop=2, length=n_births))
    append!(m, zeros(Int, n_births))
    can_marry = @. (m == 0) & (a >= aom)
    m[can_marry] = @. rand(Bernoulli(logistic(h[can_marry] - 4)))
  end
  DataFrame(:age=>a, :happiness=>h, :married=>m)
end


# ╔═╡ b4146171-f600-4033-99e2-7aba5db17610
begin
	df = sim_happiness()
	describe(df)
end

# ╔═╡ 46bb4fa8-923f-42e2-8333-c52673d47c37
model_summary(df, [:age, :happiness, :married])

# ╔═╡ 24cc2617-9b97-49bb-bc4e-a51270d53462
let
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Age", ylabel="Happiness")
	xlims!(ax, 0, 66)
	for i in 1:nrow(df)
		if df[i, :married] == 1
			scatter!([df[i, :age]], [df[i, :happiness]], color=:darkblue)
		else
			scatter!([df[i, :age]], [df[i, :happiness]], color=:lightgrey)
		end
	end
	f
end

# ╔═╡ cfadd300-c683-47d1-9d57-5764b20ea797
md" ### Julia code snippet 6.22"

# ╔═╡ 030a38f8-5728-43bf-9792-fa3d7d5517c0
let
	global df2 = copy(df)
	# or `df2 = filter(row -> row[:age] > 17, df2)`
	df2 = df2[df2.age .> 17, :]
	df2.A = (df2.age .- 18) / (65 - 18)
	describe(df2)
end

# ╔═╡ 1a627fb5-3ca8-4157-9496-fdd35b4c8f1c
md" ### Julia code snippet 6.23"

# ╔═╡ 6bae9ac8-6ca2-47e9-af4c-ceb5263318bf
df2.mid = df2.married .+ 1;

# ╔═╡ 39d7aa5c-e2d7-454d-b738-713224adb209
md" ## Julia code snippet 6.22"

# ╔═╡ e20117b2-69e5-4614-aeb1-85b53f18923d
stan6_9 = "
data {
	int <lower=1> N;
	vector[N] happiness;
	vector[N] A;
	int <lower=1>  k;
	array[N] int mid;
}
parameters {
	real <lower=0> sigma;
	vector[k] a;
	real bA;
}
model {
	vector[N] mu;
	sigma ~ exponential(1);
	a ~ normal(0, 1);
	bA ~ normal(0, 2);  
	for (i in 1:N) 
		mu[i] = a[mid[i]] + bA * A[i];
	happiness ~ normal(mu, sigma);
}
";

# ╔═╡ c3178101-b081-4866-bc72-8c09dc068ee0
let
	global m6_9s = SampleModel("m6.9s", stan6_9)
	data = Dict(:N => nrow(df2), :k => 2, :happiness => df2.happiness, 
		:A => df2.A, :mid => df2.mid)
	global rc6_9s = stan_sample(m6_9s; data)
	success(rc6_9s) && describe(m6_9s, [Symbol("a[1]"), Symbol("a[2]"), :bA, :sigma])
end

# ╔═╡ 825ba6f9-69a5-4df1-9526-6f966091419a
if success(rc6_9s)
	post6_9s_df = read_samples(m6_9s, :dataframe)
	rename!(post6_9s_df, Symbol("a.1") => :a_1, Symbol("a.2") => :a_2)
	ms6_9s = model_summary(post6_9s_df, [:a_1, :a_2, :bA, :sigma])
end

# ╔═╡ 436a2bac-ce0d-4b08-9e9c-cdb657dc35a6
let
	st6_9s_df = read_samples(m6_9s)
	m = matrix(st6_9s_df, :a)
	size(m)
end

# ╔═╡ d1338a23-cf1d-4041-b479-eb20d96c14e3
md" ### Julia code snippet 6.24"

# ╔═╡ 4956ef6f-fbcc-4b89-b517-82e558983cc1
stan6_10 = "
data {
	int <lower=1> N;
	vector[N] happiness;
	vector[N] A;
}
parameters {
	real <lower=0> sigma;
	real a;
	real bA;
}
model {
	vector[N] mu;
	sigma ~ exponential(1);
	a ~ normal(0, 1);
	bA ~ normal(0, 2);
	mu = a + bA * A;
	happiness ~ normal(mu, sigma);
}
";

# ╔═╡ a1e3ce01-506e-4d12-a683-d137e59296a6
let
	global m6_10s = SampleModel("m6.10s", stan6_10)
	data = Dict(:N => nrow(df2), :k => 2, :happiness => df2.happiness, 
		:A => df2.A, :mid => df2.mid)
	global rc6_10s = stan_sample(m6_10s; data)
	success(rc6_10s) && describe(m6_10s, [:a, :bA, :sigma])
end

# ╔═╡ c09c597f-6644-4994-9ccf-894dbcb1a36c
md" ### Julia code snippet 6.25 and 6.26"

# ╔═╡ 76f8fb35-e3c8-437b-8f83-bc2bed62184f
let
	N = 2000
	b_GP = 1
	b_GC = 0
	b_PC = 1
	b_U = 2
	U = 2 * rand(Bernoulli(0.5), N) .- 1
	G = rand(Normal(), N)
	P = [rand(Normal(b_GP * G[i] + b_U * U[i]), 1)[1] for i in 1:N]
	C = [rand(Normal(b_PC * P[i] + b_GC * G[i] + b_U * U[i]), 1)[1] for i in 1:N]
	global df3 = DataFrame(C = C, P = P, G = G, U = U)
end

# ╔═╡ 29bdd1fd-1ad7-4aa5-9f2f-6657e8651bec
md" ### Julia code snippet 6.27"

# ╔═╡ f8289a9a-8548-464e-b32a-6aaf1eb5c387
stan6_11 = "
data {
	int N;
	vector[N] P;
	vector[N] G;
	vector[N] C;
}
parameters {
	real a;
	real b_PC;
	real b_GC;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	a ~ normal(0, 1);
	b_PC ~ normal(0, 1);
	b_GC ~ normal(0, 1);
	sigma ~ exponential(1);
	mu = a + b_PC * P + b_GC * G;
	C ~ normal(mu, sigma);
}
";

# ╔═╡ e84d9b61-c59a-47ff-82a2-1bb76618778b
let
	global m6_11s = SampleModel("m6.11s", stan6_11)
	data = Dict(:N => nrow(df3), :P => df3.P, :G => df3.G, :C => df3.C)
	global rc6_11s = stan_sample(m6_11s; data)
	success(rc6_11s) && describe(m6_11s, [:a, :b_PC, :b_GC, :sigma])
end

# ╔═╡ 6b3389b4-5c98-462e-8293-6866623f848b
if success(rc6_11s)
	post6_11s_df = read_samples(m6_11s, :dataframe)
	ms6_11s_df = model_summary(post6_11s_df, [:a, :b_PC, :b_GC, :sigma])
end

# ╔═╡ df75b867-449f-4d83-b361-d23274cc919b
let
	x = -3:0.01:3
	scale_df_cols!(df3, [:C, :P, :G, :U])
	q = quantile(df3[:, :P_s], [0.45, 0.60])
	pset = Int[]
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1 ,1];)
	for (i, r) in enumerate(eachrow(df3))
		if r.U > 0.0
			if q[1] < r.P_s < q[2]
				append!(pset, i)
				scatter!(r.G_s, r.C_s; color=:darkblue)
			else
				scatter!(r.G_s, r.C_s; color=:lightblue)
			end
		else
			if q[1] < r.P_s < q[2]
				append!(pset, i)
				scatter!(r.G_s, r.C_s; color=:darkred)
			else
				scatter!(r.G_s, r.C_s; color=:lightgrey)
			end	
		end
	end
	l = lm(@formula(G ~ C), df3[pset,:])
	c = coef(l)
	lines!(x, c[1] .+ c[2] .* x)
	f
end

# ╔═╡ 393b33bc-130a-45c4-ac42-578d9dccf135
md" ### Julia code snippet 6.28"

# ╔═╡ 0057e16c-ea97-4a8c-a888-b27f2d08f344
stan6_12 = "
data {
	int N;
	vector[N] P;
	vector[N] G;
	vector[N] C;
	vector[N] U;
}
parameters {
	real a;
	real b_PC;
	real b_GC;
	real b_U;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	a ~ normal(0, 1);
	b_PC ~ normal(0, 1);
	b_GC ~ normal(0, 1);
	b_U ~ normal(0, 1);
	sigma ~ exponential(1);
	mu = a + b_PC * P + b_GC * G + b_U * U;
	C ~ normal(mu, sigma);
}
";

# ╔═╡ 06e202d7-29f2-4d3e-ab50-53e968f551e3
let
	global m6_12s = SampleModel("m6.12s", stan6_12)
	data = Dict(:N => nrow(df3), :P => df3.P, :G => df3.G, :C => df3.C, :U => df3.U)
	global rc6_12s = stan_sample(m6_12s; data)
	success(rc6_12s) && describe(m6_12s, [:a, :b_PC, :b_GC, :b_U, :sigma])
end

# ╔═╡ Cell order:
# ╟─926ef957-0e39-403f-8eb4-a7f3824e74bc
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─6d0bdac8-a453-4574-841c-6dee7b99a053
# ╠═4659c3bc-9677-4703-8a68-f1bd546efa8e
# ╠═b4146171-f600-4033-99e2-7aba5db17610
# ╠═46bb4fa8-923f-42e2-8333-c52673d47c37
# ╠═24cc2617-9b97-49bb-bc4e-a51270d53462
# ╟─cfadd300-c683-47d1-9d57-5764b20ea797
# ╠═030a38f8-5728-43bf-9792-fa3d7d5517c0
# ╟─1a627fb5-3ca8-4157-9496-fdd35b4c8f1c
# ╠═6bae9ac8-6ca2-47e9-af4c-ceb5263318bf
# ╟─39d7aa5c-e2d7-454d-b738-713224adb209
# ╠═e20117b2-69e5-4614-aeb1-85b53f18923d
# ╠═c3178101-b081-4866-bc72-8c09dc068ee0
# ╠═825ba6f9-69a5-4df1-9526-6f966091419a
# ╠═436a2bac-ce0d-4b08-9e9c-cdb657dc35a6
# ╟─d1338a23-cf1d-4041-b479-eb20d96c14e3
# ╠═4956ef6f-fbcc-4b89-b517-82e558983cc1
# ╠═a1e3ce01-506e-4d12-a683-d137e59296a6
# ╟─c09c597f-6644-4994-9ccf-894dbcb1a36c
# ╠═76f8fb35-e3c8-437b-8f83-bc2bed62184f
# ╟─29bdd1fd-1ad7-4aa5-9f2f-6657e8651bec
# ╠═f8289a9a-8548-464e-b32a-6aaf1eb5c387
# ╠═e84d9b61-c59a-47ff-82a2-1bb76618778b
# ╠═6b3389b4-5c98-462e-8293-6866623f848b
# ╠═df75b867-449f-4d83-b361-d23274cc919b
# ╟─393b33bc-130a-45c4-ac42-578d9dccf135
# ╠═0057e16c-ea97-4a8c-a888-b27f2d08f344
# ╠═06e202d7-29f2-4d3e-ab50-53e968f551e3
