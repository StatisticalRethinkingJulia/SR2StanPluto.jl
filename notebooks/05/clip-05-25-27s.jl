### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 98601dc8-fd46-11ea-2560-e762bfd97ed7
using Pkg, DrWatson

# ╔═╡ 986050d6-fd46-11ea-26b6-7f618638f1ab
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 986d9d7c-fd46-11ea-305a-915f690d446a
include(projectdir("models", "05", "m5.3.As.jl"))

# ╔═╡ f7be0558-fd45-11ea-2cb4-c9f411d2e55e
md"## Clip-05-25-27s.jl"

# ╔═╡ 9877c52c-fd46-11ea-293f-3d07c0cd6734
md"##### Rethinking results"

# ╔═╡ 98785a28-fd46-11ea-34e0-d3e047cb1b0c
rethinking_results = "
           mean   sd  5.5% 94.5%
  a        0.00 0.10 -0.16  0.16
  bM      -0.07 0.15 -0.31  0.18
  bA      -0.61 0.15 -0.85 -0.37
  sigma    0.79 0.08  0.66  0.91
  aM       0.00 0.09 -0.14  0.14
  bAM     -0.69 0.10 -0.85 -0.54
  sigma_M  0.68 0.07  0.57  0.79
";

# ╔═╡ b9af5a04-fd49-11ea-07ba-fb61574aed90
part5_3_As = read_samples(m5_3_As; output_format=:particles)

# ╔═╡ 988ca05a-fd46-11ea-2ae3-910f7baa2b3f
md"## Snippet 5.25"

# ╔═╡ c79668d4-fd48-11ea-0cea-838eb6be744c
a_seq = range(-2, stop=2, length=100)

# ╔═╡ 988d33a8-fd46-11ea-27e5-7ba54e7b04fa
md"## Snippet 5.26"

# ╔═╡ e46cd1dc-fd48-11ea-0802-4d13a4981a23
begin
	post5_3_As_df = read_samples(m5_3_As; output_format=:dataframe)
	m_sim = zeros(size(post5_3_As_df, 1), length(a_seq))
end;

# ╔═╡ 9899e134-fd46-11ea-0499-b94859cad8d1
for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.aM[j] + part5_3_As.bAM[j]*a_seq[i], part5_3_As.sigma_M[j])
    m_sim[j, i] = rand(d, 1)[1]
  end
end

# ╔═╡ 98a1fc3e-fd46-11ea-12f3-81a21baa6353
md"## Snippet 5.27"

# ╔═╡ eee2e318-fd48-11ea-2433-e1f6e65a082a
d_sim = zeros(size(post5_3_As_df, 1), length(a_seq));

# ╔═╡ 98a9de04-fd46-11ea-1a1b-b7512b456dc6
for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.a[j] + part5_3_As.bA[j]*a_seq[i] + part5_3_As.bM[j]*m_sim[j, i], part5_3_As.sigma[j])
    d_sim[j, i] = rand(d, 1)[1]
  end
end

# ╔═╡ 98ac248e-fd46-11ea-37ca-fbce7e1a8203
begin
	plot(xlab="Manipulated A", ylab="Counterfactual D",
		title="Total counterfactual effect of A on D")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

# ╔═╡ 98d0d7e8-fd46-11ea-02d8-191f0f81da25
md"## End of clip-05-25-27s.jl"

# ╔═╡ Cell order:
# ╟─f7be0558-fd45-11ea-2cb4-c9f411d2e55e
# ╠═98601dc8-fd46-11ea-2560-e762bfd97ed7
# ╠═986050d6-fd46-11ea-26b6-7f618638f1ab
# ╠═986d9d7c-fd46-11ea-305a-915f690d446a
# ╟─9877c52c-fd46-11ea-293f-3d07c0cd6734
# ╠═98785a28-fd46-11ea-34e0-d3e047cb1b0c
# ╠═b9af5a04-fd49-11ea-07ba-fb61574aed90
# ╟─988ca05a-fd46-11ea-2ae3-910f7baa2b3f
# ╠═c79668d4-fd48-11ea-0cea-838eb6be744c
# ╠═988d33a8-fd46-11ea-27e5-7ba54e7b04fa
# ╠═e46cd1dc-fd48-11ea-0802-4d13a4981a23
# ╠═9899e134-fd46-11ea-0499-b94859cad8d1
# ╟─98a1fc3e-fd46-11ea-12f3-81a21baa6353
# ╠═eee2e318-fd48-11ea-2433-e1f6e65a082a
# ╠═98a9de04-fd46-11ea-1a1b-b7512b456dc6
# ╠═98ac248e-fd46-11ea-37ca-fbce7e1a8203
# ╟─98d0d7e8-fd46-11ea-02d8-191f0f81da25
