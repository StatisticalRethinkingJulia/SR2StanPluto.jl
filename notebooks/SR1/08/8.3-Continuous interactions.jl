### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 2fee026b-f071-4c3e-bc5b-9823177d9c4d
using Pkg

# ╔═╡ 99068a6b-1f0c-4176-86f2-7dff4b47a45b
begin
	using CSV
	using Random
	using StatsBase
	using DataFrames
	using StatsPlots
	using StatsFuns
	using LaTeXStrings
	using ParetoSmoothedImportanceSampling
	using StanSample
	using StatisticalRethinking
	using StatisticalRethinkingPlots
end

# ╔═╡ 1df2d09b-7860-4acc-9d38-665107152a43
md"## 8.3 Continuous interaction"

# ╔═╡ c351bdae-93b0-4da4-b5d9-52d54cf75f16
md"### Code 8.19"

# ╔═╡ ecd48461-e555-48f6-bde0-60f0a5366eb5
begin
	tulips = CSV.read(sr_datadir("tulips.csv"), DataFrame)
	describe(tulips)
end

# ╔═╡ 02dc0bff-cc65-4ad8-b3ed-c98b79dfc8ee
tulips

# ╔═╡ c5917b74-37da-46f2-993c-ee07c4a11275
md"## Code 8.20"

# ╔═╡ deb4cbe4-c54f-4f63-a51b-d6f50fc84526
begin
	tulips.blooms_std = tulips.blooms / maximum(tulips.blooms)
	tulips.water_cent = tulips.water .- mean(tulips.water)
	tulips.shade_cent = tulips.shade .- mean(tulips.shade);
	data = (n=size(tulips, 1), blooms_std=tulips.blooms_std, 
		water_cent=tulips.water_cent, shade_cent=tulips.shade_cent)
end;

# ╔═╡ 547a6c98-9abe-4841-973c-a18eefc8a466
md"### Code 8.21"

# ╔═╡ eff79e1c-6578-41da-9088-d48cafd6116d
let
	Random.seed!(1)
	a = rand(Normal(0.5, 1), 10^4)
	sum(@. (a < 0) | (a > 1))/length(a)
end

# ╔═╡ 3472f887-f38c-49c4-aff0-b8e6529cd68f
md"### Code 8.22"

# ╔═╡ 58700f15-d848-4e71-bd95-8020eda97993
let
	Random.seed!(1)
	a = rand(Normal(0.5, 0.25), 10^4)
	sum(@. (a < 0) | (a > 1))/length(a)
end

# ╔═╡ bf287860-1590-45ab-8377-08b12e48aae1
md"### Code 8.23"

# ╔═╡ cb92360e-de69-45f7-8bd3-b1cc3df6e36e
stan8_4 = "
data {
	int<lower=1> n;      
	vector[n] blooms_std; 
	vector[n] water_cent; 
	vector[n] shade_cent; 
}
parameters {
	real<lower=0> sigma;
	real a;
	real bw;
	real bs;
}
model {
	vector[n] mu = a + bw * water_cent + bs * shade_cent;
	blooms_std ~ normal(mu, sigma);
	sigma ~ exponential(1);
	bw ~ normal(0, 0.25);
	bs ~ normal(0, 0.25);
	a ~ normal(0.5, 0.25);
}
";

# ╔═╡ f58be685-4dcf-41ee-a17f-b775fa3e854e
begin
	m8_4s = SampleModel("m8.4s", stan8_4)
	rc8_4s = stan_sample(m8_4s; data)
	if success(rc8_4s)
		post8_4s_df = read_samples(m8_4s, :dataframe)
	end
	PRECIS(post8_4s_df)
end

# ╔═╡ 3bd5b2ee-ab4e-474d-8520-2a7e6c3b20c0
md"### Code 8.24"

# ╔═╡ 2a8bc878-115e-46ea-814c-af138f82a8dd
stan8_5 = "
data {
	int<lower=0> n;      
	vector[n] blooms_std; 
	vector[n] water_cent; 
	vector[n] shade_cent; 
}
parameters {
	real<lower=0> sigma;
	real a;
	real bw;
	real bs;
	real bws;
}
transformed parameters {
	vector[n] mu;
	mu = a + bw * water_cent + bs * shade_cent + bws * water_cent .* shade_cent;
}
model {
	blooms_std ~ normal(mu, sigma);
	sigma ~ exponential(1);
	bw ~ normal(0, 0.25);
	bs ~ normal(0, 0.25);
	bws ~ normal(0, 0.25);
	a ~ normal(0.5, 0.25);
}
";

# ╔═╡ 76f1a531-95af-4b28-8273-80233a5bcb53
begin
	m8_5s = SampleModel("m8.5s", stan8_5)
	rc8_5s = stan_sample(m8_5s; data)
	if success(rc8_5s)
		post8_5s_df = read_samples(m8_5s, :dataframe)
	end
	PRECIS(post8_5s_df[:, [:a, :bs, :bw, :bws, :sigma]])
end

# ╔═╡ 6d82ff1b-16a8-4da4-8820-152dbc76bbe5
md"### Code 8.25"

