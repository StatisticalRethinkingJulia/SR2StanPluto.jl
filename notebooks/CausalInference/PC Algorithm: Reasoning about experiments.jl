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

# ╔═╡ 38f5f3d0-c532-4905-ab5d-cdc46d2b8cce
@__DIR__

# ╔═╡ 83667de0-6e4b-4fe5-bd91-f26835b7257f
readdir(@__DIR__)

# ╔═╡ 305e336a-c619-4e44-a8f0-9b57a6e5d8a2
Base.current_project()

# ╔═╡ a8079d6a-6aaf-48f2-b1d5-3c2f73719eaf
pwd()

# ╔═╡ 6db80c65-9438-4058-8a53-f5c761393098
readdir(pwd())

# ╔═╡ 261cca70-a6dd-4bed-b2f2-8667534d0ceb
let
	Random.seed!(1)
	N = 1000
	a = rand(N)
	b = rand(N)
	d = a + rand(N) * 0.25
	c = a + b + rand(N) * 0.25
	x = d + c + rand(N) * 0.25
	e = x + rand(N) * 0.25
	f = b + rand(N) * 0.25
	y = e + f + c + rand(N) * 0.25

	global X = [a b d c f x e y]
	global df = DataFrame(a=a, b=b, d=d, c=c,f=f, x=x, e=e, y=y)
	global covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
	df
end

# ╔═╡ 0ef59054-afd5-443b-a1c9-914798c98017
g_dot_str="DiGraph dag_1 {a->d; d->x; b->f; f->y; x->e; e->y; a->c; b->c; c->x; c->y;}";

# ╔═╡ 6bbfe4cb-f7e1-4503-a386-092882a1a49c
d1 = create_dag("d1", df, 0.025; g_dot_str);

# ╔═╡ 370be11e-0010-4474-bcb6-15ec550d36e9
gvplot(d1)

# ╔═╡ b303e939-f070-4e69-bbbb-32659e7da967
d1.vars

# ╔═╡ 24aafa58-5791-4542-9b5a-d224b548508a
d1.g.fadjlist

# ╔═╡ ea263529-42af-40e7-8210-bc2cb671e493
backdoor_criterion(d1, :x, :y; verbose=true)

# ╔═╡ b4258b42-89ff-446f-a4c0-d15092734762
backdoor_criterion(d1, :x, :y, [:c]; verbose=true)

# ╔═╡ 0bca1cbe-4c39-45f7-bda7-23f1509ad1bc
backdoor_criterion(d1, :x, :y, [:c, :f]; verbose=true)

# ╔═╡ b060b849-2937-4764-bb75-0d3d3f5104a2
backdoor_criterion(d1, :x, :y, [:d, :c]; verbose=true)

# ╔═╡ 97605995-e638-4eaa-b2e0-a3a18532e953
dsep(d1, :x, :y; verbose=true)

# ╔═╡ 00ad74d9-62d8-4ced-8bf1-eace47470272
dsep(d1, :x, :y, [:f]; verbose=true)

# ╔═╡ 5533711c-6cbb-4407-8081-1ab44a09a8b9
dsep(d1, :x, :y, [:c], verbose=true)

# ╔═╡ 6d999053-3612-4e8d-b2f2-2ddf3eae5630
dsep(d1, :x, :y, [:c, :f], verbose=true)

# ╔═╡ ba202d07-ab64-4d78-a222-8bb3f5d4af2f
dsep(d1, :x, :y, [:e], verbose=true)

# ╔═╡ b7d7ff16-63a3-4032-a1b8-b2d1ec068fa6
dsep(d1, :x, :y, [:d, :c, :f, :e], verbose=true)

# ╔═╡ 4b75351b-c1d9-47b7-97c1-49eb90ea5fb1
@time d2 = create_dag("d2", df, 0.025; g_dot_str, est_func=cmitest);

# ╔═╡ 66fae38a-f622-444f-bfce-2c52d336bfdb
gvplot(d2)

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
		mu = a + bX * X + bD + D + bC * C + bF * F;
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
	global m5_0s = SampleModel("m5.0s", stan5_0)
	global rc5_0s = stan_sample(m5_0s; data)
	success(rc5_0s) && describe(m5_0s, [:a, :bX, :sigma])
end

# ╔═╡ 10b5c613-5694-425c-bfc2-8112aa708cef
if success(rc1_0s)
	post1_0s_df = read_samples(m1_0s, :dataframe)
	ms1_0s = model_summary(post1_0s_df, [:a, :bX, :bC, :bD, :bF, :sigma])
