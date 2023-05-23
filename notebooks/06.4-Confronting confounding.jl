### A Pluto.jl notebook ###
# v0.19.26

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
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir, PRECIS, sim_happiness
	using RegressionAndOtherStories
end

# ╔═╡ 926ef957-0e39-403f-8eb4-a7f3824e74bc
md" ## 6.4 Confronting confounding."

# ╔═╡ 02f785db-8232-4274-828f-22902be25af4
md" ### Shutting the backdoor."

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

# ╔═╡ 9e068b40-6de7-49e5-8e89-0e26f9c7be85
begin
	b_AC = 1.0
	b_AU = 1.0
	b_CB = 1.0
	b_CY = 1.0
	b_UX = 1.0
	b_UB = 1.0
	b_XY = 1.0
end

# ╔═╡ 4fd5e63b-cf8d-41b9-91a7-05fa817c80e5
let
	N = 1000
	c = 0.25
	A = randn(N)
	U = c .* randn(N) + b_AU * A
	C = c .* randn(N) + b_AC * A
	B = c .* randn(N) + b_UB * U + b_CB * C
	X = c .* randn(N) + b_UX * U
	Y = c .* randn(N) + b_CY * C + b_XY * X
	global df1 = DataFrame(A=A, B=B, C=C, X=X, Y=Y, U=U)
	global data = Dict(:N => nrow(df1), :A => df1.A, :B => df1.B, :C => df1.C, :X => df1.X, 
		:Y => df1.Y, :U => df1.U)
	df1
end

# ╔═╡ 1cd5f6a1-b3d2-4771-911a-c4667ace7e39
let
	g_dot_str = "Digraph unobserved {A->C; A->U; U->B; C->B; U->X; C->Y; X->Y;}"
	global d1 = create_fci_dag("d1", df1, g_dot_str)
	gvplot(d1)
end

# ╔═╡ ab78ff20-060f-4ae4-96eb-fadd1ff88a9f
md" ##### Check if there are no backdoor_paths?"

# ╔═╡ b6b7c630-024a-4784-9c95-4ae7a10e995b
backdoor_criterion(d1, :X, :Y)

# ╔═╡ 4b146487-f082-486a-8586-2071145f92e1
md" ##### There are. What are possible backdoor paths between X and Y."

# ╔═╡ 8863916a-447e-4812-bb13-86c56f022729
all_paths(d1, :X, :Y)

# ╔═╡ f37ac2bb-057b-41e8-a66d-4d6f6393e565
md" ##### We need to make sure both paths are closed."

# ╔═╡ af1f67f0-57c5-4b8a-9ca6-4fa2c4ad7d3e
md" ##### The first path is already closed by collider `B` (`U -> B <- C`):"

# ╔═╡ df95e4f1-d7ee-44ed-8686-e23bd3255dda
is_collider(d1, :U, :B, :C)

# ╔═╡ 931ef767-e348-45fa-abd7-467d91f70270
md" #####  Conditioning on `B` will in fact open that path:"

# ╔═╡ 0f025755-f441-49de-9b59-d2edeaf3e4a9
backdoor_criterion(d1, :X, :Y, [:A, :B])

# ╔═╡ 902ae3ab-ba7c-452d-9dc7-b74f391ef20a
md" ##### To close the second path, we can't condition on `U` as it is not observed. We can close the path by conditioning on either `B` or `C`:"

# ╔═╡ 1d96f28e-2d9e-4647-a11d-c86e7f355b11
backdoor_criterion(d1, :X, :Y, [:A])

# ╔═╡ d27fd2b9-69cb-4d6b-a5e7-8b6429b37813
backdoor_criterion(d1, :X, :Y, [:C])

# ╔═╡ 8b88c86d-c679-4e91-aeca-f957ce112bbb
md" ##### Note that conditioning on `C` will keep both paths closed:"

# ╔═╡ b01ad9c6-d374-4bf1-a48b-55c7101d1fdd
backdoor_criterion(d1, :X, :Y, [:C, :B])

# ╔═╡ b828eb4a-46c3-470e-a543-f388fab5a75e
stan6_13 = "
data {
	int N;
	vector[N] B;
	vector[N] C;
	vector[N] X;
	vector[N] Y;
}
parameters {
	real a;
	real b_CB;
	real b_CY;
	real b_XY;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	a ~ normal(0, 2);
	b_CB ~ normal(0, 2);
	b_CY ~ normal(0, 2);
	b_XY ~ normal(0, 2);
	sigma ~ exponential(1);
	mu = a+ b_CB * C + b_CY * C+ b_XY * X;
	Y ~ normal(mu, sigma);
}
";

