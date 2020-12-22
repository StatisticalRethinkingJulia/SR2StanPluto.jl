### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 1585e592-fc0e-11ea-09b3-85bd83e3893e
using Pkg, DrWatson

# ╔═╡ 15862766-fc0e-11ea-160b-09995fb8e8fc
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 6fdbe2ac-fc0d-11ea-0253-5fcd59eb669f
md"## Fig5.1s.jl"

# ╔═╡ 33c69ba4-01af-11eb-337e-19ecbe1fe80b
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame)
	
	# Use WaffleHouses/Populations = Waffle houses per million
	
	df.WaffleHouses = df.WaffleHouses ./ df.Population
	scale!(df, [:WaffleHouses, :Divorce])
end;

# ╔═╡ db17d86a-fc0e-11ea-2df9-716728b916e6
	PRECIS(df[:, 3:15])

# ╔═╡ 15937fa4-fc0e-11ea-0aaf-e7049b6392bf
stan5_0 = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] D; // Outcome (Divorce rate)
 vector[N] W; // Predictor ()
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

model {
  vector[N] mu;               // mu is a vector
  a ~ normal(0, 0.2);         //Priors
  bA ~ normal(0, 0.5);
  sigma ~ exponential(1);
  mu = a + bA * W;
  D ~ normal(mu , sigma);     // Likelihood
}
";

# ╔═╡ 15952660-fc0e-11ea-0820-a350ee0a6326
md"##### Define the SampleModel."

# ╔═╡ 15a204fc-fc0e-11ea-2b27-75d4236363d6
m5_0s = SampleModel("Fig5.1", stan5_0);

# ╔═╡ 15a36108-fc0e-11ea-310b-d50e8725f62c
md"##### Input data."

# ╔═╡ 15afbdfe-fc0e-11ea-15a5-9bf6506abf5d
wd_data = Dict("N" => size(df, 1), "D" => df[:, :Divorce_s],
    "W" => df[:, :WaffleHouses_s]);

# ╔═╡ 15b07488-fc0e-11ea-2bdd-558c18e223f5
md"##### Sample using StanSample."

# ╔═╡ 15bce25e-fc0e-11ea-3c0d-a761765fd79f
rc5_0s = stan_sample(m5_0s, data=wd_data);

# ╔═╡ 15c8b926-fc0e-11ea-0b2d-55290b7dfe24
if success(rc5_0s)
	begin

	  # Plot regression line using means and observations

	  post5_0s_df = read_samples(m5_0s; output_format=:dataframe)
	  part5_0s = Particles(post5_0s_df)
	end
end

# ╔═╡ 15ca02e2-fc0e-11ea-281e-194a9b83623d
if success(rc5_0s)
	q5_0s = quap(m5_0s)
	quap5_0s_df = sample(q5_0s)
	PRECIS(quap5_0s_df)
end

# ╔═╡ 3e6621a0-fc42-11ea-0790-6fdef3820273
md"##### Figure out which annotations we want."

# ╔═╡ 53b10c8c-fc3d-11ea-0cfa-f9a16db84264
df[[1, 4, 11, 20, 30, 40], [1, 2, 7, 9]]

# ╔═╡ da595b90-fc3d-11ea-252e-1d4c44f1545f
df[:,1]

# ╔═╡ 15d19672-fc0e-11ea-093b-bff8eaf427d2
if success(rc5_0s)
	begin
		p2 = plotbounds(
			df, :WaffleHouses, :Divorce,
			post5_0s_df, [:a, :bA, :sigma];
			bounds=[:predicted, :hpdi],
			title="Divorce rate vs. waffle houses per million" * "\nshowing predicted and hpd range",
			xlab="Waffle houses per million",
			ylab="Divorce rate"
		)
		for i in [1, 4, 11, 20, 30, 40]
			annotate!(p2, [(df[i, :WaffleHouses]+01.5, df[i, :Divorce], Plots.text(df[i, 2],
				6, :red, :right))])
		end
	end
	plot(p2)
end

# ╔═╡ 15df0b0e-fc0e-11ea-0ca7-459b93ac79d5
md"## End of Fig5.1s.jl"

# ╔═╡ Cell order:
# ╟─6fdbe2ac-fc0d-11ea-0253-5fcd59eb669f
# ╠═1585e592-fc0e-11ea-09b3-85bd83e3893e
# ╠═15862766-fc0e-11ea-160b-09995fb8e8fc
# ╠═33c69ba4-01af-11eb-337e-19ecbe1fe80b
# ╠═db17d86a-fc0e-11ea-2df9-716728b916e6
# ╠═15937fa4-fc0e-11ea-0aaf-e7049b6392bf
# ╟─15952660-fc0e-11ea-0820-a350ee0a6326
# ╠═15a204fc-fc0e-11ea-2b27-75d4236363d6
# ╟─15a36108-fc0e-11ea-310b-d50e8725f62c
# ╠═15afbdfe-fc0e-11ea-15a5-9bf6506abf5d
# ╟─15b07488-fc0e-11ea-2bdd-558c18e223f5
# ╠═15bce25e-fc0e-11ea-3c0d-a761765fd79f
# ╠═15c8b926-fc0e-11ea-0b2d-55290b7dfe24
# ╠═15ca02e2-fc0e-11ea-281e-194a9b83623d
# ╟─3e6621a0-fc42-11ea-0790-6fdef3820273
# ╠═53b10c8c-fc3d-11ea-0cfa-f9a16db84264
# ╠═da595b90-fc3d-11ea-252e-1d4c44f1545f
# ╠═15d19672-fc0e-11ea-093b-bff8eaf427d2
# ╟─15df0b0e-fc0e-11ea-0ca7-459b93ac79d5
