### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 4ade4692-fc0b-11ea-0b14-6b6cb2435655
using Pkg, DrWatson

# ╔═╡ 4ade84b6-fc0b-11ea-06ff-9517579c812c
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 181f0620-fc0a-11ea-1c2d-ff1a89cf0660
md"# Clip-04-64-68s.jl"

# ╔═╡ 4adf1662-fc0b-11ea-18b7-2f80e0a2d4f4
md"### Preliminary snippets."

# ╔═╡ 4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	scale!(df, [:height, :weight])
	df.weight_sq_s = df.weight_s.^2
	#scale!(df, [:weight_sq])
end;

# ╔═╡ 4af06c94-fc0b-11ea-128c-89bea7c3af63
md"##### Define the Stan language model."

# ╔═╡ 4afd2eb8-fc0b-11ea-2f26-7329e44823a5
m4_9 = "
data{
    int N;
    vector[N] height;
    vector[N] weight;
    vector[N] weight_sq;
}
parameters{
    real alpha;
    real beta1;
    real beta2;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    beta1 ~ lognormal( 0 , 1 );
    beta2 ~ normal( 0 , 1 );
    alpha ~ normal( 178 , 20 );
    mu = alpha + beta1 * weight + beta2 * weight_sq;
    height ~ normal( mu , sigma );
}
";

# ╔═╡ 4afec1ea-fc0b-11ea-1674-b59e51b9f027
md"##### Define the SampleModel, etc,"

# ╔═╡ 4b0b60fa-fc0b-11ea-3929-0f0077415fc7
begin
	m4_9s = SampleModel("weights", m4_9);
	heightsdata = Dict(
		"N" => size(df, 1), 
		"height" => df.height, 
		"weight" => df.weight_s,
		"weight_sq" => df.weight_sq_s
	);
	rc = stan_sample(m4_9s, data=heightsdata);
end;

# ╔═╡ 4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
rethinking = "
        mean   sd   5.5%  94.5%
a     146.06 0.37 145.47 146.65
b1     21.73 0.29  21.27  22.19
b2     -7.80 0.27  -8.24  -7.36
sigma   5.77 0.18   5.49   6.06
";

# ╔═╡ 4b2030de-fc0b-11ea-3bce-0b80a6338b7e
if success(rc)
  sdf = read_summary(m4_9s)
end

# ╔═╡ 4b2109c8-fc0b-11ea-0aed-2b80f6b14188
md"### Snippet 4.53 - 4.67"

# ╔═╡ 4b30dc0e-fc0b-11ea-30c4-05c83cf73fda
if success(rc)
	begin
		dfa = read_samples(m4_9s; output_format=:dataframe)

		function link_poly(dfa::DataFrame, xrange)
			vars = Symbol.(names(dfa))
			[dfa[:, vars[1]] + dfa[:, vars[2]] * x +  dfa[:, vars[3]] * x^2 for x in xrange]
		end

		mu_range = -2:0.1:2

		xbar = mean(df[:, :weight])
		mu = link_poly(dfa, mu_range);

		plot(xlab="weight_s", ylab="height")
		for (indx, mu_val) in enumerate(mu_range)
		for j in 1:length(mu_range)
			scatter!([mu_val], [mu[indx][j]], leg=false, color=:darkblue)
		end
		end
		scatter!(df.weight_s, df.height, color=:lightblue)
	end
end

# ╔═╡ 4b39d052-fc0b-11ea-2d21-755ffb969e42
if success(rc)
	plot(xlab="weight_s", ylab="height", leg=:bottomright)
	fheight(weight, a, b1, b2) = a + weight * b1 + weight^2 * b2
	testweights = -2:0.01:2
	arr = [fheight.(w, dfa.alpha, dfa.beta1, dfa.beta2) for w in testweights]
	m = [mean(v) for v in arr]
	quantiles = [quantile(v, [0.055, 0.945]) for v in arr]
	lower = [q[1] - m for (q, m) in zip(quantiles, m)]
	upper = [q[2] - m for (q, m) in zip(quantiles, m)]
	scatter!(df[:, :weight_s], df[:, :height], lab="Observations")
	plot!(testweights, m, ribbon = [lower, upper], lab="(0.055, 0.945) quantiles of mean")
end

# ╔═╡ 4b426096-fc0b-11ea-0563-e1115f34f39f
md"## End of clip-04-64-68s.jl"

# ╔═╡ Cell order:
# ╟─181f0620-fc0a-11ea-1c2d-ff1a89cf0660
# ╠═4ade4692-fc0b-11ea-0b14-6b6cb2435655
# ╠═4ade84b6-fc0b-11ea-06ff-9517579c812c
# ╟─4adf1662-fc0b-11ea-18b7-2f80e0a2d4f4
# ╠═4af00a44-fc0b-11ea-080c-e9f7bc30a1b1
# ╠═4af06c94-fc0b-11ea-128c-89bea7c3af63
# ╠═4afd2eb8-fc0b-11ea-2f26-7329e44823a5
# ╟─4afec1ea-fc0b-11ea-1674-b59e51b9f027
# ╠═4b0b60fa-fc0b-11ea-3929-0f0077415fc7
# ╠═4b0c03f2-fc0b-11ea-262d-a517e75a5b6b
# ╠═4b2030de-fc0b-11ea-3bce-0b80a6338b7e
# ╟─4b2109c8-fc0b-11ea-0aed-2b80f6b14188
# ╠═4b30dc0e-fc0b-11ea-30c4-05c83cf73fda
# ╠═4b39d052-fc0b-11ea-2d21-755ffb969e42
# ╟─4b426096-fc0b-11ea-0563-e1115f34f39f
