### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 62c80a26-975a-11ed-2e09-2dce0e33bb70
using Pkg

# ╔═╡ aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 58ece6dd-a20f-4624-898a-40cae4b471e4
begin
	# General packages for this script
	using Test
	
	# Graphics related packages
	using CairoMakie
	using GraphViz
	using Graphs

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

# ╔═╡ a8079d6a-6aaf-48f2-b1d5-3c2f73719eaf
pwd()

# ╔═╡ 6db80c65-9438-4058-8a53-f5c761393098
readdir(pwd())

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
	global df_full = DataFrame(a=a, b=b, d=d, c=c,f=f, x=x, e=e, y=y)
	global df = DataFrame(d=d, c=c, f=f, x=x, e=e, y=y)
	global corm = NamedArray(cor(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	corm
end

# ╔═╡ 3a7676c8-38be-41d9-949e-d8de8c1b9cff
md" ##### Dag d1 is the full generational causal graph."

# ╔═╡ 0ef59054-afd5-443b-a1c9-914798c98017
g_dot_str="DiGraph d1 {a->d; d->x; b->f; f->y; x->e; e->y; a->c; b->c; c->x; c->y;}";

# ╔═╡ 6bbfe4cb-f7e1-4503-a386-092882a1a49c
d1 = create_dag("d1", df_full, 0.25; g_dot_str);

# ╔═╡ 85e5fbe1-f324-448a-a438-a454c0f744f0
let
	g_oracle = fcialg(8, dseporacle, d1.g)
	g_gauss = fcialg(d1.df, 0.25, gausscitest)
    fci_oracle_dot_str = to_gv(g_oracle, d1.vars)
    fci_gauss_dot_str = to_gv(g_gauss, d1.vars)
    g1 = GraphViz.Graph(d1.g_dot_str)
    g2 = GraphViz.Graph(d1.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

# ╔═╡ b14abbeb-6efa-4dc2-9a68-57e496938d62
md" ##### Dag d2 is the observed part of the causal graph."

# ╔═╡ 261199f5-cfe8-48e7-b3d5-83cb3c977de6
g_dot_str_2="DiGraph d2 {d->x; f->y; x->e; e->y; c->x; c->y;}";

# ╔═╡ 7ee0b0da-c837-4348-ad9f-7bda0d0d6222
d2 = create_dag("d2", df, 0.25; g_dot_str=g_dot_str_2);

# ╔═╡ 06554e50-4bfb-4da8-abae-eb58283ac687
d2.vars

# ╔═╡ a67ef2e6-b7f4-470a-b5d8-5fd12bfebc91
gvplot(d2; title_g="Observed part of causal graph.")

# ╔═╡ 5085b099-3f85-47b2-9fac-9f24aa9f4396
est_g = pcalg(df, 0.25, gausscitest)

# ╔═╡ b890b977-5c28-4b79-99b4-f800423405a0
est_g.fadjlist

# ╔═╡ ccfd0b98-1eb6-4381-8bb5-fecb9d9e1d5b
g_oracle = fcialg(6, dseporacle, d2.g)

# ╔═╡ 87b6c0d6-b9af-4d56-b0b1-ccfa412f2130
g_oracle.graph.fadjlist

# ╔═╡ 0ba0618b-acf6-42f6-8b40-359f40871180
g_gauss = fcialg(df, 0.25, gausscitest)

# ╔═╡ eca6a867-434d-4a07-ac60-7a466cf8f03f
g_oracle.graph.fadjlist

# ╔═╡ bb03f591-f6bb-4439-8b62-fa9ad6e6bf2c
vars = [:d, :c, :f, :x, :e, :y];

# ╔═╡ d91b5dec-28d6-479e-8ea0-fb89657cab67
let
	fci_oracle_dot_str = to_gv(g_oracle, vars)
	fci_gauss_dot_str = to_gv(g_gauss, vars)
	g1 = GraphViz.Graph(d2.g_dot_str)
	g2 = GraphViz.Graph(d2.est_g_dot_str)
	g3 = GraphViz.Graph(fci_oracle_dot_str)
	g4 = GraphViz.Graph(fci_gauss_dot_str)
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="Observed portion of causal DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
	CairoMakie.image!(rotr90(create_png_image(g3)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
	CairoMakie.image!(rotr90(create_png_image(g4)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 2481e166-ddf1-4e44-941e-ada126da201d
md" ##### Use DAG d3 to illustrate backdoor-paths."

# ╔═╡ 0d58fc1f-96e2-4df6-9f68-dd405afd888c
d3 = create_dag("d3", df_full, 0.025; g_dot_str=g_dot_str);

# ╔═╡ 27f574ba-1c83-44b4-91b5-943701d133da
md" ##### Regression of y on x might not show the correct average causal effect (ACE) as the `backdoor_criterion` returns `false`."

# ╔═╡ ea263529-42af-40e7-8210-bc2cb671e493
backdoor_criterion(d1, :x, :y; verbose=true)

# ╔═╡ 363ba48a-643b-42c4-a8a7-12a9c530a4f2
let
	ds= "DiGraph d1 {a->d; d->x; b->f; f->y; x->e [color=yellow]; e->y [color=yellow]; a->c; b->c; c->x [color=red]; c->y [color=red];}"
	set_dag_est_g!(d3; g_dot_str=ds)
	g1 = GraphViz.Graph(d3.g_dot_str)
	g2 = GraphViz.Graph(d3.est_g_dot_str)
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
	CairoMakie.image!(rotr90(create_png_image(g1)))
	hidedecorations!(ax)
	hidespines!(ax)
	ax = Axis(f[1, 2]; aspect=DataAspect(), title="Regress y on x\nFails because of a backdoor path via c")
	CairoMakie.image!(rotr90(create_png_image(g2)))
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 4cfc8028-a7ef-4a63-b5c1-c1ff6664cb7d
md" ##### Can we close the backdoor by conditioning on c?"

# ╔═╡ b4258b42-89ff-446f-a4c0-d15092734762
backdoor_criterion(d1, :x, :y, [:c]; verbose=true)

# ╔═╡ 1dc7b8fa-ffda-4f5b-8b0f-a8df8a4e4708
md" ##### No, this opens backdoor path x-d-a-c-b-f-y."

# ╔═╡ 51da6b02-d5a9-467c-bfbd-c6d9dc164953
let
	ds= "DiGraph d1 {a->d [color=red]; d->x [color=red]; b->f [color=red]; f->y [color=red]; x->e [color=yellow]; e->y [color=yellow]; a->c [color=red]; b->c [color=red]; c->x; c->y;}"
	set_dag_est_g!(d3; g_dot_str=ds)
	g1 = GraphViz.Graph(d3.g_dot_str)
	g2 = GraphViz.Graph(d3.est_g_dot_str)
	f = Figure(resolution=default_figure_resolution)
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
backdoor_criterion(d1, :x, :y, [:c, :f]; verbose=true)

# ╔═╡ 3ba9b2e8-813f-437c-81e3-c2ba7c27cb8c
md" ##### Yes it does, and so will conditioning on d and c."

# ╔═╡ b060b849-2937-4764-bb75-0d3d3f5104a2
backdoor_criterion(d1, :x, :y, [:c, :d]; verbose=true)

# ╔═╡ d1a768a9-eee0-43e0-b5b5-567b10836bbe
let
	ds= "DiGraph d1 {a->d; d->x; b->f; f->y; x->e [color=yellow]; e->y [color=yellow]; a->c; b->c; c->x; c->y;}"
	set_dag_est_g!(d3; g_dot_str=ds)
	g1 = GraphViz.Graph(d3.g_dot_str)
	g2 = GraphViz.Graph(d3.est_g_dot_str)
	f = Figure(resolution=default_figure_resolution)
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
backdoor_criterion(d1, :x, :y, [:d, :f]; verbose=true)

# ╔═╡ 87e59d11-bf40-4c8b-b85c-0f0e07d9689f
backdoor_criterion(d1, :x, :y, [:c, :d, :f]; verbose=true)

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

# ╔═╡ 7426e93b-da9f-423f-a2d2-0a116f286012
tmpdir = mktempdir()

# ╔═╡ 4d9a3c0d-49c3-4502-b7c7-ab0c95d6b141
data = (N=size(df, 1), X=df.x, Y=df.y, D=df.d, C=df.c, F=df.f)

# ╔═╡ d7837ce1-2780-45ec-8645-42b83af17b1d
let
	global m1_0s = SampleModel("m1.0s", stan1_0, tmpdir)
	global rc1_0s = stan_sample(m1_0s; data)
	success(rc1_0s) && describe(m1_0s, [:a, :bX, :bC, :bD, :bF, :sigma])
end

# ╔═╡ f264ee82-9e03-4a0c-bc4a-fbb000700de5
let
	global m2_0s = SampleModel("m2.0s", stan2_0, tmpdir)
	global rc2_0s = stan_sample(m2_0s; data)
	success(rc2_0s) && describe(m2_0s, [:a, :bX, :bC, :bD, :sigma])
end

# ╔═╡ 0c4811f2-ad5b-47af-a74b-ff3b24185a2d
let
	global m3_0s = SampleModel("m3.0s", stan3_0, tmpdir)
	global rc3_0s = stan_sample(m3_0s; data)
	success(rc3_0s) && describe(m3_0s, [:a, :bX, :bC, :bF, :sigma])
end

# ╔═╡ 1691a68e-e918-42b3-b067-120b6dbebc15
let
	global m4_0s = SampleModel("m4.0s", stan4_0, tmpdir)
	global rc4_0s = stan_sample(m4_0s; data)
	success(rc4_0s) && describe(m4_0s, [:a, :bX, :bD, :bF, :sigma])
end

# ╔═╡ 6ba10a1a-b236-4dc8-af0b-ae8403f63b01
let
	global m5_0s = SampleModel("m5.0s", stan5_0, tmpdir)
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
md" ##### Models m1.0s and m3.0s will likely provide the best estimate of the average causal effect (ACE) of x on y."

# ╔═╡ Cell order:
# ╟─ad08dd09-222a-4071-92d4-38deebaf2e82
# ╠═e4552c81-d0db-4434-b81a-c86f1af515e5
# ╠═62c80a26-975a-11ed-2e09-2dce0e33bb70
# ╠═aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
# ╠═a8079d6a-6aaf-48f2-b1d5-3c2f73719eaf
# ╠═6db80c65-9438-4058-8a53-f5c761393098
# ╠═58ece6dd-a20f-4624-898a-40cae4b471e4
# ╠═261cca70-a6dd-4bed-b2f2-8667534d0ceb
# ╟─3a7676c8-38be-41d9-949e-d8de8c1b9cff
# ╠═0ef59054-afd5-443b-a1c9-914798c98017
# ╠═6bbfe4cb-f7e1-4503-a386-092882a1a49c
# ╠═85e5fbe1-f324-448a-a438-a454c0f744f0
# ╟─b14abbeb-6efa-4dc2-9a68-57e496938d62
# ╠═261199f5-cfe8-48e7-b3d5-83cb3c977de6
# ╠═7ee0b0da-c837-4348-ad9f-7bda0d0d6222
# ╠═06554e50-4bfb-4da8-abae-eb58283ac687
# ╠═a67ef2e6-b7f4-470a-b5d8-5fd12bfebc91
# ╠═5085b099-3f85-47b2-9fac-9f24aa9f4396
# ╠═b890b977-5c28-4b79-99b4-f800423405a0
# ╠═ccfd0b98-1eb6-4381-8bb5-fecb9d9e1d5b
# ╠═87b6c0d6-b9af-4d56-b0b1-ccfa412f2130
# ╠═0ba0618b-acf6-42f6-8b40-359f40871180
# ╠═eca6a867-434d-4a07-ac60-7a466cf8f03f
# ╠═bb03f591-f6bb-4439-8b62-fa9ad6e6bf2c
# ╠═d91b5dec-28d6-479e-8ea0-fb89657cab67
# ╟─2481e166-ddf1-4e44-941e-ada126da201d
# ╠═0d58fc1f-96e2-4df6-9f68-dd405afd888c
# ╟─27f574ba-1c83-44b4-91b5-943701d133da
# ╠═ea263529-42af-40e7-8210-bc2cb671e493
# ╠═363ba48a-643b-42c4-a8a7-12a9c530a4f2
# ╟─4cfc8028-a7ef-4a63-b5c1-c1ff6664cb7d
# ╠═b4258b42-89ff-446f-a4c0-d15092734762
# ╟─1dc7b8fa-ffda-4f5b-8b0f-a8df8a4e4708
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
# ╠═7426e93b-da9f-423f-a2d2-0a116f286012
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
