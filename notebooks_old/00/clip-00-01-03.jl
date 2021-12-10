### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 9941173e-f2dc-11ea-0f91-4ff7401d7d2c
using Pkg, DrWatson

# ╔═╡ 0b2c7f06-f2dc-11ea-0434-cdc3e04decae
md"## 00-Preface.jl"

# ╔═╡ 9948d1f4-f2dc-11ea-225d-992c7e2f825f
md"### snippet 0.1"

# ╔═╡ 99496f10-f2dc-11ea-21f9-7fd3bcbdf477
"All models are wrong, but some are useful."

# ╔═╡ 9956c73c-f2dc-11ea-1620-13786d3d33e4
md"### snippet 0.2"

# ╔═╡ 9957701a-f2dc-11ea-18d6-55adda75b7d4
md"##### This is a StepRange, not a vector."

# ╔═╡ 9960bc1a-f2dc-11ea-3a7b-4181c9fa8fe8
x1 = 1:3

# ╔═╡ 996156d4-f2dc-11ea-10e4-4fc246187dd3
md"##### Below still preserves the StepRange."

# ╔═╡ 996b40ea-f2dc-11ea-3814-15033114a487
x2 = x1*10

# ╔═╡ e04af122-f2dc-11ea-2a23-33f8632dbed9
typeof(x2)

# ╔═╡ fbc13db2-f2dc-11ea-1368-9387b64be726
x2[end]

# ╔═╡ 996be34c-f2dc-11ea-2f8f-c389bca0896e
md"##### `Broadcast` log to steprange elements in x2, this returms a vector! Notice the log.(x2) notation."

# ╔═╡ 99780bae-f2dc-11ea-0af3-6157b75c5288
x3 = log.(x2)

# ╔═╡ ed4ea62a-f2dc-11ea-3bed-0ff984265c52
typeof(x3)

# ╔═╡ 9979b86e-f2dc-11ea-3cb9-291cec8627a2
md"##### We can sum the vector x3."

# ╔═╡ 9988b358-f2dc-11ea-1f2d-139af6ac6699
x4 = sum(x3)

# ╔═╡ 998df810-f2dc-11ea-0415-a33278120eac
# Etc.

begin
	x = exp(x4)
	x = x*10
	x = log(x)
	x = sum(x)
	x = exp(x)
end

# ╔═╡ 9991cfc6-f2dc-11ea-0322-f908d09388e7
md"### snippet 0.3"

# ╔═╡ 999f513c-f2dc-11ea-3917-2390217ae1ad
[log(0.01^200) 200 * log(0.01)]

# ╔═╡ 99a096fa-f2dc-11ea-2c15-bd83f1acacf9
md"## End of clip-00-01-03s.jl"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[compat]
DrWatson = "~2.5.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DrWatson]]
deps = ["Dates", "FileIO", "LibGit2", "MacroTools", "Pkg", "Random", "Requires", "UnPack"]
git-tree-sha1 = "d6aa02ad618cf31af9bbbf87f87baad632538211"
uuid = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
version = "2.5.0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═0b2c7f06-f2dc-11ea-0434-cdc3e04decae
# ╠═9941173e-f2dc-11ea-0f91-4ff7401d7d2c
# ╟─9948d1f4-f2dc-11ea-225d-992c7e2f825f
# ╟─99496f10-f2dc-11ea-21f9-7fd3bcbdf477
# ╟─9956c73c-f2dc-11ea-1620-13786d3d33e4
# ╟─9957701a-f2dc-11ea-18d6-55adda75b7d4
# ╠═9960bc1a-f2dc-11ea-3a7b-4181c9fa8fe8
# ╟─996156d4-f2dc-11ea-10e4-4fc246187dd3
# ╠═996b40ea-f2dc-11ea-3814-15033114a487
# ╠═e04af122-f2dc-11ea-2a23-33f8632dbed9
# ╠═fbc13db2-f2dc-11ea-1368-9387b64be726
# ╟─996be34c-f2dc-11ea-2f8f-c389bca0896e
# ╠═99780bae-f2dc-11ea-0af3-6157b75c5288
# ╠═ed4ea62a-f2dc-11ea-3bed-0ff984265c52
# ╟─9979b86e-f2dc-11ea-3cb9-291cec8627a2
# ╠═9988b358-f2dc-11ea-1f2d-139af6ac6699
# ╠═998df810-f2dc-11ea-0415-a33278120eac
# ╟─9991cfc6-f2dc-11ea-0322-f908d09388e7
# ╠═999f513c-f2dc-11ea-3917-2390217ae1ad
# ╟─99a096fa-f2dc-11ea-2c15-bd83f1acacf9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
