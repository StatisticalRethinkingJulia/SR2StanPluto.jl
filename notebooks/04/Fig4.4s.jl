### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 3d34e5be-fb5a-11ea-078e-e5f5257c36aa
using Pkg, DrWatson

# ╔═╡ 3d35172a-fb5a-11ea-2f8c-e5415c94ddbd
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 39c55d48-fb5a-11ea-06e4-25dbf801a6e3
md"## Fig4.4s.jl"

# ╔═╡ 3d3c66b2-fb5a-11ea-168c-7b6f540dc3a1
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';');
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ 3d4e8354-fb5a-11ea-1017-67b29f9e14d5
md"### Snippet 4.16"

# ╔═╡ 3d517b36-fb5a-11ea-2594-49d7675ee3df
md"##### Generate approximate probabilities."

# ╔═╡ 3d5e518a-fb5a-11ea-2dd0-2fea73211321
function grid_prob(x, y, prior_x, prior_y, obs)

  df = DataFrame()
  grid = reshape([ [x,y]  for x=x, y=y ], length(x)*length(y))

  # Define the priors

  d2 = Normal(178.0, 20.0)
  d3 = Uniform(0, 50)

  # Compute the log(likelihood * prior)

  the_prod = []
  for i in 1:length(grid)
	d1 = Normal(grid[i][1], grid[i][2])
	ll = sum(log.(pdf.(d1, obs)))
	append!(df, DataFrame(mu=grid[i][1], sigma=grid[i][2], ll=ll))
	append!(the_prod, ll + log.(pdf.(prior_x, grid[i][1])) +  log.(pdf.(prior_y, grid[i][2])))
  end

  # Make it a probability

  df.prob = exp.(the_prod .- maximum(the_prod))
  df
end

# ╔═╡ 4acacbf0-fb5a-11ea-1cf6-072711635fbf
begin
	mu_list = range(150, 160, length=100)
	sigma_list = range(7, 9, length=100)
	prior_mu = Normal(178.0, 20.0)
	prior_sigma = Uniform(0, 50)
end

# ╔═╡ 75c1d0ba-fb5a-11ea-01ff-07c1b83566fb
md"### snippet 4.17"

# ╔═╡ 75c206a2-fb5a-11ea-08e6-33067b498efe
begin
	post_df = grid_prob(mu_list, sigma_list, prior_mu, prior_sigma,
	  df[:, :height])

	fig1 = contour(mu_list, sigma_list, post_df[:, :prob],
	  xlim = (153.5, 155.7),
	  ylim = (7.0, 8.5),
	  xlab="height",
	  ylab="sigma",
	  title="Contour")
end

# ╔═╡ 75c2b7aa-fb5a-11ea-1f80-7763cafbabcb
md"### snippet 4.18"

# ╔═╡ 929016ac-fb5a-11ea-2850-8dc437ebc9b5
fig2 = heatmap(mu_list, sigma_list, transpose(reshape(post_df[:, :prob], 100,100)),
  xlim = (153.5, 155.7),
  ylim = (7.0, 8.5),
  xlab="height",
  ylab="sigma",
  title="Heatmap")

# ╔═╡ 95611342-fb5a-11ea-27e2-2d04f8d7ba80
md"### Snippet 4.19"

# ╔═╡ 95615080-fb5a-11ea-2611-e5a331dc489d
md"##### Sample post_df."

# ╔═╡ 9562084a-fb5a-11ea-2db7-4b8e14fd5f5e
samples = post_df[sample(1:size(post_df, 1), Weights(post_df[:, :prob]), 10000, replace=true), :];

# ╔═╡ 9574982a-fb5a-11ea-2b18-3ddcf8f9d439
md"### Snippet 4.22"

# ╔═╡ 9575608e-fb5a-11ea-0872-451639a07f80
md"##### Convert to an MCMCChains.Chains object."

# ╔═╡ 9586946e-fb5a-11ea-306e-edb148625f90
begin
	a2d = hcat(samples[:, :mu], samples[:, :sigma])
	a3d = reshape(a2d, (size(a2d, 1), size(a2d, 2), 1))
	chn = convert_a3d(a3d, ["mu", "sigma"], Val(:mcmcchains); start=1)
	CHNS(chn)
