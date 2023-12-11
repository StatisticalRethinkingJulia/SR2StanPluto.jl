### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 46ef488a-43ac-4b50-9093-d4e93dd38432
using Pkg

# ╔═╡ 58ece6dd-a20f-4624-898a-40cae4b471e4
begin
	# General packages for this script
	using Test
	
	# Graphics related packages
	using CairoMakie
	using GraphViz

	# DAG support
	using CausalInference

	# Stan specific
	using StanSample

	# Project support functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ ad08dd09-222a-4071-92d4-38deebaf2e82
md" ### PC Algorithm: Reasoning about experiments"

# ╔═╡ e4552c81-d0db-4434-b81a-c86f1af515e5
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 5%);
    	padding-right: max(5px, 5%);
	}
</style>
"""

# ╔═╡ 081be249-4e6c-4d94-b2e8-044d0c7ddcae
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 261cca70-a6dd-4bed-b2f2-8667534d0ceb
let
	Random.seed!(1)
	N = 10000
	a = rand(N)
	b = rand(N)
	d = a + rand(N) * 0.25
	c = a + b + rand(N) * 0.25
	x = d + c + rand(N) * 0.25
	e = x + rand(N) * 0.25
	f = b + rand(N) * 0.25
	y = e + f + c + rand(N) * 0.25

	global X = [a b d c f x e y]
	global df_full = DataFrame(A=a, B=b, D=d, C=c, F=f, X=x, E=e, Y=y)
	global df = DataFrame(D=d, C=c, F=f, X=x, E=e, Y=y)
	global corm = NamedArray(cor(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	corm
end

# ╔═╡ 3a7676c8-38be-41d9-949e-d8de8c1b9cff
md" ##### Dag d1 is the full generational causal graph."

# ╔═╡ 0ef59054-afd5-443b-a1c9-914798c98017
g_dot_str="DiGraph d1 {A->D; D->X; B->F; F->Y; X->E; E->Y; A->C; B->C; C->X; C->Y;}";

# ╔═╡ 6bbfe4cb-f7e1-4503-a386-092882a1a49c
d1 = create_fci_dag("d1", df_full, g_dot_str);

# ╔═╡ b1f81e4e-cd1c-416d-8300-dcd6042a00bb
gvplot(d1)

# ╔═╡ b72ae505-db7e-4a4c-a97a-420bf3a2feaf
all_paths(d1, :A, :B)

# ╔═╡ ff523e85-4760-4fba-99d9-1c19930fc855
d2 = create_pcalg_gauss_dag("d2", df_full, g_dot_str; p=0.25);

# ╔═╡ 27350494-87a9-4619-beeb-e9b31502c1cf
gvplot(d2)

# ╔═╡ b14abbeb-6efa-4dc2-9a68-57e496938d62
md" ##### Dag d3 is the observed part of the causal graph."

# ╔═╡ 261199f5-cfe8-48e7-b3d5-83cb3c977de6
g_dot_str_2="DiGraph d2 {D->X; X->E; E->Y; C->X; C->Y; F->Y;}";

# ╔═╡ faf4f474-99c2-40df-a47b-0b73d0a92d27
d3 = create_fci_dag("d3", df, g_dot_str_2);

# ╔═╡ a67ef2e6-b7f4-470a-b5d8-5fd12bfebc91
gvplot(d3; title_g="Observed part of generational graph.")

# ╔═╡ 2481e166-ddf1-4e44-941e-ada126da201d
md" ##### Use DAG d4 to illustrate backdoor-paths."

# ╔═╡ 0d58fc1f-96e2-4df6-9f68-dd405afd888c
dtmp = create_fci_dag("dtmp", df_full, g_dot_str);

# ╔═╡ 363ba48a-643b-42c4-a8a7-12a9c530a4f2
let
	ds= "DiGraph d1 {A->D; B->F; D->X; X->E [color=yellow]; E->Y [color=yellow]; B->C; C->X [color=red]; C->Y [color=red]; F->Y;}"
	dtmp.est_g_dot_str = ds
	g1 = GraphViz.Graph(dtmp.g_dot_str)
	g2 = GraphViz.Graph(dtmp.est_g_dot_str)
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="Generational DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="Regress y on x\nFails because of a backdoor path via c")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 27f574ba-1c83-44b4-91b5-943701d133da
md" ##### Regression of Y on X might not show the correct average causal effect (ACE) as the `backdoor_criterion` returns `false`."

# ╔═╡ ea263529-42af-40e7-8210-bc2cb671e493
backdoor_criterion(dtmp, :X, :Y; verbose=true)

# ╔═╡ 62a63405-6562-4dd5-b005-714a465c1b3b
all_paths(dtmp, :X, :Y)

# ╔═╡ 4cfc8028-a7ef-4a63-b5c1-c1ff6664cb7d
md" ##### Can we close the backdoor by conditioning on C?"

# ╔═╡ b4258b42-89ff-446f-a4c0-d15092734762
backdoor_criterion(dtmp, :X, :Y, [:C]; verbose=true)

# ╔═╡ 1dc7b8fa-ffda-4f5b-8b0f-a8df8a4e4708
md" ##### No, this opens backdoor path X-D-A-C-B-F-Y."

# ╔═╡ 1be951aa-160a-4c0d-97aa-0a77dc9a9873
dtmp.vars

# ╔═╡ 51da6b02-d5a9-467c-bfbd-c6d9dc164953
let
	ds= "DiGraph d1 {a->d [color=red]; d->x [color=red]; b->f [color=red]; f->y [color=red]; x->e [color=yellow]; e->y [color=yellow]; a->c [color=red]; b->c [color=red]; c->x; c->y;}"
	dtmp.est_g_dot_str = ds
	g1 = GraphViz.Graph(dtmp.g_dot_str)
	g2 = GraphViz.Graph(dtmp.est_g_dot_str)
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="Regress y on x\nOpens up a new backdoor path")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 76eebf62-537f-4ff3-b35a-7f292df6c81f
md" ##### Will conditioning on both c and f close all backdoor paths?"

# ╔═╡ 0bca1cbe-4c39-45f7-bda7-23f1509ad1bc
backdoor_criterion(dtmp, :X, :Y, [:C, :F]; verbose=true)

# ╔═╡ 3ba9b2e8-813f-437c-81e3-c2ba7c27cb8c
md" ##### Yes it does, and so will conditioning on d and c."

# ╔═╡ b060b849-2937-4764-bb75-0d3d3f5104a2
backdoor_criterion(dtmp, :X, :Y, [:C, :D]; verbose=true)

# ╔═╡ d1a768a9-eee0-43e0-b5b5-567b10836bbe
let
	ds= "DiGraph d1 {a->d; d->x; b->f; f->y; x->e [color=yellow]; e->y [color=yellow]; a->c; b->c; c->x; c->y;}"
	dtmp.est_g_dot_str = ds
	g1 = GraphViz.Graph(dtmp.g_dot_str)
	g2 = GraphViz.Graph(dtmp.est_g_dot_str)
	f = Figure(;size=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="Regress y on x\nNo more backdoor paths ")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 70d69a91-5d84-4ab7-aca4-f321975861db
backdoor_criterion(dtmp, :X, :Y, [:D, :F]; verbose=true)

# ╔═╡ 87e59d11-bf40-4c8b-b85c-0f0e07d9689f
backdoor_criterion(dtmp, :X, :Y, [:C, :D, :F]; verbose=true)

# ╔═╡ 28853ae3-fd09-4e86-9807-79642cedd56d
md" ##### Below Stan models illustrate this in another way. See the coefficient plot below."

# ╔═╡ 4993add1-19c3-4c0a-93b6-3f0c21cb2b09
stan1_0 = "
	data {
		int<lower=1> N; // Sample size
		vector[N] X;
		vector[N] Y;
		vector[N] D;
		vector[N] C;
		vector[N] F;
	}
	parameters {
		real a;
		real bX;
		real bD;
		real bC;
		real bF;
		real<lower=0>sigma;
	}
	model {
		vector[N] mu;
		a ~ normal(0, 1);
		bX ~ normal(0, 1);
		bC ~ normal(0, 1);
		bD ~ normal(0, 1);
		bF ~ normal(0, 1);
		sigma ~ exponential(1);
		mu = a + bX * X + bD * D + bC * C + bF * F;
		Y ~ normal(mu, sigma);
	}
";

# ╔═╡ 42571912-43ef-4123-8723-aec1ed1efa6d
stan2_0 = "
	data {
		int<lower=1> N; // Sample size
		vector[N] X;
		vector[N] Y;
		vector[N] C;
		vector[N] D;
	}
	parameters {
		real a;
		real bX;
		real bC;
		real bD;
		real<lower=0> sigma;
	}
	model {
		vector[N] mu;
		a ~ normal(0, 1);
		bX ~ normal(0, 1);
		bC ~ normal(0, 1);
		bD ~ normal(0, 1);
		sigma ~ exponential(1);
		mu = a + bX * X + bC * C + bD * D;
		Y ~ normal(mu, sigma);
	}
";

# ╔═╡ 98745efe-cb3e-44bd-a1fc-ef8150e79772
stan3_0 = "
	data {
		int<lower=1> N; // Sample size
		vector[N] X;
		vector[N] Y;
		vector[N] C;
		vector[N] F;
	}
	parameters {
		real a;
		real bX;
		real bC;
		real bF;
		real<lower=0> sigma;
	}
	model {
		vector[N] mu;
		a ~ normal(0, 1);
		bX ~ normal(0, 1);
		bC ~ normal(0, 1);
		bF ~ normal(0, 1);
		sigma ~ exponential(1);
		mu = a + bX * X + bC * C + bF * F;
		Y ~ normal(mu, sigma);
	}
";

# ╔═╡ c947bb30-554d-42bc-9369-a6f8b531c391
stan4_0 = "
	data {
		int<lower=1> N; // Sample size
		vector[N] X;
		vector[N] Y;
		vector[N] D;
		vector[N] F;
	}
	parameters {
		real a;
		real bX;
		real bD;
		real bF;
		real<lower=0> sigma;
	}
	model {
		vector[N] mu;
		a ~ normal(0, 1);
		bX ~ normal(0, 1);
		bD ~ normal(0, 1);
		bF ~ normal(0, 1);
		sigma ~ exponential(1);
		mu = a + bX * X + bD * D + bF * F;
		Y ~ normal(mu, sigma);
	}
";

# ╔═╡ 61758a72-f516-4e76-b7e0-c7c278d7f2ab
stan5_0 = "
	data {
		int<lower=1> N; // Sample size
		vector[N] X;
		vector[N] Y;
	}
	parameters {
		real a;
		real bX;
		real<lower=0> sigma;
	}
	model {
		vector[N] mu;
		a ~ normal(0, 1);
		bX ~ normal(0, 1);
		sigma ~ exponential(1);
		mu = a + bX * X;
		Y ~ normal(mu, sigma);
	}
";

# ╔═╡ 4d9a3c0d-49c3-4502-b7c7-ab0c95d6b141
data = (N=size(df, 1), X=df.X, Y=df.Y, D=df.D, C=df.C, F=df.F);

# ╔═╡ d7837ce1-2780-45ec-8645-42b83af17b1d
let
	global m1_0s = SampleModel("m1.0s", stan1_0)
	global rc1_0s = stan_sample(m1_0s; data)
	success(rc1_0s) && describe(m1_0s, [:a, :bX, :bC, :bD, :bF, :sigma])
end

# ╔═╡ f264ee82-9e03-4a0c-bc4a-fbb000700de5
let
	global m2_0s = SampleModel("m2.0s", stan2_0)
	global rc2_0s = stan_sample(m2_0s; data)
	success(rc2_0s) && describe(m2_0s, [:a, :bX, :bC, :bD, :sigma])
end

# ╔═╡ 0c4811f2-ad5b-47af-a74b-ff3b24185a2d
let
	global m3_0s = SampleModel("m3.0s", stan3_0)
	global rc3_0s = stan_sample(m3_0s; data)
	success(rc3_0s) && describe(m3_0s, [:a, :bX, :bC, :bF, :sigma])
end

# ╔═╡ 1691a68e-e918-42b3-b067-120b6dbebc15
let
	global m4_0s = SampleModel("m4.0s", stan4_0)
	global rc4_0s = stan_sample(m4_0s; data)
	success(rc4_0s) && describe(m4_0s, [:a, :bX, :bD, :bF, :sigma])
end

# ╔═╡ 6ba10a1a-b236-4dc8-af0b-ae8403f63b01
let
	global m5_0s = SampleModel("m5.0s", stan5_0)
	global rc5_0s = stan_sample(m5_0s; data)
	success(rc5_0s) && describe(m5_0s, [:a, :bX, :sigma])
end

# ╔═╡ 10b5c613-5694-425c-bfc2-8112aa708cef
if success(rc1_0s)
	post1_0s_df = read_samples(m1_0s, :dataframe)
	ms1_0s = model_summary(post1_0s_df, [:a, :bX, :bC, :bD, :bF, :sigma])
end

# ╔═╡ 405f665b-635f-4436-93cb-1c205aa1c52d
if success(rc2_0s)
	post2_0s_df = read_samples(m2_0s, :dataframe)
	ms2_0s = model_summary(post2_0s_df, [:a, :bX, :bC, :bD, :sigma])
end

# ╔═╡ e6616c30-f5b8-4dd9-bdcf-578cabf0369f
if success(rc3_0s)
	post3_0s_df = read_samples(m3_0s, :dataframe)
	ms3_0s = model_summary(post3_0s_df, [:a, :bX, :bC, :bF, :sigma])
end

# ╔═╡ a954b58d-95b9-4ac0-8962-09ac9fe42f50
if success(rc4_0s)
	post4_0s_df = read_samples(m4_0s, :dataframe)
	ms4_0s = model_summary(post4_0s_df, [:a, :bX, :bD, :bF, :sigma])
end

# ╔═╡ 3f63885a-6848-4aa2-a4ba-62ade75d6e58
if success(rc5_0s)
	post5_0s_df = read_samples(m5_0s, :dataframe)
	ms5_0s = model_summary(post5_0s_df, [:a, :bX, :sigma])
end

# ╔═╡ 33f8e94c-8cb6-4c25-af40-a0ae73dcb29b
if success(rc1_0s) && success(rc2_0s)
	(s1, f1) = plot_model_coef([m1_0s, m2_0s, m3_0s, m4_0s, m5_0s], [:a, :bX, :bC, :bD, :bF, :sigma])
	f1
end

# ╔═╡ f908a8aa-b8df-4280-8652-4831483117d1
md" ##### Model m3.0s will likely provide the best estimate of the average causal effect (ACE) of X on Y."

# ╔═╡ Cell order:
# ╟─ad08dd09-222a-4071-92d4-38deebaf2e82
# ╠═e4552c81-d0db-4434-b81a-c86f1af515e5
# ╠═46ef488a-43ac-4b50-9093-d4e93dd38432
# ╠═081be249-4e6c-4d94-b2e8-044d0c7ddcae
# ╠═58ece6dd-a20f-4624-898a-40cae4b471e4
# ╠═261cca70-a6dd-4bed-b2f2-8667534d0ceb
# ╟─3a7676c8-38be-41d9-949e-d8de8c1b9cff
# ╠═0ef59054-afd5-443b-a1c9-914798c98017
# ╠═6bbfe4cb-f7e1-4503-a386-092882a1a49c
# ╠═b1f81e4e-cd1c-416d-8300-dcd6042a00bb
# ╠═b72ae505-db7e-4a4c-a97a-420bf3a2feaf
# ╠═ff523e85-4760-4fba-99d9-1c19930fc855
# ╠═27350494-87a9-4619-beeb-e9b31502c1cf
# ╟─b14abbeb-6efa-4dc2-9a68-57e496938d62
# ╠═261199f5-cfe8-48e7-b3d5-83cb3c977de6
# ╠═faf4f474-99c2-40df-a47b-0b73d0a92d27
# ╠═a67ef2e6-b7f4-470a-b5d8-5fd12bfebc91
# ╟─2481e166-ddf1-4e44-941e-ada126da201d
# ╠═0d58fc1f-96e2-4df6-9f68-dd405afd888c
# ╠═363ba48a-643b-42c4-a8a7-12a9c530a4f2
# ╟─27f574ba-1c83-44b4-91b5-943701d133da
# ╠═ea263529-42af-40e7-8210-bc2cb671e493
# ╠═62a63405-6562-4dd5-b005-714a465c1b3b
# ╟─4cfc8028-a7ef-4a63-b5c1-c1ff6664cb7d
# ╠═b4258b42-89ff-446f-a4c0-d15092734762
# ╟─1dc7b8fa-ffda-4f5b-8b0f-a8df8a4e4708
# ╠═1be951aa-160a-4c0d-97aa-0a77dc9a9873
# ╠═51da6b02-d5a9-467c-bfbd-c6d9dc164953
# ╟─76eebf62-537f-4ff3-b35a-7f292df6c81f
# ╠═0bca1cbe-4c39-45f7-bda7-23f1509ad1bc
# ╟─3ba9b2e8-813f-437c-81e3-c2ba7c27cb8c
# ╠═b060b849-2937-4764-bb75-0d3d3f5104a2
# ╠═d1a768a9-eee0-43e0-b5b5-567b10836bbe
# ╠═70d69a91-5d84-4ab7-aca4-f321975861db
# ╠═87e59d11-bf40-4c8b-b85c-0f0e07d9689f
# ╟─28853ae3-fd09-4e86-9807-79642cedd56d
# ╠═4993add1-19c3-4c0a-93b6-3f0c21cb2b09
# ╠═42571912-43ef-4123-8723-aec1ed1efa6d
# ╠═98745efe-cb3e-44bd-a1fc-ef8150e79772
# ╠═c947bb30-554d-42bc-9369-a6f8b531c391
# ╠═61758a72-f516-4e76-b7e0-c7c278d7f2ab
# ╠═4d9a3c0d-49c3-4502-b7c7-ab0c95d6b141
# ╠═d7837ce1-2780-45ec-8645-42b83af17b1d
# ╠═f264ee82-9e03-4a0c-bc4a-fbb000700de5
# ╠═0c4811f2-ad5b-47af-a74b-ff3b24185a2d
# ╠═1691a68e-e918-42b3-b067-120b6dbebc15
# ╠═6ba10a1a-b236-4dc8-af0b-ae8403f63b01
# ╠═10b5c613-5694-425c-bfc2-8112aa708cef
# ╠═405f665b-635f-4436-93cb-1c205aa1c52d
# ╠═e6616c30-f5b8-4dd9-bdcf-578cabf0369f
# ╠═a954b58d-95b9-4ac0-8962-09ac9fe42f50
# ╠═3f63885a-6848-4aa2-a4ba-62ade75d6e58
# ╠═33f8e94c-8cb6-4c25-af40-a0ae73dcb29b
# ╟─f908a8aa-b8df-4280-8652-4831483117d1
