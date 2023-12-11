### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ a20974be-c658-11ec-3a53-a185aa9085cb
using Pkg

# ╔═╡ 39360ef8-2e7d-4943-af7f-9d10248a96f9
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 3626cf55-ee2b-4363-95ee-75f2444a1542
begin
    using CairoMakie
	using RegressionAndOtherStories
end

# ╔═╡ 2409c72b-cbcc-467f-9e81-23d83d2b703a
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 3500px;
        padding-left: max(10px, 5%);
        padding-right: max(10px, 37%);
    }
</style>
"""

# ╔═╡ 4a6f12f9-3b83-42b5-9fed-0296a5a603c6
md" ### 09.1-Good King Markov.jl"

# ╔═╡ c101c831-3ab2-485e-8983-3711513ca967
md"
!!! note

This notebooks uses CairoMakie for graphics."

# ╔═╡ 47a54aeb-769c-4cd9-b1ef-e4b0b92946b6
function metropolis(num_weeks = Int(1e2), current = 10)
    positions = zeros(Int, num_weeks)
    for i in 1:num_weeks
        # Record current position.
        positions[i] = current
        # Flip a coin to generate proposal.
        proposal = current + sample(-1:2:1)
        proposal = proposal < 1 ? 10 : proposal > 10 ? 10 : proposal
        # Moving?
        prop_move = proposal / current
        current = rand(Uniform(0, 1), 1)[1] < prop_move ? proposal : current
    end
    positions
end

# ╔═╡ ed5d093b-0d84-460d-87ac-de7bcf39316e
let
    positions = metropolis(100000, 10)
    cm = countmap(positions)
    f = Figure(;size=default_figure_resolution)
    
    # Left graph
    ax = Axis(f[1, 1]; title="Position in the first 100 weeks", ylabel="Island", xlabel="Week")
	ax.yticks = (0:1:11, vcat(" ", ["$i" for i in 1:10], " "))
    ylims!(ax, 0, 11) # separate
    sca = scatter!(1:100, positions[1:100])
    lin = lines!(1:100, positions[1:100]; color=:lightgrey)

    # Right graph
    ax = Axis(f[1, 2], title="Weeks at each island", ylabel="Number of weeks", xlabel="Island")
    ax.yticks = (0:5000:20000, vcat("0", "5000", "10000", "15000", "20000"))
    barplot!(f[1, 2], 1:10, [cm[i] for i in 1:10], width=0.3, dodge_gap=0.3)

    f
end

# ╔═╡ Cell order:
# ╠═2409c72b-cbcc-467f-9e81-23d83d2b703a
# ╟─4a6f12f9-3b83-42b5-9fed-0296a5a603c6
# ╟─c101c831-3ab2-485e-8983-3711513ca967
# ╠═a20974be-c658-11ec-3a53-a185aa9085cb
# ╠═39360ef8-2e7d-4943-af7f-9d10248a96f9
# ╠═3626cf55-ee2b-4363-95ee-75f2444a1542
# ╠═47a54aeb-769c-4cd9-b1ef-e4b0b92946b6
# ╠═ed5d093b-0d84-460d-87ac-de7bcf39316e
