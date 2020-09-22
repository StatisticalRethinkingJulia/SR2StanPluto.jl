### A Pluto.jl notebook ###
# v0.11.14

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

# ╔═╡ c43be296-fced-11ea-05e5-ed58eaff96ec
include(projectdir("models", "05", "m5.3s.jl"))

# ╔═╡ 1e3eaf90-fced-11ea-12c7-9f994f24a65d
md"## Clip-05-10-11s.jl"

# ╔═╡ c4470928-fced-11ea-14d1-df38dd138e54
if success(rc)
	begin
		dfs = read_samples(m5_3s; output_format=:dataframe)

		# Rethinking results

		rethinking_results = "
			   mean   sd  5.5% 94.5%
		a      0.00 0.10 -0.16  0.16
		bM    -0.07 0.15 -0.31  0.18
		bA    -0.61 0.15 -0.85 -0.37
		sigma  0.79 0.08  0.66  0.91
		";

		title = "Divorce rate vs. Marriage rate" * "\nshowing predicted and hpd range"
		plotbounds(
			df, :Marriage, :Divorce,
			dfs, [:a, :bM, :sigma];
			title=title,
			colors=[:lightgrey, :darkgrey],
			bounds=[:predicted, :hpdi]
		)
	end
end

# ╔═╡ c447c624-fced-11ea-23e3-297d5e57104e
md"## End of clip-05-10-12.jl"

# ╔═╡ Cell order:
# ╠═1e3eaf90-fced-11ea-12c7-9f994f24a65d
# ╠═c436330a-fced-11ea-132d-85f5197a22b8
# ╠═c43683be-fced-11ea-0575-f78e4551118a
# ╠═c43be296-fced-11ea-05e5-ed58eaff96ec
# ╠═c4470928-fced-11ea-14d1-df38dd138e54
# ╟─c447c624-fced-11ea-23e3-297d5e57104e