# ╔═╡ 82a171d2-f5d8-4936-a254-74e29959327b
let
	global m6_13s = SampleModel("m6.13s", stan6_13)
	global rc6_13s = stan_sample(m6_13s; data)
	success(rc6_13s) && describe(m6_13s, [:a, :b_AC, :b_CB, :b_CY, :b_XY, :sigma])
end

# ╔═╡ ae286aa2-b770-4e3b-9f69-e8e75dcd2918
stan6_14 = "
data {
	int N;
	vector[N] C;
	vector[N] X;
	vector[N] Y;
}
parameters {
	real a;
	real b_CY;
	real b_XY;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	a ~ normal(0, 1);
	b_CY ~ normal(0, 1);
	b_XY ~ normal(0, 1);
	sigma ~ exponential(1);
	mu = a + b_CY * C + b_XY * X;
	Y ~ normal(mu, sigma);
}
";

# ╔═╡ 3d855cfe-c7bd-4ae8-ae13-cda1fac9760b
let
	global m6_14s = SampleModel("m6.14s", stan6_14)
	global rc6_14s = stan_sample(m6_14s; data)
	success(rc6_14s) && describe(m6_14s, [:a, :b_AC, :b_CY, :b_XY, :sigma])
end

# ╔═╡ 3c9ed8da-0d99-44e0-b0ef-e5d6e908ebe9
stan6_15 = "
data {
	int N;
	vector[N] A;
	vector[N] X;
	vector[N] Y;
}
parameters {
	real a;
	real b_AC;
	real b_XY;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	a ~ normal(0, 1);
	b_AC ~ normal(0, 1);
	b_XY ~ normal(0, 1);
	sigma ~ exponential(1);
	mu = a + b_AC * A + b_XY * X;
	Y ~ normal(mu, sigma);
}
";

# ╔═╡ 2bbb7326-cd2a-4c40-a78f-38518ccae033
let
	global m6_15s = SampleModel("m6.15s", stan6_15)
	global rc6_15s = stan_sample(m6_15s; data)
	success(rc6_15s) && describe(m6_15s, [:a, :b_AC, :b_XY, :sigma])
end

# ╔═╡ dc7163a3-2ebf-415c-bb94-a2a35f6b68ce
let
	if success(rc6_13s) && success(rc6_14s) && success(rc6_15s)
		(s1, p1) = plot_model_coef([m6_13s, m6_14s, m6_15s], [:a, :b_AC, :b_CY, :b_CB, :b_XY, :sigma])
		p1
	end
end

# ╔═╡ 40a28481-e0e1-4d56-9f01-1b81cabe68a2
md" ### Backdoor waffles."

# ╔═╡ dc01ac4c-25fb-46c8-a809-ed2fbf4cca93
begin
	waffles = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale_df_cols!(waffles, [:Marriage, :MedianAgeMarriage, :Divorce])
	waffles.Whpm = waffles.WaffleHouses./waffles.Population
	waffles[:, [:Marriage, :MedianAgeMarriage, :Divorce, :WaffleHouses, :South]]
	df2 = DataFrame(S=waffles.South, W=waffles.WaffleHouses, A=waffles.MedianAgeMarriage,
		M=waffles.Marriage, D=waffles.Divorce)
	scale_df_cols!(df2, [:S, :W, :A, :M, :D])
	df2
end


# ╔═╡ bcf51205-7059-4f85-8ad3-f83f72a672e5
let
	g_dot_str = "Digraph d2 {S->W; W->D; S->M; S->A; A->M; M->D; A->D;}"
	global d2 = create_fci_dag("d2", df2, g_dot_str)
end;

# ╔═╡ 474f3fbc-dae5-4a64-aac2-66a8adeee672
g_oracle2 = fcialg(5, dseporacle, d2.g)

# ╔═╡ 68b6ce8a-6545-4f75-becd-c907e907cfb7
let
	fci_oracle_dot_str = to_gv(g_oracle2, d2.vars)
	g1 = GraphViz.Graph(d2.g_dot_str)
	g2 = GraphViz.Graph(fci_oracle_dot_str)
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="FCI oracle estimated DAG")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 56ebd880-8dbe-4c9d-9c0f-6c52db050b3c
md" ##### Check if there are no backdoor_paths?"

# ╔═╡ 67508533-482e-4c9c-b9ef-6fed2e68c6d9
backdoor_criterion(d2, :W, :D)

# ╔═╡ 393b43f0-9f7f-4e09-94ae-7d70b690c231
md" ##### There are:"

# ╔═╡ ec48a1fa-bf1d-4d51-a43f-650dae979802
all_paths(d2, :W, :D)