end

# ╔═╡ e4f4c963-c627-46e6-b21a-4f51a4b7a2da
set_dag_est_g!(d2; g_dot_str="DiGraph dag_1 {a->d; d->x; b->f; f->y; x->e [color=orange]; e->y [color=orange]; a->c; b->c; c->x; c->y;}")

# ╔═╡ 6091b043-4362-4b77-8d50-e4f58cf1c2da
d2.g_dot_str

# ╔═╡ 2cd6db5a-ee7d-4770-94ae-8a9f0549ecb1
gvplot(d2; 
	title_g="Figure A: Generational causal model",
	title_est_g="Figure B: We're interested regressing\n y on x")

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

# ╔═╡ c23f2f77-f40a-4f35-b0bb-f3f80c6b49e8
g_oracle = fcialg(8, dseporacle, d1.g)

# ╔═╡ 7ae6c2c0-c895-4acc-9728-1f93143b56f0
g_gauss = fcialg(d1.df, 0.05, gausscitest)

# ╔═╡ 85e5fbe1-f324-448a-a438-a454c0f744f0
let
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

# ╔═╡ Cell order:
# ╟─ad08dd09-222a-4071-92d4-38deebaf2e82
# ╠═e4552c81-d0db-4434-b81a-c86f1af515e5
# ╠═62c80a26-975a-11ed-2e09-2dce0e33bb70
# ╠═aaea31c8-37ed-4f0f-8e3e-8e89d30ed918
# ╠═38f5f3d0-c532-4905-ab5d-cdc46d2b8cce
# ╠═83667de0-6e4b-4fe5-bd91-f26835b7257f
# ╠═305e336a-c619-4e44-a8f0-9b57a6e5d8a2
# ╠═a8079d6a-6aaf-48f2-b1d5-3c2f73719eaf
# ╠═6db80c65-9438-4058-8a53-f5c761393098
# ╠═58ece6dd-a20f-4624-898a-40cae4b471e4
# ╠═261cca70-a6dd-4bed-b2f2-8667534d0ceb
# ╠═0ef59054-afd5-443b-a1c9-914798c98017
# ╠═6bbfe4cb-f7e1-4503-a386-092882a1a49c
# ╠═370be11e-0010-4474-bcb6-15ec550d36e9
# ╠═b303e939-f070-4e69-bbbb-32659e7da967
# ╠═24aafa58-5791-4542-9b5a-d224b548508a
# ╠═ea263529-42af-40e7-8210-bc2cb671e493
# ╠═b4258b42-89ff-446f-a4c0-d15092734762
# ╠═0bca1cbe-4c39-45f7-bda7-23f1509ad1bc
# ╠═b060b849-2937-4764-bb75-0d3d3f5104a2
# ╠═97605995-e638-4eaa-b2e0-a3a18532e953
# ╠═00ad74d9-62d8-4ced-8bf1-eace47470272
# ╠═5533711c-6cbb-4407-8081-1ab44a09a8b9
# ╠═6d999053-3612-4e8d-b2f2-2ddf3eae5630
# ╠═ba202d07-ab64-4d78-a222-8bb3f5d4af2f
# ╠═b7d7ff16-63a3-4032-a1b8-b2d1ec068fa6
# ╠═4b75351b-c1d9-47b7-97c1-49eb90ea5fb1
# ╠═66fae38a-f622-444f-bfce-2c52d336bfdb
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
# ╠═e4f4c963-c627-46e6-b21a-4f51a4b7a2da
# ╠═6091b043-4362-4b77-8d50-e4f58cf1c2da
# ╠═2cd6db5a-ee7d-4770-94ae-8a9f0549ecb1
# ╠═405f665b-635f-4436-93cb-1c205aa1c52d
# ╠═e6616c30-f5b8-4dd9-bdcf-578cabf0369f
# ╠═a954b58d-95b9-4ac0-8962-09ac9fe42f50
# ╠═3f63885a-6848-4aa2-a4ba-62ade75d6e58
# ╠═33f8e94c-8cb6-4c25-af40-a0ae73dcb29b
# ╠═c23f2f77-f40a-4f35-b0bb-f3f80c6b49e8
# ╠═7ae6c2c0-c895-4acc-9728-1f93143b56f0
# ╠═85e5fbe1-f324-448a-a438-a454c0f744f0
