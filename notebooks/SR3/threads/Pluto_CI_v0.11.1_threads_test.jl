### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 859783d0-73c9-4d1a-aab7-1d1bc474389e
using Pkg

# ╔═╡ c80881ad-605b-40fc-a492-d253fef966c8
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
	using DataFrames
	using NamedTupleTools
	using CausalInference
end

# ╔═╡ be65de6f-35f5-43e9-8004-30dd3f189456
let
	N = 2000 # number of data points

	# define simple linear model with added noise

	x = randn(N)
	v = x + randn(N)*0.25
	w = x + randn(N)*0.25
	z = v + w + randn(N)*0.25
	s = z + randn(N)*0.25
	global df = DataFrame(X=x, V=v, W=w, Z=z, S=s)
end

# ╔═╡ 8423ced6-a8d9-4643-833d-164dd547e7ec
let
	vars = Symbol.(names(df))
	nt = namedtuple(vars, [df[!, k] for k in vars])
	@time g = pcalg(nt, 0.25, gausscitest)
end

# ╔═╡ 23a7409a-80da-471a-8032-7b6f0abb7766
@time est_g, score = ges(df; penalty=1.0, parallel=true)

# ╔═╡ f2a1d903-0578-4caf-b1df-e670c7514744
est_g.fadjlist

# ╔═╡ 9171c355-096a-4cc2-b4d8-d7c6d37256da
@time g = pcalg(df, 0.25, gausscitest)

# ╔═╡ be499ec2-cc0d-4b3f-af78-4cc617d52b97
g.fadjlist

# ╔═╡ Cell order:
# ╠═859783d0-73c9-4d1a-aab7-1d1bc474389e
# ╠═c80881ad-605b-40fc-a492-d253fef966c8
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╠═be65de6f-35f5-43e9-8004-30dd3f189456
# ╠═8423ced6-a8d9-4643-833d-164dd547e7ec
# ╠═23a7409a-80da-471a-8032-7b6f0abb7766
# ╠═f2a1d903-0578-4caf-b1df-e670c7514744
# ╠═be499ec2-cc0d-4b3f-af78-4cc617d52b97
# ╠═9171c355-096a-4cc2-b4d8-d7c6d37256da
