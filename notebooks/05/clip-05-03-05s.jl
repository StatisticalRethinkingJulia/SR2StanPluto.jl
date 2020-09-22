### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 16ddb41a-fc59-11ea-1631-153e3466c75c
using Pkg, DrWatson

# ╔═╡ d65dd2b2-fc58-11ea-2300-4db47ec9a789
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ e875dcfc-fc57-11ea-27e5-c56f1f9d5370
md"## clip-05-03-05s.jl"

# ╔═╡ d65e1360-fc58-11ea-11c0-5928313bb9a0
md"### snippet 5.1"

# ╔═╡ d65e98dc-fc58-11ea-25e1-9fab97b6125a
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame; delim=';');
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
m5_1 = "
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
m5_1s = SampleModel("MedianAgeMarriage", m5_1);

# ╔═╡ d67ea35c-fc58-11ea-2f14-a34cdc172628
m5_1_data = Dict("N" => size(df, 1), "D" => df.Divorce_s, "A" => df.MedianAgeMarriage_s);

# ╔═╡ d689eb54-fc58-11ea-146f-edd32afb6cf6
rc = stan_sample(m5_1s, data=m5_1_data);

# ╔═╡ 12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
md"### snippet 5.5"

# ╔═╡ d68ab980-fc58-11ea-342d-31e66a8e7559
if success(rc)
	begin

		# Plot regression line using means and observations

		dfa = read_samples(m5_1s; output_format=:dataframe)
		xi = -3.0:0.1:3.0
		plot(xlab="Medium age marriage (scaled)", ylab="Divorce rate (scaled)",
			title="Showing 50 regression lines")
		for i in 1:50
			local yi = mean(dfa[i, :a]) .+ dfa[i, :bA] .* xi
			plot!(xi, yi, color=:lightgrey, leg=false)
		end

		scatter!(df[:, :MedianAgeMarriage_s], df[!, :Divorce_s], color=:darkblue)

	end

end

# ╔═╡ d69533ba-fc58-11ea-3378-e512a1d55d27
md"## End of clip-05-03-05.jl"

# ╔═╡ Cell order:
# ╠═e875dcfc-fc57-11ea-27e5-c56f1f9d5370
# ╠═16ddb41a-fc59-11ea-1631-153e3466c75c
# ╠═d65dd2b2-fc58-11ea-2300-4db47ec9a789
# ╟─d65e1360-fc58-11ea-11c0-5928313bb9a0
# ╠═d65e98dc-fc58-11ea-25e1-9fab97b6125a
# ╠═d66f515e-fc58-11ea-3fae-cbb82f1a1a6a
# ╟─f4602d4a-fc59-11ea-0d9d-9f58c73c119f
# ╟─d670aefa-fc58-11ea-1c56-4bfb66e1cab2
# ╠═d67e0602-fc58-11ea-3a27-31d03e1c2318
# ╠═d67ea35c-fc58-11ea-2f14-a34cdc172628
# ╠═d689eb54-fc58-11ea-146f-edd32afb6cf6
# ╟─12fedbca-fc5a-11ea-2d4d-1d5ac93ac4fa
# ╠═d68ab980-fc58-11ea-342d-31e66a8e7559
# ╟─d69533ba-fc58-11ea-3378-e512a1d55d27
