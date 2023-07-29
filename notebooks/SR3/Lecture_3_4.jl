### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 859783d0-73c9-4d1a-aab7-1d1bc474389e
using Pkg

# ╔═╡ c80881ad-605b-40fc-a492-d253fef966c8
Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
    # General packages
    using LaTeXStrings

	# Graphics related packages
	using CairoMakie
	
	# Stan related packages
	using StanSample

	# Project functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 00d5774b-5ef0-4d01-b21d-1749beec466a
md"## SR 2023: Lectures 3 and 4."

# ╔═╡ bd8e4305-bb79-409b-9930-e11e579b8cd0
md"##### Set page layout for notebook."

# ╔═╡ da00c7fe-43ff-4e3a-ab43-0dfd9444f779
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 3%);
    	padding-right: max(5px, 25%);
	}
</style>
"""

# ╔═╡ 0f2f43f6-d3f6-43aa-9624-d2be810a261b
md"### Julia code snippet 4.7"

# ╔═╡ 591eeff9-52fd-4f9f-8a8a-10d94e49d89c
begin
	howell1_2023 = CSV.read(sr_datadir("2023/Howell1.csv"), DataFrame)
	d2 = howell1_2023[howell1_2023.age .> 18,:]
	scale_df_cols!(d2, [:height, :weight])
end

# ╔═╡ 5c68fc71-42f3-4198-b661-b42b4b1a5cb3
stan1_0 = "
data {
	int N;
	real W[N];
	real H[N];
}
parameters {
	real a;
	real b;
	real<lower=0> sigma;
}
transformed parameters {
    vector[N] mu;
	for (i in 1:N)
    	mu[i] = a + b * H[i];
}
model {
	// Priors for a, b and sigma
	a ~ uniform(0, 1);
	b ~ normal(0, 10);
	sigma ~ exponential(1);
	
	// Observed heights
	W ~ normal(mu, sigma);
}
generated quantities {
	vector[N] log_lik;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(W[i] | mu[i], sigma);
}
";

# ╔═╡ 2eaf889e-b371-4bf1-8382-e92d6734bc37
let
	data = (N = length(d2.height_s), H = d2.height_s, W = d2.weight_s)
	global m1_0s = SampleModel("m1.0s", stan1_0)
	global rc1_0s = stan_sample(m1_0s; data)
	if success(rc1_0s) 
	  global post1_0s_df = read_samples(m1_0s, :dataframe)          # DataFrame with samples
	  model_summary(post1_0s_df, [:a, :b, :sigma])
	end
end

# ╔═╡ efc044dd-b1ce-4635-a663-1296d7080bc3
if success(rc1_0s)
	nt1_0s = read_samples(m1_0s, :namedtuple)
	log_lik = nt1_0s.log_lik'
	n_sam, n_obs = size(log_lik)
end

# ╔═╡ ac6ed0e0-09d7-4eb3-a486-9ccd48eeb8a9
log_lik

# ╔═╡ 9ab25a70-8e23-498b-84c0-cc3fad317188
md"### Julia code snippet 4.15"

# ╔═╡ c366fcaf-0898-4e00-a0b0-ccd27837a67b
let
    sample_μ = rand(Normal(178, 100), 10000)
	sample_σ = rand(Uniform(0, 50), 10000)
    prior_h = [rand(Normal(μ, σ)) for (μ, σ) in zip(sample_μ, sample_σ)]
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
	density!(prior_h)
	vlines!([0, 272])
	f
end

# ╔═╡ 77ae1357-ccee-4eb3-88c8-573582aa451b
let
	f = Figure(resolution=default_figure_resolution)
    size = 10_000
	    
	ax = Axis(f[1, 1]; title="mu ~ rand(Normal(178, 20), $size)", xlabel="μ")
	xlims!(0, 300)

    f
end

# ╔═╡ Cell order:
# ╟─00d5774b-5ef0-4d01-b21d-1749beec466a
# ╟─bd8e4305-bb79-409b-9930-e11e579b8cd0
# ╠═da00c7fe-43ff-4e3a-ab43-0dfd9444f779
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─0f2f43f6-d3f6-43aa-9624-d2be810a261b
# ╠═591eeff9-52fd-4f9f-8a8a-10d94e49d89c
# ╠═5c68fc71-42f3-4198-b661-b42b4b1a5cb3
# ╠═2eaf889e-b371-4bf1-8382-e92d6734bc37
# ╠═efc044dd-b1ce-4635-a663-1296d7080bc3
# ╠═ac6ed0e0-09d7-4eb3-a486-9ccd48eeb8a9
# ╟─9ab25a70-8e23-498b-84c0-cc3fad317188
# ╠═c366fcaf-0898-4e00-a0b0-ccd27837a67b
# ╠═77ae1357-ccee-4eb3-88c8-573582aa451b
