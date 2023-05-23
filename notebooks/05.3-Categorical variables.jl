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
	using StatisticalRethinking: sr_datadir, PRECIS
	using RegressionAndOtherStories
end

# ╔═╡ 645d4df3-af64-489b-b2b0-e710d8917680
md" ## 5.3 - Categorical variables."

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

# ╔═╡ 4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
md"### Julia code snippets 5.46"

# ╔═╡ 2195f047-416a-40bc-ab00-fd5bef502e62
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';');
	df = filter(row -> row[:age] > 18, df)
	scale_df_cols!(df, [:height, :weight])
end;

# ╔═╡ c67411f7-bd2a-42d8-86dd-bea5e435b4fc
stan5_8 = "
data{
    int N;
    int male[N];
    vector[N] age;
    vector[N] weight;
    vector[N] height;
    int sex[N];
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

# ╔═╡ 74b9ca50-8c24-40ab-a89e-0e022a01345c
md"### Define the SampleModel, etc."

# ╔═╡ c65770e3-d43c-4368-bdf2-55efb76db580
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

# ╔═╡ 885827cc-a6f4-4658-b3f1-1c8e1a529035
if success(rc5_8s)
	post5_8s = read_samples(m5_8s, :dataframe)
	ms5_8s = model_summary(post5_8s, [Symbol("a.1"), Symbol("a.2"), :sigma])
end

# ╔═╡ c0777af3-5bfa-4ec9-9a24-e88d21aab82d
md" #### Many categories."

# ╔═╡ 80eb4c84-5c43-4f2c-9a7a-6c8f7f8a92ea
begin
	milk = CSV.read(sr_datadir("milk.csv"), DataFrame; delim=';')
	milk[!, :clade_id] = Int.(indexin(milk[:, :clade], unique(milk[:, :clade])))
	scale_df_cols!(milk, [:kcal_per_g])
	milk
end

# ╔═╡ 54de96d1-52bb-4801-956a-e7bedd1d50b6
PRECIS(milk[:, [:clade_id, :kcal_per_g]])

# ╔═╡ 4a155621-d560-4d6d-850e-a9e57180bfe0
stan5_9 = "
data{
  int <lower=1> N;              // Sample size
  int <lower=1> k;
  vector[N] K;
  int clade_id[N];
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

# ╔═╡ 535c6009-ac50-4b9b-a9a4-91b67108fc07
let
	data = (N = size(milk, 1), clade_id = milk.clade_id,
    	K = milk.kcal_per_g_s, k = length(unique(milk[:, :clade_id])))
	global m5_9s = SampleModel("m5.9", stan5_9)
	global rc5_9s = stan_sample(m5_9s; data)

	success(rc5_9s) && describe(m5_9s, ["a[1]", "a[2]", "a[3]", "a[4]", "sigma"])
end

# ╔═╡ fa3179c5-8b79-4b05-843a-b906de956aea
if success(rc5_9s)
	post5_9s_df = read_samples(m5_9s, :dataframe)
	PRECIS(post5_9s_df)
end

# ╔═╡ 689d48c4-100d-437c-aa11-42125d26b326
model_summary(post5_9s_df, [Symbol("a.1"), Symbol("a.2"), Symbol("a.3"), Symbol("a.4"), :sigma])

# ╔═╡ 0d2d8423-ec6a-4ce5-a069-fc0fabd824f1
if success(rc5_9s)
	(s1, f1) = plot_model_coef([m5_9s], 
		[Symbol("a.1"), Symbol("a.2"), Symbol("a.3"), Symbol("a.4"), :sigma]; 
	title="Comparison of `a` coefficients for categories")
	f1
end


# ╔═╡ Cell order:
# ╟─645d4df3-af64-489b-b2b0-e710d8917680
# ╟─234d835c-b651-4b16-9f2e-986eda90a1a8
# ╠═fbc882d4-18b0-4f08-a1b1-ec4c4f78635d
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═76b6ce64-9f9b-48fa-8ef4-8ee1a0723bf0
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─4b4ddf89-b54a-4744-a7e2-2c06b0ebcc80
# ╠═2195f047-416a-40bc-ab00-fd5bef502e62
# ╠═c67411f7-bd2a-42d8-86dd-bea5e435b4fc
# ╟─74b9ca50-8c24-40ab-a89e-0e022a01345c
# ╠═c65770e3-d43c-4368-bdf2-55efb76db580
# ╠═885827cc-a6f4-4658-b3f1-1c8e1a529035
# ╟─c0777af3-5bfa-4ec9-9a24-e88d21aab82d
# ╠═80eb4c84-5c43-4f2c-9a7a-6c8f7f8a92ea
# ╠═54de96d1-52bb-4801-956a-e7bedd1d50b6
# ╠═4a155621-d560-4d6d-850e-a9e57180bfe0
# ╠═535c6009-ac50-4b9b-a9a4-91b67108fc07
# ╠═fa3179c5-8b79-4b05-843a-b906de956aea
# ╠═689d48c4-100d-437c-aa11-42125d26b326
# ╠═0d2d8423-ec6a-4ce5-a069-fc0fabd824f1
