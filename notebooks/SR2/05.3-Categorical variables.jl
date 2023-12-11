### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ ad749c1e-b3e8-4889-b5ae-e3a34003815e
using Pkg

# ╔═╡ 20e931f5-965b-4e12-943a-164c7bfe17e6
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ fa9aa4e8-3967-4032-a5c4-bca70678045e
begin
	# Notebook specific
	using LaTeXStrings
	
	# Graphics related
	using CairoMakie

	# Causal inference support
	using Graphs
	using GraphViz
	using CausalInference

	# Stan specific
	using StanQuap
	using StanSample
	
	# Project support libraries
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 87ec8a7a-38c5-4f1b-a187-56471f61ac01
md" ## 5.3 - Categorical variables."

# ╔═╡ 0217d8d6-fad5-41df-94e3-8f7dc3883f89
md"##### Set page layout for notebook."

# ╔═╡ c26f9f12-ac83-46f7-b46c-6d39c585f10b
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

# ╔═╡ 694005d2-df03-490f-ac71-b449c8dd7b1a
md"### Julia code snippets 5.46"

# ╔═╡ 63a73ce0-c098-4bf2-942f-f5d6e64b0e1d
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';');
	df = filter(row -> row[:age] > 18, df)
	scale_df_cols!(df, [:height, :weight])
end;

# ╔═╡ 5038119c-031d-40ae-a951-c6ea8eaa0ab1
stan5_8 = "
data{
    int N;
    array[N] int male;
    vector[N] age;
    vector[N] weight;
    vector[N] height;
    array[N] int sex;
}
parameters{
    vector[2] a;
    real<lower=0> sigma;
}
model{
    vector[N] mu;
    sigma ~ exponential(1);
    a ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = a[sex[i]];
    }
    height ~ normal( mu , sigma );
}
";

# ╔═╡ 37eb04f4-8a5b-4a07-8c5f-b0e55b8215cb
md"### Define the SampleModel, etc."

# ╔═╡ 29820723-606d-4fe3-861d-486cbd8d4921
begin
	howell1 = copy(df)
	howell1[!, :sex] = [howell1[i, :male] == 1 ? 2 : 1 for i in 1:size(howell1, 1)]
	howell1 = filter(row -> row[:sex] == 2, howell1)
	howell1 = filter(row -> row[:sex] == 1, howell1)
	data = (N = size(howell1, 1), male = howell1.male, weight = howell1.weight,
		height = howell1.height, age = howell1.age, sex = howell1.sex)
	m5_8s = SampleModel("m5.8s", stan5_8)
	rc5_8s = stan_sample(m5_8s; data)
	success(rc5_8s) && describe(m5_8s, [Symbol("a[1]"), Symbol("a[2]"), :sigma])
end

# ╔═╡ c2ae9f52-ea70-45b8-9e6f-22407cda89ab
if success(rc5_8s)
	post5_8s = read_samples(m5_8s, :dataframe)
	ms5_8s = model_summary(post5_8s, [Symbol("a.1"), Symbol("a.2"), :sigma])
end

# ╔═╡ 6a2e70fd-d7d2-484c-a92b-dda57891b1f3
md" #### Many categories."

# ╔═╡ 5a790520-0ca7-410d-9dbb-65f6edd092fe
begin
	milk = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	milk[!, :clade_id] = Int.(indexin(milk[:, :clade], unique(milk[:, :clade])))
	scale_df_cols!(milk, [:kcal_per_g])
	milk
end

# ╔═╡ 5acbad80-e131-4f3b-b27f-058bcc430120
milk[:, [:clade_id, :kcal_per_g]]

# ╔═╡ 34f19d14-5707-42ce-9c5b-876fdfa9eafd
stan5_9 = "
data{
  int <lower=1> N;              // Sample size
  int <lower=1> k;
  vector[N] K;
  array[N] int clade_id;
}
parameters{
  vector[k] a;
  real<lower=0> sigma;
}
model{
  vector[N] mu;
  sigma ~ exponential( 1 );
  a ~ normal( 0 , 0.5 );
  for ( i in 1:N ) {
      mu[i] = a[clade_id[i]];
  }
  K ~ normal( mu , sigma );
}
";

# ╔═╡ f67cb8ee-2b3b-4030-8601-72d063f9e30f
let
	data = (N = size(milk, 1), clade_id = milk.clade_id,
    	K = milk.kcal_per_g_s, k = length(unique(milk[:, :clade_id])))
	global m5_9s = SampleModel("m5.9", stan5_9)
	global rc5_9s = stan_sample(m5_9s; data)

	success(rc5_9s) && describe(m5_9s, ["a[1]", "a[2]", "a[3]", "a[4]", "sigma"])
end

# ╔═╡ 4a28fb97-7a9b-4e08-9c05-73809bc30ef3
if success(rc5_9s)
	post5_9s_df = read_samples(m5_9s, :dataframe)
	post5_9s_df
end

# ╔═╡ 9dbbb2fb-0ad6-4f99-a2aa-a4395f8ebc6e
model_summary(post5_9s_df, [Symbol("a.1"), Symbol("a.2"), Symbol("a.3"), Symbol("a.4"), :sigma])

# ╔═╡ 39ca9bf6-11ec-4fe0-ae6e-4207f695e43f
if success(rc5_9s)
	(s1, f1) = plot_model_coef([m5_9s], 
		[Symbol("a.1"), Symbol("a.2"), Symbol("a.3"), Symbol("a.4"), :sigma]; 
	title="Comparison of `a` coefficients for categories")
	f1
end

# ╔═╡ Cell order:
# ╟─87ec8a7a-38c5-4f1b-a187-56471f61ac01
# ╠═0217d8d6-fad5-41df-94e3-8f7dc3883f89
# ╠═c26f9f12-ac83-46f7-b46c-6d39c585f10b
# ╠═ad749c1e-b3e8-4889-b5ae-e3a34003815e
# ╠═20e931f5-965b-4e12-943a-164c7bfe17e6
# ╠═fa9aa4e8-3967-4032-a5c4-bca70678045e
# ╟─694005d2-df03-490f-ac71-b449c8dd7b1a
# ╠═63a73ce0-c098-4bf2-942f-f5d6e64b0e1d
# ╠═5038119c-031d-40ae-a951-c6ea8eaa0ab1
# ╟─37eb04f4-8a5b-4a07-8c5f-b0e55b8215cb
# ╠═29820723-606d-4fe3-861d-486cbd8d4921
# ╠═c2ae9f52-ea70-45b8-9e6f-22407cda89ab
# ╟─6a2e70fd-d7d2-484c-a92b-dda57891b1f3
# ╠═5a790520-0ca7-410d-9dbb-65f6edd092fe
# ╠═5acbad80-e131-4f3b-b27f-058bcc430120
# ╠═34f19d14-5707-42ce-9c5b-876fdfa9eafd
# ╠═f67cb8ee-2b3b-4030-8601-72d063f9e30f
# ╠═4a28fb97-7a9b-4e08-9c05-73809bc30ef3
# ╠═9dbbb2fb-0ad6-4f99-a2aa-a4395f8ebc6e
# ╠═39ca9bf6-11ec-4fe0-ae6e-4207f695e43f