# ╔═╡ 14dc15e3-cf16-483f-9bda-cb262447c544
md" ##### Looking at the left (FCI generated) graph we can verify there are 4 paths, all open:"

# ╔═╡ ebd6f148-be54-4064-98cc-8e6a72d2f12a
md" ##### We need to make sure all 4 paths are closed."

# ╔═╡ c8361e51-1407-499c-9a4f-c28b8581e7e3
md" ##### Notice that all 4 paths go through `S`, conditioning on `S` will suffice:"

# ╔═╡ b02d63dd-c79a-4ffe-bc8f-c09546f068e0
backdoor_criterion(d2, :W, :D, [:S])

# ╔═╡ 4e12b4b2-772e-4a57-bfd3-309168ce53ac
md" ##### Conditioning on just `A` or `M` is not sufficient:"

# ╔═╡ 4760f2bc-ba64-4314-a733-695a067d885b
backdoor_criterion(d2, :W, :D, [:A])

# ╔═╡ 4dcc411e-1a43-474f-bb03-0887df06d7e6
backdoor_criterion(d2, :W, :D, [:M])

# ╔═╡ ea59fb9f-6252-43a2-933b-576a69d3ccd6
md" ##### Conditioning on both [`A`, `M`] also closes all backdoor paths:"

# ╔═╡ ec34ac4b-3c8b-4908-bf7e-bc656b68f1af
backdoor_criterion(d2, :W, :D, [:A, :M])

# ╔═╡ 969844e9-eb1c-41f5-83eb-44eef227bd2e
stan6_16 = "
data {
	int N;
	vector[N] W;
	vector[N] D;
	vector[N] S;
	vector[N] A;
	vector[N] M;
}
parameters {
	real a;
	real b_SW;
	real b_SM;
	real b_SA;
	real b_AM;
	real b_MD;
	real b_AD;
	real b_WD;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	sigma ~ exponential(1);
	mu = a + b_SW * S + b_SM * S + b_SA * A + b_AM * A + b_MD * M + b_WD * W;
	D ~ normal(mu, sigma);
}
";

# ╔═╡ 2313f571-0bc1-4f5d-ab1b-c22184545333
let
	global data2 = (N=nrow(df2), S=df2.S_s, W=df2.W_s, D=df2.D_s, A=df2.A_s, M=df2.M_s)
	global m6_16s = SampleModel("m6.16s", stan6_16)
	global rc6_16s = stan_sample(m6_16s; data=data2)
	success(rc6_16s) && describe(m6_16s, [:a, :b_SW, :b_SM, :b_SA, :b_AM, :b_MD,
		:b_AD, :b_WD, :sigma])
end

# ╔═╡ a47b79d1-a2b4-4dda-8889-2d776e18f2e7
stan6_17 = "
data {
	int N;
	vector[N] W;
	vector[N] D;
	vector[N] S;
}
parameters {
	real a;
	real b_SW;
	real b_WD;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	sigma ~ exponential(1);
	mu = a + b_SW * S + b_WD * W;
	D ~ normal(mu, sigma);
}
";

# ╔═╡ 23b900e8-b26a-4cd6-8c72-78e4a05c37aa
let
	global m6_17s = SampleModel("m6.17s", stan6_17)
	global rc6_17s = stan_sample(m6_17s; data=data2)
	success(rc6_17s) && describe(m6_17s, [:a, :b_SW, :b_WD, :sigma])
end

# ╔═╡ 04a27360-d31b-4a15-b688-e3c5e6692fd3
stan6_18 = "
data {
	int N;
	vector[N] W;
	vector[N] D;
	vector[N] M;
	vector[N] A;
}
parameters {
	real a;
	real b_MD;
	real b_AD;
	real b_WD;
	real<lower=0> sigma;
}
model {
	vector[N] mu;
	sigma ~ exponential(1);
	mu = a + b_MD * M + b_AD * A + b_WD * W;
	D ~ normal(mu, sigma);
}
";

# ╔═╡ eced8349-3a74-487d-9acc-1b468a939dce
let
	global m6_18s = SampleModel("m6.18s", stan6_18)
	global rc6_18s = stan_sample(m6_18s; data=data2)
	success(rc6_18s) && describe(m6_18s, [:a, :b_MD, :b_AD, :b_WD, :sigma])
end

# ╔═╡ 5b83ca88-dd93-48d9-96d9-2b53e667065b
let
	if success(rc6_16s) && success(rc6_17s) && success(rc6_17s)
		(s1, p1) = plot_model_coef([m6_16s, m6_17s, m6_18s], [:a, :b_SW, :b_SM, :b_SA, 
			:b_AM, :b_MD, :b_AD, :b_WD, :sigma])
		p1
	end
end

