### A Pluto.jl notebook ###
# v0.15.1

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

# ╔═╡ 78e82534-3101-11eb-2eda-43b2de63543b
using Pkg, DrWatson

# ╔═╡ 7fcdc6c2-3101-11eb-306d-b32a138fa475
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
	using PlutoUI
end

# ╔═╡ 69c4c56a-3101-11eb-0c7c-8372134bc6a3
md"## Intro-pluto-10.jl"

# ╔═╡ ad970090-3102-11eb-2aa8-6122b50d6069
@bind x Slider(1:20, default=3)

# ╔═╡ 964f8476-3101-11eb-168e-438a10661092
s1 = s2 = [sqrt(i) for i in 1:x]

# ╔═╡ 0aaeaef0-318e-11eb-289b-978a9a86418b
md"<details><summary>CLICK ME</summary>
<p>

#### yes, even hidden code blocks!

```julia
Text('hello world!')
```

</p>
</details>"

# ╔═╡ 48625f5c-3103-11eb-3d51-4b70ff04ba9b
md"## End of intro-pluto-10.jl"

# ╔═╡ Cell order:
# ╟─69c4c56a-3101-11eb-0c7c-8372134bc6a3
# ╠═78e82534-3101-11eb-2eda-43b2de63543b
# ╠═7fcdc6c2-3101-11eb-306d-b32a138fa475
# ╠═ad970090-3102-11eb-2aa8-6122b50d6069
# ╠═964f8476-3101-11eb-168e-438a10661092
# ╠═0aaeaef0-318e-11eb-289b-978a9a86418b
# ╟─48625f5c-3103-11eb-3d51-4b70ff04ba9b
