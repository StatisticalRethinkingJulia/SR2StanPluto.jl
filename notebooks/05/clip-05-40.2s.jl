### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 13c9b84e-fdb9-11ea-2e2f-bd38a244317f
using Pkg, DrWatson

# ╔═╡ 13ca0af6-fdb9-11ea-2956-45f2849a856c
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 13d69b68-fdb9-11ea-3eaf-612320346d53
for i in 5:7
  include(projectdir("models", "05", "m5.$(i)s.jl"))
end

# ╔═╡ e2ddee76-fdb8-11ea-1f1a-09de92c87dd3
md"## Clip-05-40.2s.jl"

# ╔═╡ 13ca9958-fdb9-11ea-000f-2d2d5d211e5b
md"### snippet 5.39"

# ╔═╡ 13d72238-fdb9-11ea-364d-8db015412817
if success(rc)

  dfa5 = read_samples(m5_5s; output_format=:dataframe)
  title5 = "Kcal_per_g vs. neocortex_perc" * "\n89% predicted and mean range"
  p1 = plotbounds(
    df, :neocortex_perc, :kcal_per_g,
    dfa5, [:a, :bN, :sigma];
    title=title5,
    rescale_axis=false
  )

  dfa6 = read_samples(m5_6s; output_format=:dataframe)
  title6 = "Kcal_per_g vs. log mass" * "\nshowing 89% predicted and mean range"
  p2 = plotbounds(
    df, :lmass, :kcal_per_g,
    dfa6, [:a, :bM, :sigma];
    title=title6,
    rescale_axis=false
  )

  dfa7 = read_samples(m5_7s; output_format=:dataframe)
  title7 = "Counterfactual,\nholding M=0.0"
  p3 = plotbounds(
    df, :neocortex_perc, :kcal_per_g,
    dfa7, [:a, :bN, :sigma];
    title=title7,
    rescale_axis=false
  )

  title8 = "Counterfactual,\nholding N=0.0"
  p4 = plotbounds(
    df, :lmass, :kcal_per_g,
    dfa7, [:a, :bM, :sigma];
    title=title8,
    xlab="log(mass)",
    rescale_axis=false
  )

end;

# ╔═╡ 13e216fa-fdb9-11ea-38d0-83247639f99e
plot(p1, p2, p3, p4, layout=(2, 2))

# ╔═╡ 13e2a9aa-fdb9-11ea-2bce-5515b878fbed
md"## End of clip-05-40.2s.jl"

# ╔═╡ Cell order:
# ╟─e2ddee76-fdb8-11ea-1f1a-09de92c87dd3
# ╠═13c9b84e-fdb9-11ea-2e2f-bd38a244317f
# ╠═13ca0af6-fdb9-11ea-2956-45f2849a856c
# ╟─13ca9958-fdb9-11ea-000f-2d2d5d211e5b
# ╠═13d69b68-fdb9-11ea-3eaf-612320346d53
# ╠═13d72238-fdb9-11ea-364d-8db015412817
# ╠═13e216fa-fdb9-11ea-38d0-83247639f99e
# ╟─13e2a9aa-fdb9-11ea-2bce-5515b878fbed
