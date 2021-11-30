### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 79789782-8d97-11eb-112c-fd8c2c294527
using Pkg, DrWatson

# ╔═╡ dd81850e-8d97-11eb-0cff-8bf4f38f0660
begin
	#@quickactivate "SR2StanPluto"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ a3565770-8e31-11eb-1635-3b842d541ab6
md" ## Clip-11-01-08s.jl"

# ╔═╡ dd81af5c-8d97-11eb-10e4-73daebcd8875
begin
	df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame)
	df[!, "treatment"] = 1 .+ df.prosoc_left + 2 * df.condition
end;

# ╔═╡ 691258d8-8dab-11eb-3ec4-8b2059af0832
unique(df.treatment)

# ╔═╡ dd82254a-8d97-11eb-3f3d-59b7642304f5
stan11_1_1 = "
parameters {
 	real a;
}
model {
	a ~ normal(0, 10.0);
}
";

# ╔═╡ dd8c8ce4-8d97-11eb-1249-03382bfe3feb
begin
	m11_1_1s = SampleModel("m11.1.1s", stan11_1_1)
	rc11_1_1s = stan_sample(m11_1_1s)
end;

# ╔═╡ dd96b924-8d97-11eb-0d47-ffa72b39a875
if success(rc11_1_1s)
	post11_1_1s_df = read_samples(m11_1_1s, :dataframe)
	PRECIS(post11_1_1s_df)
end

# ╔═╡ 8436e374-8e3a-11eb-0e48-d10c66f248a4
if success(rc11_1_1s)
	p1 = logistic.(post11_1_1s_df.a)
	mean(p1)
end

# ╔═╡ dce2c76c-8e3b-11eb-1b40-a739dda46d0b
stan11_1_2 = "
parameters {
 	real a;
}
model {
	a ~ normal(0, 1.5);
}
";

# ╔═╡ 61c85042-8daa-11eb-392e-45b1d7adb978
begin
	m11_1_2s = SampleModel("m11.1.2s", stan11_1_2)
	rc11_1_2s = stan_sample(m11_1_2s)
end;

# ╔═╡ dc1a5f76-8e3a-11eb-1a9d-4374c4fadbc2
if success(rc11_1_2s)
	post11_1_2s_df = read_samples(m11_1_2s, :dataframe)
	PRECIS(post11_1_2s_df)
end

# ╔═╡ dc1a8a32-8e3a-11eb-0173-11ea33425350
if success(rc11_1_2s)
	p2 = logistic.(post11_1_2s_df.a)
end

# ╔═╡ dc1b3d88-8e3a-11eb-3167-0726ac404587
if success(rc11_1_1s) && success(rc11_1_2s)
	density(p1, lab="p1")
	density!(p2, lab="p2")
end

# ╔═╡ 83a05b7a-8e30-11eb-23f4-cdf5fa972dd4
stan11_2 = "
data {
  int N;
  int K;
  int<lower=1, upper=4> treatment[N];
  //int<lower=0,upper=1> pulled_left[N];
}
parameters {
  real a;
  vector[K] b;
}
model {
	a ~ normal(0, 1.5);
    b ~ normal(0, 0.5);
 	//pulled_left ~ binomial_logit(a + b[treatment]);
}
";

# ╔═╡ dcd3f5b0-8e30-11eb-1a78-451a3437b6d6
begin
	m11_2s = SampleModel("m11.2s", stan11_2)
	data3 = (N = size(df, 1), K = length(unique(df.treatment)),
		pulled_left = df.pulled_left, treatment = df.treatment)
	rc11_2s = stan_sample(m11_2s; data=data3)
end;

# ╔═╡ dcd4235c-8e30-11eb-2130-a5027eb07957
if success(rc11_2s)
	post11_2s_df = read_samples(m11_2s, :dataframe)
	PRECIS(post11_2s_df)
end

# ╔═╡ dcd4dc46-8e30-11eb-33e4-67633257f5df
begin
	nt11_2s = read_samples(m11_2s, :namedtuple)
	p3 = [logistic.(nt11_2s.a .+ nt11_2s.b[i]) for i in 1:4]
	mean.([p3[i] for i in 1:4])
end

# ╔═╡ dce32f32-8e30-11eb-0db6-670aa2e9e017
mean(abs.(p3[1] - p3[2]))

# ╔═╡ dce3ebc0-8e30-11eb-0c16-53439160c3b9
begin
	density(p1, ylims=(0, 10), lab="p1")
	density!(p2, lab="p2")
	density!(abs.(p3[1] - p3[2]), lab="p3")
end

# ╔═╡ b6a6c8e6-8e31-11eb-3276-2d3f9297fe70
md" ## End of clip-11-01-08s.jl"

# ╔═╡ Cell order:
# ╟─a3565770-8e31-11eb-1635-3b842d541ab6
# ╠═79789782-8d97-11eb-112c-fd8c2c294527
# ╠═dd81850e-8d97-11eb-0cff-8bf4f38f0660
# ╠═dd81af5c-8d97-11eb-10e4-73daebcd8875
# ╠═691258d8-8dab-11eb-3ec4-8b2059af0832
# ╠═dd82254a-8d97-11eb-3f3d-59b7642304f5
# ╠═dd8c8ce4-8d97-11eb-1249-03382bfe3feb
# ╠═dd96b924-8d97-11eb-0d47-ffa72b39a875
# ╠═8436e374-8e3a-11eb-0e48-d10c66f248a4
# ╠═dce2c76c-8e3b-11eb-1b40-a739dda46d0b
# ╠═61c85042-8daa-11eb-392e-45b1d7adb978
# ╠═dc1a5f76-8e3a-11eb-1a9d-4374c4fadbc2
# ╠═dc1a8a32-8e3a-11eb-0173-11ea33425350
# ╠═dc1b3d88-8e3a-11eb-3167-0726ac404587
# ╠═83a05b7a-8e30-11eb-23f4-cdf5fa972dd4
# ╠═dcd3f5b0-8e30-11eb-1a78-451a3437b6d6
# ╠═dcd4235c-8e30-11eb-2130-a5027eb07957
# ╠═dcd4dc46-8e30-11eb-33e4-67633257f5df
# ╠═dce32f32-8e30-11eb-0db6-670aa2e9e017
# ╠═dce3ebc0-8e30-11eb-0c16-53439160c3b9
# ╟─b6a6c8e6-8e31-11eb-3276-2d3f9297fe70
