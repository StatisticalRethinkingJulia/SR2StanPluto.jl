### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ c436330a-fced-11ea-132d-85f5197a22b8
using Pkg, DrWatson

# ╔═╡ c43683be-fced-11ea-0575-f78e4551118a
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 1e3eaf90-fced-11ea-12c7-9f994f24a65d
md"## Clip-05-13s.jl"

# ╔═╡ 4bd1668a-81df-11eb-2096-ebf30ab5cd8a
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ 97b5bff4-81df-11eb-35f8-47a6d481ed6e
stan5_3 = "
data {
  int N;
  vector[N] divorce_s;
  vector[N] marriage_s;
  vector[N] medianagemarriage_s;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + + bA * medianagemarriage_s + bM * marriage_s;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  divorce_s ~ normal( mu , sigma );
}
";

# ╔═╡ 74ff3772-81e1-11eb-00f2-11ca8eb479ea
# Rethinking results
rethinking_results = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bM    -0.07 0.15 -0.31  0.18
bA    -0.61 0.15 -0.85 -0.37
sigma  0.79 0.08  0.66  0.91
";

# ╔═╡ 97b5fcee-81df-11eb-153a-1d3c25d4ae12
begin
	m5_3s = SampleModel("m5.3", stan5_3);
	m5_3_data = Dict(
	  "N" => size(df, 1), 
	  "divorce_s" => df[:, :Divorce_s],
	  "marriage_s" => df[:, :Marriage_s],
	  "medianagemarriage_s" => df[:, :MedianAgeMarriage_s] 
	)
	rc5_3s = stan_sample(m5_3s, data=m5_3_data);
	if success(rc5_3s)

		post5_3s_df = read_samples(m5_3s; output_format=:dataframe)
		PRECIS(post5_3s_df)
	end
end

# ╔═╡ c4470928-fced-11ea-14d1-df38dd138e54
if success(rc5_3s)
	begin
		title = "Divorce rate vs. Marriage rate" *
			"\nshowing predicted and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			post5_3s_df, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey],
			bounds=[:predicted, :hpdi]
		)
	end
end

# ╔═╡ c447c624-fced-11ea-23e3-297d5e57104e
md"## End of clip-05-13s.jl"

# ╔═╡ Cell order:
# ╟─1e3eaf90-fced-11ea-12c7-9f994f24a65d
# ╠═c436330a-fced-11ea-132d-85f5197a22b8
# ╠═c43683be-fced-11ea-0575-f78e4551118a
# ╠═4bd1668a-81df-11eb-2096-ebf30ab5cd8a
# ╠═97b5bff4-81df-11eb-35f8-47a6d481ed6e
# ╠═74ff3772-81e1-11eb-00f2-11ca8eb479ea
# ╠═97b5fcee-81df-11eb-153a-1d3c25d4ae12
# ╠═c4470928-fced-11ea-14d1-df38dd138e54
# ╟─c447c624-fced-11ea-23e3-297d5e57104e
