### A Pluto.jl notebook ###
# v0.12.13

using Markdown
using InteractiveUtils

# ╔═╡ 9f10e30a-fcec-11ea-1ca8-f1ad8754f845
using Pkg, DrWatson

# ╔═╡ 9f11214e-fcec-11ea-2002-6541f7abc779
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 9f11aca4-fcec-11ea-0d60-2549341d0fc8
include(projectdir("models", "05", "m5.2s.jl"))

# ╔═╡ e2e2c948-fceb-11ea-20e0-f19b598a9e90
md"## Clip-05-06-09s.jl"

# ╔═╡ 9f1dddee-fcec-11ea-2328-dbd9ddc2be94
if success(rc5_2s)
	post5_2s_df = read_samples(m5_2s; output_format=:dataframe)
	part5_2s = Particles(post5_2s_df) 
end

# ╔═╡ 9f1e7e82-fcec-11ea-203c-bf2312bf2fc6
success(rc5_2s) && quap(post5_2s_df)

# ╔═╡ 9f27c84a-fcec-11ea-005e-97c59812d16e
# Rethinking results

rethinking_results = "
	  mean   sd  5.5% 94.5%
a     0.00 0.11 -0.17  0.17
bM    0.35 0.13  0.15  0.55
sigma 0.91 0.09  0.77  1.05
";

# ╔═╡ 9f284e50-fcec-11ea-3eec-4160f696255c
if success(rc5_2s)
	begin
		title = "Divorce rate vs. Marriage rate" * "\nshowing sample and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			post5_2s_df, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey]
		)
	end
end

# ╔═╡ 9f329860-fcec-11ea-012b-b59bc79f7336
md"## End of clip-05-06-10s.jl"

# ╔═╡ Cell order:
# ╟─e2e2c948-fceb-11ea-20e0-f19b598a9e90
# ╠═9f10e30a-fcec-11ea-1ca8-f1ad8754f845
# ╠═9f11214e-fcec-11ea-2002-6541f7abc779
# ╠═9f11aca4-fcec-11ea-0d60-2549341d0fc8
# ╠═9f1dddee-fcec-11ea-2328-dbd9ddc2be94
# ╠═9f1e7e82-fcec-11ea-203c-bf2312bf2fc6
# ╠═9f27c84a-fcec-11ea-005e-97c59812d16e
# ╠═9f284e50-fcec-11ea-3eec-4160f696255c
# ╟─9f329860-fcec-11ea-012b-b59bc79f7336
