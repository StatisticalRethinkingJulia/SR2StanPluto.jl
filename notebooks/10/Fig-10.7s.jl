### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 4fb1c47c-8d70-11eb-3d5c-01c5bb7190fe
using Pkg, DrWatson

# ╔═╡ 5838d806-8d70-11eb-2a78-fb586f056012
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
end

# ╔═╡ 3562c0e2-8d70-11eb-0f89-9d039fe996b9
md" ## Clip-11-01-05s.jl"

# ╔═╡ 07c85e9e-8d95-11eb-295d-63a99f7aa921
md" ##### Fig 10.7."

# ╔═╡ 9bfd33fc-8d70-11eb-3a9c-bb9a990cbcf9
x = collect(-1.0:0.01:1.0);

# ╔═╡ ee25cbe6-8d8c-11eb-3323-c521a67b10f0
begin
	α = 0.0
	β = 2.0
	
	# p = exp.(α .+ β .* x) ./ (1 .+ exp.(α .+ β .* x))
	
	p = logistic.(α .+ β .* x)
end

# ╔═╡ 1cba8970-8d91-11eb-01d8-09d8d076dc73
begin
	odds = p ./ (1 .- p)
	logodds = log.(odds)
end

# ╔═╡ 6b96d95e-8d91-11eb-25ac-75f21ee9c98e
logistic.(x)

# ╔═╡ 15dcde1e-8d8c-11eb-0964-d9c5f616e59c
begin
	fig1 = plot(x, logodds, leg=false)
	fig2 = plot(x, p, ylims=(0,1), leg=false)
	plot(fig1, fig2, layout=(1, 2))
end

# ╔═╡ 1404a820-8d95-11eb-27d2-531cea578fda
md" ##### Fig 10.8."

# ╔═╡ c859986c-8d93-11eb-1211-db9c435de034
logsig = exp.(α .+ β .* x)

# ╔═╡ f3bac6a4-8d93-11eb-2614-1572443e3415
begin
	fig3 = plot(x, log.(logsig), leg=false)
	fig4 = plot(x, logsig, ylims=(0,10), leg=false)
	plot(fig3, fig4, layout=(1, 2))
end

# ╔═╡ 7e069492-8d70-11eb-2093-8375b07f4099
md" ## End of clip-11-01-05s.jl"

# ╔═╡ Cell order:
# ╠═3562c0e2-8d70-11eb-0f89-9d039fe996b9
# ╠═4fb1c47c-8d70-11eb-3d5c-01c5bb7190fe
# ╠═5838d806-8d70-11eb-2a78-fb586f056012
# ╟─07c85e9e-8d95-11eb-295d-63a99f7aa921
# ╠═9bfd33fc-8d70-11eb-3a9c-bb9a990cbcf9
# ╠═ee25cbe6-8d8c-11eb-3323-c521a67b10f0
# ╠═1cba8970-8d91-11eb-01d8-09d8d076dc73
# ╠═6b96d95e-8d91-11eb-25ac-75f21ee9c98e
# ╠═15dcde1e-8d8c-11eb-0964-d9c5f616e59c
# ╟─1404a820-8d95-11eb-27d2-531cea578fda
# ╠═c859986c-8d93-11eb-1211-db9c435de034
# ╠═f3bac6a4-8d93-11eb-2614-1572443e3415
# ╟─7e069492-8d70-11eb-2093-8375b07f4099