# ╔═╡ 775596cc-8d09-4b67-9cc6-8e7a366845c3
let
	if success(rc6_17s) && success(rc6_17s)
		(s1, p1) = plot_model_coef([m6_17s, m6_18s], [:a, :b_SW, :b_SM, :b_SA, 
			:b_AM, :b_MD, :b_AD, :b_WD, :sigma])
		p1
	end
end

# ╔═╡ Cell order:
# ╟─926ef957-0e39-403f-8eb4-a7f3824e74bc
# ╟─02f785db-8232-4274-828f-22902be25af4
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╠═9e068b40-6de7-49e5-8e89-0e26f9c7be85
# ╠═4fd5e63b-cf8d-41b9-91a7-05fa817c80e5
# ╠═1cd5f6a1-b3d2-4771-911a-c4667ace7e39
# ╟─ab78ff20-060f-4ae4-96eb-fadd1ff88a9f
# ╠═b6b7c630-024a-4784-9c95-4ae7a10e995b
# ╟─4b146487-f082-486a-8586-2071145f92e1
# ╠═8863916a-447e-4812-bb13-86c56f022729
# ╟─f37ac2bb-057b-41e8-a66d-4d6f6393e565
# ╟─af1f67f0-57c5-4b8a-9ca6-4fa2c4ad7d3e
# ╠═df95e4f1-d7ee-44ed-8686-e23bd3255dda
# ╟─931ef767-e348-45fa-abd7-467d91f70270
# ╠═0f025755-f441-49de-9b59-d2edeaf3e4a9
# ╟─902ae3ab-ba7c-452d-9dc7-b74f391ef20a
# ╠═1d96f28e-2d9e-4647-a11d-c86e7f355b11
# ╠═d27fd2b9-69cb-4d6b-a5e7-8b6429b37813
# ╟─8b88c86d-c679-4e91-aeca-f957ce112bbb
# ╠═b01ad9c6-d374-4bf1-a48b-55c7101d1fdd
# ╠═b828eb4a-46c3-470e-a543-f388fab5a75e
# ╠═82a171d2-f5d8-4936-a254-74e29959327b
# ╠═ae286aa2-b770-4e3b-9f69-e8e75dcd2918
# ╠═3d855cfe-c7bd-4ae8-ae13-cda1fac9760b
# ╠═3c9ed8da-0d99-44e0-b0ef-e5d6e908ebe9
# ╠═2bbb7326-cd2a-4c40-a78f-38518ccae033
# ╠═dc7163a3-2ebf-415c-bb94-a2a35f6b68ce
# ╟─40a28481-e0e1-4d56-9f01-1b81cabe68a2
# ╠═dc01ac4c-25fb-46c8-a809-ed2fbf4cca93
# ╠═bcf51205-7059-4f85-8ad3-f83f72a672e5
# ╠═474f3fbc-dae5-4a64-aac2-66a8adeee672
# ╠═68b6ce8a-6545-4f75-becd-c907e907cfb7
# ╟─56ebd880-8dbe-4c9d-9c0f-6c52db050b3c
# ╠═67508533-482e-4c9c-b9ef-6fed2e68c6d9
# ╟─393b43f0-9f7f-4e09-94ae-7d70b690c231
# ╠═ec48a1fa-bf1d-4d51-a43f-650dae979802
# ╟─14dc15e3-cf16-483f-9bda-cb262447c544
# ╟─ebd6f148-be54-4064-98cc-8e6a72d2f12a
# ╟─c8361e51-1407-499c-9a4f-c28b8581e7e3
# ╠═b02d63dd-c79a-4ffe-bc8f-c09546f068e0
# ╟─4e12b4b2-772e-4a57-bfd3-309168ce53ac
# ╠═4760f2bc-ba64-4314-a733-695a067d885b
# ╠═4dcc411e-1a43-474f-bb03-0887df06d7e6
# ╟─ea59fb9f-6252-43a2-933b-576a69d3ccd6
# ╠═ec34ac4b-3c8b-4908-bf7e-bc656b68f1af
# ╠═969844e9-eb1c-41f5-83eb-44eef227bd2e
# ╠═2313f571-0bc1-4f5d-ab1b-c22184545333
# ╠═a47b79d1-a2b4-4dda-8889-2d776e18f2e7
# ╠═23b900e8-b26a-4cd6-8c72-78e4a05c37aa
# ╠═04a27360-d31b-4a15-b688-e3c5e6692fd3
# ╠═eced8349-3a74-487d-9acc-1b468a939dce
# ╠═5b83ca88-dd93-48d9-96d9-2b53e667065b
# ╠═775596cc-8d09-4b67-9cc6-8e7a366845c3
