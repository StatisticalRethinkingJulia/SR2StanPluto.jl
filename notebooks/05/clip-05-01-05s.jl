### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg, DrWatson

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ e875dcfc-fc57-11ea-27e5-c56f1f9d5370
md"## clip-05-01-05s.jl"

# ╔═╡ d65e1360-fc58-11ea-11c0-5928313bb9a0
md"### snippet 5.1"

# ╔═╡ cfa44fec-01c5-11eb-14bf-338eed7e2c9d
md"##### Notice that in below Stan language model we ignore the observed data (the likelihood is commented out). The draws show sampled regression lines implied by the priors. This is an alternative to the formulation chosen in clip-04-01-05s.jl"

# ╔═╡ d65e98dc-fc58-11ea-25e1-9fab97b6125a
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
stan5_1_alt_priors = "
	data {
	 int < lower = 1 > N; // Sample size
	 vector[N] D; // Outcome
	 vector[N] A; // Predictor
	}

	parameters {
	 real a; // Intercept
	 real bA; // Slope (regression coefficients)
	 real < lower = 0 > sigma;    // Error SD
	}

	model {
	  vector[N] mu;               // mu is a vector
	  a ~ normal(0, 0.2);         // Priors
	  bA ~ normal(0, 0.5);
	  sigma ~ exponential(1);
	  mu = a + bA * A;
	  //D ~ normal(mu , sigma);   // Likelihood
	}
";

# ╔═╡ f4602d4a-fc59-11ea-0d9d-9f58c73c119f
md"### snippet 5.3 - 5.4"

# ╔═╡ d670aefa-fc58-11ea-1c56-4bfb66e1cab2
md"## Define the SampleModel, etc."

# ╔═╡ d67e0602-fc58-11ea-3a27-31d03e1c2318
begin
	m5_1s = SampleModel("MedianAgeMarriage", stan5_1_alt_priors)
	m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s)
	rc5_1s = stan_sample(m5_1s, data=m5_1_data)
	success(rc5_1s) && (post5_1s_df = read_samples(m5_1s, :dataframe))
end;

# ╔═╡ a4a9351a-01c6-11eb-28d0-71f8fb243719
PRECIS(post5_1s_df)

# ╔═╡ 12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
md"### snippet 5.5"

# ╔═╡ 45b2b002-01c6-11eb-3f86-3f9586afcc8b
md"##### Plot priors of the intercept (`:a`) and the slope (`:bA`)."

# ╔═╡ d68ab980-fc58-11ea-342d-31e66a8e7559
if success(rc5_1s)
	xi = -3.0:0.1:3.0
	plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
		title="Showing 50 regression lines")
	for i in 1:50
		local yi = mean(post5_1s_df[i, :a]) .+ post5_1s_df[i, :bA] .* xi
		plot!(xi, yi, color=:lightgrey, leg=false)
	end
	scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)
end

# ╔═╡ d69533ba-fc58-11ea-3378-e512a1d55d27
md"## End of clip-05-01-05.jl"

# ╔═╡ Cell order:
# ╟─e875dcfc-fc57-11ea-27e5-c56f1f9d5370
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─d65e1360-fc58-11ea-11c0-5928313bb9a0
# ╟─cfa44fec-01c5-11eb-14bf-338eed7e2c9d
# ╠═d65e98dc-fc58-11ea-25e1-9fab97b6125a
# ╠═d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
# ╟─f4602d4a-fc59-11ea-0d9d-9f58c73c119f
# ╟─d670aefa-fc58-11ea-1c56-4bfb66e1cab2
# ╠═d67e0602-fc58-11ea-3a27-31d03e1c2318
# ╠═a4a9351a-01c6-11eb-28d0-71f8fb243719
# ╟─12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
# ╟─45b2b002-01c6-11eb-3f86-3f9586afcc8b
# ╠═d68ab980-fc58-11ea-342d-31e66a8e7559
# ╟─d69533ba-fc58-11ea-3378-e512a1d55d27
