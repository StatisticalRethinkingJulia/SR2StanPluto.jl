### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ a4fef4fe-f36a-11ea-244e-cdb543d14fd8
using Pkg, DrWatson

# ╔═╡ a4ff2640-f36a-11ea-062f-2d35275f2b12
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ ebda0e64-f369-11ea-072e-239cd87efc28
md"## Clip-03-06-10s.jl"

# ╔═╡ a4ff9ce2-f36a-11ea-2729-0705057ce156
md"### snippet 3.2"

# ╔═╡ a50ce9d8-f36a-11ea-3ef1-b3256e84a761
begin
	p_grid = range(0, step=0.001, stop=1)
	prior = ones(length(p_grid))
	likelihood = [pdf(Binomial(9, p), 6) for p in p_grid]
	posterior = likelihood .* prior
	posterior = posterior / sum(posterior)
end;

# ╔═╡ a5112304-f36a-11ea-00e8-c7a181813a3c
md"### snippet 3.3"

# ╔═╡ a51b0cd4-f36a-11ea-15c3-67e40bc741f0
md"##### Draw 10000 samples from this posterior distribution."

# ╔═╡ a51b8858-f36a-11ea-1e51-395eb0b3d22f
begin
	N = 10000
	samples = sample(p_grid, Weights(posterior), N)
end;

# ╔═╡ a5246036-f36a-11ea-06ba-e15630b3b040
md"##### Store samples in an MCMCChains.Chains object."

# ╔═╡ a524d2fa-f36a-11ea-0113-11b1e9ffe306
chn = MCMCChains.Chains(reshape(samples, N, 1, 1), ["toss"]);

# ╔═╡ a52f7ba6-f36a-11ea-16cd-5de42e29f3b4
md"##### Describe the chain."

# ╔═╡ a53460f8-f36a-11ea-13f9-af8cf26fdf2c
chn

# ╔═╡ 4ddc489c-f36b-11ea-121b-e3e288b12fdf
md"##### Plot the chain."

# ╔═╡ 5c369870-f36b-11ea-3eae-3b11cc0614fa
plot(chn)

# ╔═╡ a53cf4ac-f36a-11ea-075d-ffcf6547d4b0
md"### snippet 3.6"

# ╔═╡ a541cac2-f36a-11ea-25c0-fb4a7cd4320f
begin
	v = 0.0
	for i in 1:length(p_grid)
	  global v
	  if p_grid[i] < 0.5
		v += posterior[i]
	  end
	end
	v
end

# ╔═╡ 758de3a0-f389-11ea-3065-375491113043
mapreduce(p -> p < 0.5 ? p : 0, +, samples) / N

# ╔═╡ a5452fe4-f36a-11ea-012f-3b9363b0bc55
md"### snippet 3.7"

# ╔═╡ a54b93d6-f36a-11ea-034d-7f9a0b257a2e
mapreduce(p -> p < 0.5 ? 1 : 0, +, samples) / N

# ╔═╡ a55285c4-f36a-11ea-2efd-a1eaa158dd93
md"### snippet 3.8"

# ╔═╡ a558b1ec-f36a-11ea-1f56-b506f4939cdc
mapreduce(p -> (p > 0.5 && p < 0.75) ? 1 : 0, +, samples) / N

# ╔═╡ a55ef4ee-f36a-11ea-3ff6-8737718563c7
md"### snippet 3.9"

# ╔═╡ a5695a74-f36a-11ea-1476-a9425b2b38a5
quantile(samples, 0.8)

# ╔═╡ a56c4216-f36a-11ea-20c0-0fd3bb1e32a0
md"### snippet 3.10"

# ╔═╡ a5730a24-f36a-11ea-3d02-df3631450b3b
quantile(samples, [0.1, 0.9])

# ╔═╡ 1e78e006-f36b-11ea-11ac-87b9baccdde1


# ╔═╡ a57a49ec-f36a-11ea-167c-e1d90e858751
md"## End of clip-03-06-10s.jl"

# ╔═╡ Cell order:
# ╟─ebda0e64-f369-11ea-072e-239cd87efc28
# ╠═a4fef4fe-f36a-11ea-244e-cdb543d14fd8
# ╠═a4ff2640-f36a-11ea-062f-2d35275f2b12
# ╟─a4ff9ce2-f36a-11ea-2729-0705057ce156
# ╠═a50ce9d8-f36a-11ea-3ef1-b3256e84a761
# ╟─a5112304-f36a-11ea-00e8-c7a181813a3c
# ╟─a51b0cd4-f36a-11ea-15c3-67e40bc741f0
# ╠═a51b8858-f36a-11ea-1e51-395eb0b3d22f
# ╟─a5246036-f36a-11ea-06ba-e15630b3b040
# ╠═a524d2fa-f36a-11ea-0113-11b1e9ffe306
# ╟─a52f7ba6-f36a-11ea-16cd-5de42e29f3b4
# ╠═a53460f8-f36a-11ea-13f9-af8cf26fdf2c
# ╟─4ddc489c-f36b-11ea-121b-e3e288b12fdf
# ╠═5c369870-f36b-11ea-3eae-3b11cc0614fa
# ╟─a53cf4ac-f36a-11ea-075d-ffcf6547d4b0
# ╠═a541cac2-f36a-11ea-25c0-fb4a7cd4320f
# ╠═758de3a0-f389-11ea-3065-375491113043
# ╟─a5452fe4-f36a-11ea-012f-3b9363b0bc55
# ╠═a54b93d6-f36a-11ea-034d-7f9a0b257a2e
# ╟─a55285c4-f36a-11ea-2efd-a1eaa158dd93
# ╠═a558b1ec-f36a-11ea-1f56-b506f4939cdc
# ╟─a55ef4ee-f36a-11ea-3ff6-8737718563c7
# ╠═a5695a74-f36a-11ea-1476-a9425b2b38a5
# ╟─a56c4216-f36a-11ea-20c0-0fd3bb1e32a0
# ╠═a5730a24-f36a-11ea-3d02-df3631450b3b
# ╠═1e78e006-f36b-11ea-11ac-87b9baccdde1
# ╟─a57a49ec-f36a-11ea-167c-e1d90e858751
