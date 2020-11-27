### A Pluto.jl notebook ###
# v0.12.12

using Markdown
using InteractiveUtils

# ╔═╡ 6108e1d6-fc09-11ea-09f3-813584d0e90a
using Pkg, DrWatson

# ╔═╡ 610918ea-fc09-11ea-307f-d38169d14f3f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 22ef750a-fbbd-11ea-3e29-cf89af1d8084
md"## Clip-04-59-63s.jl"

# ╔═╡ 61098ea6-fc09-11ea-08e0-830addd82187
md"### Preliminary snippets."

# ╔═╡ 611674c2-fc09-11ea-2f6d-f72e6cec1b28
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	scale!(df, [:height, :weight])
end;

# ╔═╡ 61170ed2-fc09-11ea-0e31-9157c92154d6
md"##### Define the Stan language model."

# ╔═╡ 6123f1a8-fc09-11ea-2354-b5650434c87d
m4_8 = "
data{
    int N;
    real xbar;
    vector[N] height;
    vector[N] weight;
}
parameters{
    real a;
    real b;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    b ~ normal( 0 , 1 );
    a ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = a + b * weight[i];
    }
    height ~ normal( mu , sigma );
}
";

# ╔═╡ 61248756-fc09-11ea-10af-9f466044a138
md"##### Define the SampleModel, input data and samples."

# ╔═╡ 61309cbc-fc09-11ea-173d-cb33d7b82e8d
begin
	m4_8s = SampleModel("m4.8s", m4_8);
	m4_8_data = Dict(
	  "N" => size(df, 1), 
	  "height" => df.height_s, 
	  "weight" => df.weight_s,
	  "xbar" => mean(df.weight)
	);
	rc4_8s = stan_sample(m4_8s, data=m4_8_data)
end;

# ╔═╡ 61313e88-fc09-11ea-3da3-2f1cfc0eb392
unscaled_rethinking_result = "
        mean   sd   5.5%  94.5%
a     154.60 0.27 154.17 155.03
b       0.90 0.04   0.84   0.97
sigma   5.07 0.19   4.77   5.38
";

# ╔═╡ 613e2b7a-fc09-11ea-37df-c3957f1dcb86
if success(rc4_8s)
  sdf4_8s = read_summary(m4_8s)
end

# ╔═╡ 6145d0be-fc09-11ea-183e-13fdf81ae7d0
md"### Snippet 4.53"

# ╔═╡ 614e8dc6-fc09-11ea-16c9-19a4d2eed3e6
begin
	dfa4_8s = read_samples(m4_8s; output_format=:dataframe)

	title = "Height vs. Weight, regions are" * "\nshowing 89% of predicted heights (lightgrey)" *
		"\nand 89% hpd interval around the mean line (darkgrey)"
	plotbounds(
		df, :weight, :height,
		dfa4_8s, [:a, :b, :sigma];
		bounds=[:predicted, :hpdi],
		title=title,
		colors=[:lightblue, :darkgrey]
	)
end

# ╔═╡ 61580018-fc09-11ea-2b83-f77bffee0fff
md"## End of clip-04-53-58s.jl"

# ╔═╡ Cell order:
# ╟─22ef750a-fbbd-11ea-3e29-cf89af1d8084
# ╠═6108e1d6-fc09-11ea-09f3-813584d0e90a
# ╠═610918ea-fc09-11ea-307f-d38169d14f3f
# ╟─61098ea6-fc09-11ea-08e0-830addd82187
# ╠═611674c2-fc09-11ea-2f6d-f72e6cec1b28
# ╟─61170ed2-fc09-11ea-0e31-9157c92154d6
# ╠═6123f1a8-fc09-11ea-2354-b5650434c87d
# ╟─61248756-fc09-11ea-10af-9f466044a138
# ╠═61309cbc-fc09-11ea-173d-cb33d7b82e8d
# ╠═61313e88-fc09-11ea-3da3-2f1cfc0eb392
# ╠═613e2b7a-fc09-11ea-37df-c3957f1dcb86
# ╟─6145d0be-fc09-11ea-183e-13fdf81ae7d0
# ╠═614e8dc6-fc09-11ea-16c9-19a4d2eed3e6
# ╟─61580018-fc09-11ea-2b83-f77bffee0fff
