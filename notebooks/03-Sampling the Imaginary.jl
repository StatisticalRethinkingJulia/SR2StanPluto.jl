### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ cb745deb-2d58-4a73-a954-7fc885654e15
using Pkg

# ╔═╡ 10249d26-e2b5-4ce5-a87d-4a703e9f3b45
begin
	# General packages
    using Distributions
    using StatsBase
    using KernelDensity

	# Graphics related
	using GLMakie

	# Basic packages
	using RegressionAndOtherStories
	using StatisticalRethinking: sr_datadir, hpdi
end

# ╔═╡ d9d421ed-b182-4def-a608-bf0005eee3d7
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 2000px;
        padding-left: max(160px, 0%);
        padding-right: max(160px, 30%);
    }
</style>
"""

# ╔═╡ 3080b453-0a4f-45ef-8e3d-731c44e14b6d
md"### Julia code snippet 3.1"

# ╔═╡ 7148ccef-6649-4208-8107-bc886315c42f
begin
    Pr_Positive_Vampire = 0.95
    Pr_Positive_Mortal = 0.01
    Pr_Vampire = 0.001
    tmp = Pr_Positive_Vampire * Pr_Vampire
    Pr_Positive = tmp + Pr_Positive_Mortal * (1 - Pr_Vampire)
    Pr_Vampire_Positive = tmp / Pr_Positive
end

# ╔═╡ 542059d8-0152-4add-8c1f-81c76ebef04c
md"### Julia code snippet 3.2"

# ╔═╡ 524b026e-a281-46ff-8438-bd6968571335
begin
    size = 1000
    p_grid = range(0, 1; length=size)
    prob_p = repeat([1.0], size);
    prob_data = [pdf(Binomial(9, p), 6) for p in p_grid];
    posterior = prob_data .* prob_p
    posterior /= sum(posterior);
end

# ╔═╡ 0b948b52-144d-437c-b69d-cff99c901210
md"### Julia code snippet 3.3"

# ╔═╡ b6c1ea47-c1a3-4b6a-bc72-d97ea64d81c6
samples1 = sample(p_grid, Weights(posterior), 10000; replace=true)

# ╔═╡ 6b5c3871-61e0-44a0-b852-9b2d0820aad2
sum(Weights(posterior))

# ╔═╡ 8169ab77-793d-4e0f-9981-ef0e2ba36508
md"### Julia code snippet 3.4,  code snippet 3.5 and Figure 3.1"

# ╔═╡ e78b6f64-61b0-4790-a4a7-e40c5546fd5d
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; xlabel="Sample number", ylabel="Proportion water (p)")
	scatter!(samples1; alpha=0.2, markersize=4)
	ax = Axis(f[1, 2]; xlabel="Proportion water (p)", ylabel="Density")
	density!(samples1; color=(:lightblue, 0.3), strokedolor=:blue, strokewidth = 3, strokearound = true)
	f
end

# ╔═╡ acbe73d9-75f3-4099-afaa-d1483c6c2323
md"### Julia code snippet 3.6"

# ╔═╡ 970adc98-dbeb-4454-b6cc-a0fdfa4dc50d
sum(posterior[p_grid .< 0.5])

# ╔═╡ 61c51874-f9db-4434-81cb-206be02adb48
md"### Julia code snippet 3.7"

# ╔═╡ d2702ea5-bdad-4daf-8f34-e0a2f0bd9963
sum(samples1 .< 0.5) / length(samples1)

# ╔═╡ 47060a12-d34e-404e-956f-b7c6a262c3d7
let
	f = Figure(resolution=default_figure_resolution)
	x = 0:0.01:1
	d = Normal(mean(samples1), std(samples1))
	
	ax = Axis(f[1, 1]; xlabel="Proportion water (p)", ylabel="Density")
	lines!(x, pdf.(d, x))
	x1 = range(0, 0.5; length=100)
	band!(x1, fill(0, length(x1)), pdf.(d, x1); color = (:darkblue, 0.5), label = "Label")

	ax = Axis(f[1, 2]; xlabel="Sample number", ylabel="Proportion water (p)")
	lines!(x, pdf.(d, x))
	x1 = range(0.5, 0.75; length=100)
	band!(x1, fill(0, length(x1)), pdf.(d, x1); color = (:darkblue, 0.5), label = "Label")
	
	ax = Axis(f[2, 1]; xlabel="Sample number", ylabel="Proportion water (p)")
	lines!(x, pdf.(d, x))
	x1 = range(0, 0.75; length=100)
	band!(x1, fill(0, length(x1)), pdf.(d, x1); color = (:darkblue, 0.5), label = "Label")
	
	ax = Axis(f[2, 2]; xlabel="Sample number", ylabel="Proportion water (p)")
	lines!(x, pdf.(d, x))
	x1 = range(0.45, 0.81; length=100)
	band!(x1, fill(0, length(x1)), pdf.(d, x1); color = (:darkblue, 0.5), label = "Label")
	f
end

# ╔═╡ aaed0560-4c07-49a6-a8a9-80d68d8ebf10
md"### Julia code snippet 3.8"

# ╔═╡ 4adccbf1-7d07-4d0f-b5bc-ba77bf591814
sum(@. (samples1 > 0.5) & (samples1 < 0.75)) / length(samples1)

# ╔═╡ 5e91f0ee-b23e-4ac5-b4cb-c80d1d3a13ba
md"### Julia code snippet 3.9"

# ╔═╡ 79a5219e-7a13-473f-b6ca-0f9e3a2c9101
quantile(samples1, 0.8)

# ╔═╡ e31e8117-f297-4fde-8289-cf6bfeb29b3e
md"### Julia code snippet 3.10"

# ╔═╡ a6b662ef-cb3f-4caa-99dc-0bd478d04f5a
quantile(samples1, [0.1, 0.9])

# ╔═╡ e7327115-d417-4dad-879d-22bcd27de807
md"### Julia code snippet 3.11"

# ╔═╡ 3cce986c-0fbd-4da0-9c2d-2544e684f584
let
    size = 1000
    global p_grid2 = range(0, 1; length=size)
    prior = ones(size)
    likelihood = [pdf(Binomial(3, p), 3) for p in p_grid2];
    global posterior2 = likelihood .* prior
    posterior2 /= sum(posterior2)
	global samples2 = sample(p_grid2, Weights(posterior2), 1000000; replace=true)
	hpdi(samples2)
end

# ╔═╡ c3254e98-ac09-46d2-afd1-8968bef00248
md"### Julia code snippet 3.12"

# ╔═╡ 0dc02541-a73e-4913-b740-80ba755ea71c
percentage_interval = percentile(samples2, [25, 75])

# ╔═╡ 656171b1-d1a4-4e2e-84bf-34efb7f03b4f
md"### Julia code snippet 3.13"

# ╔═╡ 1e1eed13-4472-48ef-858b-df4c04ae6269
highest_posterior_interval = hpdi(samples2, alpha=0.5)

# ╔═╡ b35c9437-d664-4af8-872f-08aa9f48958b
let
	f = Figure(resolution=default_figure_resolution)
	
	pi = percentage_interval
	hpi = highest_posterior_interval
	k = kde(samples2, bandwidth=0.01)
	
	ax = Axis(f[1, 1]; xlabel="Proportion water (p)", ylabel="Density", title="50% percentile interval")
	ylims!(0, 4)
	xlims!(0, 1)
	for i in 1:length(k.x)
		if k.x[i] > pi[1] && k.x[i] < pi[2]
			vlines!(k.x[i]; color=:lightblue, ymax=k.density[i]/4)
		end
	end
	lines!(k.x, k.density; color=:darkblue, linewidth=3)
	
	ax = Axis(f[1, 2]; xlabel="Proportion water (p)", ylabel="Density", title="50% HPDI")
	ylims!(0, 4)
	xlims!(0, 1)
	for i in 1:length(k.x)
		if k.x[i] > hpi[1] && k.x[i] < hpi[2]
			vlines!(k.x[i]; color=:lightblue, ymax=k.density[i]/4)
		end
	end
	lines!(k.x, k.density; color=:darkblue, linewidth=3)

	f
end

# ╔═╡ 93649bd6-03c2-4c20-9985-4bf82bbbdf28
md"### Julia code snippet 3.14"

# ╔═╡ d4242e1c-6033-4d05-9567-261d4251f726
p_grid2[argmax(posterior2)]

# ╔═╡ 8410768e-c81e-4e5e-91f7-789d5a85d434
md"### Julia code snippet 3.15"

# ╔═╡ 30ad6d2c-cf5a-4c86-801e-af791439960b
let
	k = kde(samples2, bandwidth=0.01)
	k.x[argmax(k.density)]
end

# ╔═╡ 0419f3b1-a49a-4234-b23c-393457c04c23
md"### Julia code snippet 3.16"

# ╔═╡ 44f1f5b2-b09a-474b-8147-fb7012a7651d
mean(samples2), median(samples2)

# ╔═╡ 50824b2b-ab77-4255-9e24-7a0881193b81
md"### Julia code snippet 3.17"

# ╔═╡ 8865e1e3-53ab-4c06-bf6f-09c7048ddd5d
sum(@. posterior2 * abs(0.5 - p_grid2))

# ╔═╡ eb3d25d8-a963-4ed9-a8dc-2f6a397b1600
md"### Julia code snippet 3.18"

# ╔═╡ c3c8171c-facd-4b71-8dab-0aa4b30cc59d
loss = map(d -> sum(@. posterior2 * abs(d - p_grid2)), p_grid2);

# ╔═╡ 570f015f-bbe7-404d-a5ab-5ac570ef8c99
md"### Julia code snippet 3.19"

# ╔═╡ ff1cdbdc-81df-4404-a8dc-ec0af633d090
findmin(loss)

# ╔═╡ f3eb02e9-31ce-4813-bf0b-43bd31b0948a
p_grid2[argmin(loss)]

# ╔═╡ 2609d3b7-63bf-453b-a1d2-69195c3f2148
md" #### Figure 3.2"

# ╔═╡ 0c733bb4-ce48-477b-ac7d-23d2fb2aa7e3
let
	f = Figure(resolution=default_figure_resolution)

	k = kde(samples2, bandwidth=0.01)

	ax = Axis(f[1, 1]; xlabel="Proportion water (p)", ylabel="Density", title="50% percentile interval")
	ylims!(0.0, 4)
	xlims!(0, 1)
	vlines!(mean(samples2))
	vlines!(median(samples2))
	x = 0:0.01:1
	lines!(k.x, k.density; linewidth=4)
	annotations!("mean"; position=(0.788, 0.5), rotation = pi/2)
	annotations!("median"; position=(0.88, 0.5), rotation = pi/2)
	
	ax = Axis(f[1, 2]; title="Loss function")
	lines!(p_grid2, loss; linewidth=4)
	vlines!(mean(samples2))
	vlines!(median(samples2))
	annotations!("mean"; position=(0.788, 0.5), rotation = pi/2)
	annotations!("median"; position=(0.88, 0.5), rotation = pi/2)
	f
end

# ╔═╡ bc989c65-1e44-4a56-8954-4c48d887349d
md"### Julia code snippet 3.20"

# ╔═╡ 275ccd69-e7d5-4a73-8609-c722dec555fa
[pdf(Binomial(2, 0.7), n) for n ∈ 0:2]

# ╔═╡ 950611f8-d8c0-41f3-9668-2fb7e8e8cbe0
md"### Julia code snippet 3.21"

# ╔═╡ dfbf8ad3-bbd8-43ac-bd39-9d4117c60e76
rand(Binomial(2, 0.7), 10)

# ╔═╡ eec4cbcd-69a4-49f1-9b1e-ffc6f110c7cb
md"### Julia code snippet 3.22"

# ╔═╡ 763c4569-d0df-4129-b9c9-f6aaa2b8d7a6
s = rand(Binomial(2, 0.7), 10)

# ╔═╡ 61b2214c-7459-47e9-a890-5235380d000c
md"### Julia code snippet 3.23"

# ╔═╡ 0662dfb6-82ff-4e38-aacd-ed8ec9894393
let
    dummy_w = rand(Binomial(2, 0.7), 100_000);
    proportions(dummy_w)  # or counts(dummy_w)/100000
end

# ╔═╡ 1f11ffc4-d64d-4a42-b313-06a1373e789f
md"### Julia code snippet 3.24"

# ╔═╡ b2fa1670-f8ad-4d4d-aa6b-d8e0983e4a17
let
    dummy_w = rand(Binomial(9, 0.7), 100_000);
	f = Figure()
	ax = Axis(f[1, 1]; xlabel="dummy water count", ylabel="Frequency")
    hist!(dummy_w)
	f
end

# ╔═╡ 1c350e5b-4d35-4358-b49b-b435c2103936
md"### Julia code snippet 3.25"

# ╔═╡ 5d5b2bbf-b27c-4679-9520-b318cdce0487
let
	w = rand(Binomial(9, 0.6), 10_000);
end

# ╔═╡ 046170a4-344c-448f-8de0-025172dba30b
md"### Julia code snippet 3.26"

# ╔═╡ fd6783a7-3e40-4eb9-abf8-47c1978041f5
w = [rand(Binomial(9, p)) for p in samples2]

# ╔═╡ Cell order:
# ╠═d9d421ed-b182-4def-a608-bf0005eee3d7
# ╠═cb745deb-2d58-4a73-a954-7fc885654e15
# ╠═10249d26-e2b5-4ce5-a87d-4a703e9f3b45
# ╟─3080b453-0a4f-45ef-8e3d-731c44e14b6d
# ╠═7148ccef-6649-4208-8107-bc886315c42f
# ╟─542059d8-0152-4add-8c1f-81c76ebef04c
# ╠═524b026e-a281-46ff-8438-bd6968571335
# ╟─0b948b52-144d-437c-b69d-cff99c901210
# ╠═b6c1ea47-c1a3-4b6a-bc72-d97ea64d81c6
# ╠═6b5c3871-61e0-44a0-b852-9b2d0820aad2
# ╟─8169ab77-793d-4e0f-9981-ef0e2ba36508
# ╠═e78b6f64-61b0-4790-a4a7-e40c5546fd5d
# ╟─acbe73d9-75f3-4099-afaa-d1483c6c2323
# ╠═970adc98-dbeb-4454-b6cc-a0fdfa4dc50d
# ╟─61c51874-f9db-4434-81cb-206be02adb48
# ╠═d2702ea5-bdad-4daf-8f34-e0a2f0bd9963
# ╠═47060a12-d34e-404e-956f-b7c6a262c3d7
# ╟─aaed0560-4c07-49a6-a8a9-80d68d8ebf10
# ╠═4adccbf1-7d07-4d0f-b5bc-ba77bf591814
# ╟─5e91f0ee-b23e-4ac5-b4cb-c80d1d3a13ba
# ╠═79a5219e-7a13-473f-b6ca-0f9e3a2c9101
# ╟─e31e8117-f297-4fde-8289-cf6bfeb29b3e
# ╠═a6b662ef-cb3f-4caa-99dc-0bd478d04f5a
# ╟─e7327115-d417-4dad-879d-22bcd27de807
# ╠═3cce986c-0fbd-4da0-9c2d-2544e684f584
# ╟─c3254e98-ac09-46d2-afd1-8968bef00248
# ╠═0dc02541-a73e-4913-b740-80ba755ea71c
# ╟─656171b1-d1a4-4e2e-84bf-34efb7f03b4f
# ╠═1e1eed13-4472-48ef-858b-df4c04ae6269
# ╠═b35c9437-d664-4af8-872f-08aa9f48958b
# ╟─93649bd6-03c2-4c20-9985-4bf82bbbdf28
# ╠═d4242e1c-6033-4d05-9567-261d4251f726
# ╟─8410768e-c81e-4e5e-91f7-789d5a85d434
# ╠═30ad6d2c-cf5a-4c86-801e-af791439960b
# ╟─0419f3b1-a49a-4234-b23c-393457c04c23
# ╠═44f1f5b2-b09a-474b-8147-fb7012a7651d
# ╟─50824b2b-ab77-4255-9e24-7a0881193b81
# ╠═8865e1e3-53ab-4c06-bf6f-09c7048ddd5d
# ╟─eb3d25d8-a963-4ed9-a8dc-2f6a397b1600
# ╠═c3c8171c-facd-4b71-8dab-0aa4b30cc59d
# ╟─570f015f-bbe7-404d-a5ab-5ac570ef8c99
# ╠═ff1cdbdc-81df-4404-a8dc-ec0af633d090
# ╠═f3eb02e9-31ce-4813-bf0b-43bd31b0948a
# ╟─2609d3b7-63bf-453b-a1d2-69195c3f2148
# ╠═0c733bb4-ce48-477b-ac7d-23d2fb2aa7e3
# ╟─bc989c65-1e44-4a56-8954-4c48d887349d
# ╠═275ccd69-e7d5-4a73-8609-c722dec555fa
# ╟─950611f8-d8c0-41f3-9668-2fb7e8e8cbe0
# ╠═dfbf8ad3-bbd8-43ac-bd39-9d4117c60e76
# ╟─eec4cbcd-69a4-49f1-9b1e-ffc6f110c7cb
# ╠═763c4569-d0df-4129-b9c9-f6aaa2b8d7a6
# ╟─61b2214c-7459-47e9-a890-5235380d000c
# ╠═0662dfb6-82ff-4e38-aacd-ed8ec9894393
# ╟─1f11ffc4-d64d-4a42-b313-06a1373e789f
# ╠═b2fa1670-f8ad-4d4d-aa6b-d8e0983e4a17
# ╟─1c350e5b-4d35-4358-b49b-b435c2103936
# ╠═5d5b2bbf-b27c-4679-9520-b318cdce0487
# ╟─046170a4-344c-448f-8de0-025172dba30b
# ╠═fd6783a7-3e40-4eb9-abf8-47c1978041f5
