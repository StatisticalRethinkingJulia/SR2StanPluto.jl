### A Pluto.jl notebook ###
# v0.11.6

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ cd2366c0-e0c5-11ea-287a-abc0804397c8
using Pkg, DrWatson

# ╔═╡ 9fb491f0-df47-11ea-3cf9-6fa3cee85c33
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
	using StanSample
	using StatsPlots
	using PlutoUI
end

# ╔═╡ cb3b80f4-df47-11ea-18e1-dd4b1f2b5cde
md"### Fig 2.5"

# ╔═╡ f65a77d8-df47-11ea-271a-41999fd773fb
md"##### This clip is only intended to generate Fig 2.5. It is not intended to show how to use Stan (yet)!"

# ╔═╡ 0b3fbb40-df48-11ea-08f2-479bc2292d46
m2_0s = "
// Inferring a rate
data {
  int n;
  int k;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

# ╔═╡ 147b737a-df48-11ea-3679-77200acb11f0
md"#### 1. Create a Stanmodel object:"

# ╔═╡ 2331e85c-df48-11ea-1551-b54d9e48188c
m2_0 = SampleModel("m2.0s", m2_0s; tmpdir=projectdir("tmp"));

# ╔═╡ 2f43c3b0-df48-11ea-2d13-99adeddbe90a
md"#### n can go from 1:9"

# ╔═╡ 150bbb7c-e0d0-11ea-3ba0-57135fa7c974
@bind n Slider(1:18, default=9)

# ╔═╡ 48d028ea-dfcb-11ea-018b-25399925cdef
begin
	k = [1,0,1,1,1,0,1,0,1,1,0,1,1,1,0,1,0,1][1:n]
  	m2_0_data = Dict("n" => n, "k" => sum(k[1:n]));
end

# ╔═╡ 9c95af86-dfcb-11ea-1eed-4bc7b6f75b3f
  rc = stan_sample(m2_0, data=m2_0_data);

# ╔═╡ a0e6624c-dfcb-11ea-1b63-1b1f27c9f6e8
if success(rc)
	dfs = read_samples(m2_0; output_format=:dataframe);
end;

# ╔═╡ 991b1400-df48-11ea-02a7-e9bdf39427ff
begin
  plot(xlims=(0.0, 1.0), ylims=(0.0, 4.0), leg=false)
  hline!([1.0], line=(:dash))
  density!(dfs.theta, line=(:dash))
 end

# ╔═╡ 13851f4a-dfc8-11ea-0933-cb4f026bcf42
md"### End of clip-00.1.jl"

# ╔═╡ Cell order:
# ╠═cb3b80f4-df47-11ea-18e1-dd4b1f2b5cde
# ╠═cd2366c0-e0c5-11ea-287a-abc0804397c8
# ╠═9fb491f0-df47-11ea-3cf9-6fa3cee85c33
# ╟─f65a77d8-df47-11ea-271a-41999fd773fb
# ╠═0b3fbb40-df48-11ea-08f2-479bc2292d46
# ╠═147b737a-df48-11ea-3679-77200acb11f0
# ╠═2331e85c-df48-11ea-1551-b54d9e48188c
# ╠═2f43c3b0-df48-11ea-2d13-99adeddbe90a
# ╠═150bbb7c-e0d0-11ea-3ba0-57135fa7c974
# ╠═48d028ea-dfcb-11ea-018b-25399925cdef
# ╠═9c95af86-dfcb-11ea-1eed-4bc7b6f75b3f
# ╠═a0e6624c-dfcb-11ea-1b63-1b1f27c9f6e8
# ╠═991b1400-df48-11ea-02a7-e9bdf39427ff
# ╟─13851f4a-dfc8-11ea-0933-cb4f026bcf42