# ╔═╡ 28beb1b8-5b06-4183-bc65-139bd40a581e
let
	plts = []
	
	for shade ∈ -1:1
	    idx = findall(==(shade), tulips.shade_cent)
	    p = plot(xlims=(-1.2,1.2), ylims=(-.2,1.2), xlab="water", ylab="blooms", 
	             title="shade=$shade", titlefontsize=12, leg=false)
	    scatter!(tulips.water_cent[idx], tulips.blooms_std[idx])
	    water_seq = -1:1
	    mu = link(post8_4s_df, (r, water) -> r.a + r.bw * water + r.bs * shade, 
			water_seq)
	    mu = hcat(mu...);
	    for μ ∈ first(eachrow(mu), 20)
	        plot!(water_seq, μ, c=:black, alpha=0.2)
	    end
	    push!(plts, p)
	end
	plot(plts..., layout=(1, 3), size=(800, 400), plot_title="m8.4s post", 
		plot_titlefontsize=14)
end

# ╔═╡ c39aef76-7245-4cc3-9fc1-f86edc708416
let
	plts = []
	
	for shade ∈ -1:1
	    idx = findall(==(shade), tulips.shade_cent)
	    p = plot(xlims=(-1.2,1.2), ylims=(-.2,1.2), xlab="water", ylab="blooms", 
	             title="shade=$shade", titlefontsize=12, leg=false)
	    scatter!(tulips.water_cent[idx], tulips.blooms_std[idx])
	    water_seq = -1:1
	    mu = link(post8_5s_df, (r, water) -> r.a + r.bw*water + r.bs*shade + 
			r.bws*water*shade, water_seq)
	    mu = hcat(mu...);
	    for μ ∈ first(eachrow(mu), 20)
	        plot!(water_seq, μ, c=:black, alpha=0.2)
	    end
	    push!(plts, p)
	end
	plot(plts..., layout=(1, 3), size=(800, 400), plot_title="m8.5s post", 
		plot_titlefontsize=14)
end

# ╔═╡ 539cef32-4ab8-401a-95e9-a3d0c04f99ed
md"### Code 8.26"

# ╔═╡ 02f75016-dc94-40ed-b38c-125bc3b8847f
let
	data = (n=0, blooms_std=[], water_cent=[], shade_cent=[])
	m8_5s = SampleModel("m8.5s", stan8_5)
	rc8_5s = stan_sample(m8_5s; data)
	if success(rc8_5s)
		global priors8_5s_df = read_samples(m8_5s, :dataframe)
	end
	PRECIS(priors8_5s_df[:, [:a, :bs, :bw, :bws, :sigma]])
end	

# ╔═╡ fbdeeb1f-e335-4345-b258-d3e635cfc0bd
let
	plts = []
	
	for shade ∈ -1:1
	    p = plot(xlims=(-1, 1), ylims=(-0.5, 1.5), xlab="water", ylab="blooms", 
	             title="shade=$shade", titlefontsize=12, leg=false)
	    water_seq = -1:1
	    mu = link(priors8_5s_df, (r, water) -> r.a + r.bw*water + r.bs*shade + 
			r.bws*water*shade, water_seq)
	    mu = hcat(mu...);
	    for μ ∈ first(eachrow(mu), 20)
	        plot!(water_seq, μ, c=:black, alpha=0.2)
	    end
	    hline!([0.0, 1.0], s=:dash, c=:black)
	    push!(plts, p)
	end
	plot(plts..., layout=(1, 3), size=(800, 400), plot_title="m8.5 prior", 
		plot_titlefontsize=14)
end

# ╔═╡ 067b87f3-5756-4bc4-8b9c-d180578dc05d


# ╔═╡ Cell order:
# ╠═1df2d09b-7860-4acc-9d38-665107152a43
# ╠═2fee026b-f071-4c3e-bc5b-9823177d9c4d
# ╠═99068a6b-1f0c-4176-86f2-7dff4b47a45b
# ╠═c351bdae-93b0-4da4-b5d9-52d54cf75f16
# ╠═ecd48461-e555-48f6-bde0-60f0a5366eb5
# ╠═02dc0bff-cc65-4ad8-b3ed-c98b79dfc8ee
# ╠═c5917b74-37da-46f2-993c-ee07c4a11275
# ╠═deb4cbe4-c54f-4f63-a51b-d6f50fc84526
# ╠═547a6c98-9abe-4841-973c-a18eefc8a466
# ╠═eff79e1c-6578-41da-9088-d48cafd6116d
# ╠═3472f887-f38c-49c4-aff0-b8e6529cd68f
# ╠═58700f15-d848-4e71-bd95-8020eda97993
# ╠═bf287860-1590-45ab-8377-08b12e48aae1
# ╠═cb92360e-de69-45f7-8bd3-b1cc3df6e36e
# ╠═f58be685-4dcf-41ee-a17f-b775fa3e854e
# ╠═3bd5b2ee-ab4e-474d-8520-2a7e6c3b20c0
# ╠═2a8bc878-115e-46ea-814c-af138f82a8dd
# ╠═76f1a531-95af-4b28-8273-80233a5bcb53
# ╠═6d82ff1b-16a8-4da4-8820-152dbc76bbe5
# ╠═28beb1b8-5b06-4183-bc65-139bd40a581e
# ╠═c39aef76-7245-4cc3-9fc1-f86edc708416
# ╠═539cef32-4ab8-401a-95e9-a3d0c04f99ed
# ╠═02f75016-dc94-40ed-b38c-125bc3b8847f
# ╠═fbdeeb1f-e335-4345-b258-d3e635cfc0bd
# ╠═067b87f3-5756-4bc4-8b9c-d180578dc05d
