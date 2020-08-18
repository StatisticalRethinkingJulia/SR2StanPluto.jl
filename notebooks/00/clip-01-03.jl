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

# ╔═╡ e8a5afbe-dc1e-11ea-023e-31002d1c7688
using Pkg, DrWatson

# ╔═╡ f476d956-dc1e-11ea-002f-79f79dfc79e2
begin
	@quickactivate "StatisticalRethinkingStan"
	using PlutoUI
end

# ╔═╡ bfa90d82-dc1e-11ea-0fe9-83abb69fd819
md"### clip-01-03.jl"

# ╔═╡ 1b540d64-dc1f-11ea-321a-f1e0d2bab3e8
md"#### snippet 0.1"

# ╔═╡ 624b8daa-dc1f-11ea-114f-19896cd76aa5
"All models are wrong, but some are useful."

# ╔═╡ 8fa79b3e-dc1f-11ea-1437-d7bfe6cdea51
md"#### snippet 0.2"

# ╔═╡ c4321a66-de4f-11ea-3449-774edd51eb10
@bind N Slider(1:5, default=3)

# ╔═╡ df73cd1c-dc1f-11ea-0e14-c7e381f49c4a
begin
	x = 1:N
	x = x*10
	x = log.(x)
	x = sum(x)
	x = exp(x)
	x = x*10
	x = log(x)
	x = sum(x)
	x = exp(x)
end

# ╔═╡ 35330a6a-dc20-11ea-2929-9b904165e207
md"##### Notes on snippet 0.2:

Variable x initially is a StepRange, not a vector. The log.(x) notation `broadcast` the log function to all steprange elements in x and returms a vector!"

# ╔═╡ b1d6b4ac-dc20-11ea-3237-a515964f9176
md"#### snippet 0.3"

# ╔═╡ 88e3bb64-dc1e-11ea-1136-bd822afb72e4
[log(0.01^200) 200 * log(0.01)]

# ╔═╡ c4403280-dc20-11ea-0550-5f2f606a9fea
md"#### End of `clip-01-03.jl`"

# ╔═╡ Cell order:
# ╟─bfa90d82-dc1e-11ea-0fe9-83abb69fd819
# ╠═e8a5afbe-dc1e-11ea-023e-31002d1c7688
# ╠═f476d956-dc1e-11ea-002f-79f79dfc79e2
# ╟─1b540d64-dc1f-11ea-321a-f1e0d2bab3e8
# ╠═624b8daa-dc1f-11ea-114f-19896cd76aa5
# ╟─8fa79b3e-dc1f-11ea-1437-d7bfe6cdea51
# ╠═c4321a66-de4f-11ea-3449-774edd51eb10
# ╠═df73cd1c-dc1f-11ea-0e14-c7e381f49c4a
# ╠═35330a6a-dc20-11ea-2929-9b904165e207
# ╟─b1d6b4ac-dc20-11ea-3237-a515964f9176
# ╠═88e3bb64-dc1e-11ea-1136-bd822afb72e4
# ╟─c4403280-dc20-11ea-0550-5f2f606a9fea