end

# ╔═╡ 7aa6ebee-fb58-11ea-18e2-5dad90457b46
md"##### hpd regions."

# ╔═╡ a91331ac-fb5a-11ea-30f1-17727fb4b4e3
begin
	bnds = MCMCChains.hpd(chn)
	HPD(chn)
end

# ╔═╡ a9138058-fb5a-11ea-107f-49a1e879a358
md"### Snippet 4.21"

# ╔═╡ a91449dc-fb5a-11ea-0b55-0bad6aa880a5
md"##### Density of mu."

# ╔═╡ a9274050-fb5a-11ea-303f-c78a442e85a2
begin
	fig3 = density(samples[:, :mu],
	  xlab="height",
	  ylab="density",
	  lab="mu",
	  title="posterior mu")
	vline!([bnds[:mu, :upper]], line=:dash, lab="Lower bound")
	vline!([bnds[:mu, :lower]], line=:dash, lab="Upper bound")
end

# ╔═╡ a92ee794-fb5a-11ea-1a9c-dd5dc869aa42
md"##### Density of sigma."

# ╔═╡ a9321cea-fb5a-11ea-1e8e-8f11ecb095ee
begin
	fig4 = density(samples[:, :sigma],
	  xlab="sigma",
	  ylab="density",
	  lab="sigma",
	  title="posterior sigma")
	vline!([bnds[:sigma, :upper]], line=:dash, lab="Lower bound")
	vline!([bnds[:sigma, :lower]], line=:dash, lab="Upper bound")
end

# ╔═╡ a94127a6-fb5a-11ea-38fb-9977442826f9
plot(fig1, fig2, fig3, fig4, layout=(2,2))

# ╔═╡ a94be68c-fb5a-11ea-3a48-8744e6400f9c
md"## End of Fig4.4s.jl"

# ╔═╡ Cell order:
# ╠═39c55d48-fb5a-11ea-06e4-25dbf801a6e3
# ╠═3d34e5be-fb5a-11ea-078e-e5f5257c36aa
# ╠═3d35172a-fb5a-11ea-2f8c-e5415c94ddbd
# ╠═3d3c66b2-fb5a-11ea-168c-7b6f540dc3a1
# ╟─3d4e8354-fb5a-11ea-1017-67b29f9e14d5
# ╟─3d517b36-fb5a-11ea-2594-49d7675ee3df
# ╠═3d5e518a-fb5a-11ea-2dd0-2fea73211321
# ╠═4acacbf0-fb5a-11ea-1cf6-072711635fbf
# ╟─75c1d0ba-fb5a-11ea-01ff-07c1b83566fb
# ╠═75c206a2-fb5a-11ea-08e6-33067b498efe
# ╟─75c2b7aa-fb5a-11ea-1f80-7763cafbabcb
# ╠═929016ac-fb5a-11ea-2850-8dc437ebc9b5
# ╟─95611342-fb5a-11ea-27e2-2d04f8d7ba80
# ╟─95615080-fb5a-11ea-2611-e5a331dc489d
# ╠═9562084a-fb5a-11ea-2db7-4b8e14fd5f5e
# ╟─9574982a-fb5a-11ea-2b18-3ddcf8f9d439
# ╟─9575608e-fb5a-11ea-0872-451639a07f80
# ╠═9586946e-fb5a-11ea-306e-edb148625f90
# ╟─7aa6ebee-fb58-11ea-18e2-5dad90457b46
# ╠═a91331ac-fb5a-11ea-30f1-17727fb4b4e3
# ╟─a9138058-fb5a-11ea-107f-49a1e879a358
# ╟─a91449dc-fb5a-11ea-0b55-0bad6aa880a5
# ╠═a9274050-fb5a-11ea-303f-c78a442e85a2
# ╟─a92ee794-fb5a-11ea-1a9c-dd5dc869aa42
# ╠═a9321cea-fb5a-11ea-1e8e-8f11ecb095ee
# ╠═a94127a6-fb5a-11ea-38fb-9977442826f9
# ╟─a94be68c-fb5a-11ea-3a48-8744e6400f9c
