### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 1023a7b4-f3a1-11ea-2ef9-25fc0b399e02
using Pkg, DrWatson

# ╔═╡ 446102a4-f3a1-11ea-1123-5705598143b8
using StatisticalRethinking

# ╔═╡ ab58a6ec-f3a1-11ea-00a9-49baa8d23645


# ╔═╡ 4460cd50-f3a1-11ea-0e00-23d86f74a3b8
@quickactivate "StatisticalRethinkingStan"

# ╔═╡ 4461699c-f3a1-11ea-1d09-3b67c733381c
# Set plots backend to PyPlot
pyplot()

# ╔═╡ 446ec132-f3a1-11ea-1b65-77a8fb1a1060
# Generate some funky heteroscedastic data
data = DataFrame(y =[rand(TruncatedNormal(1, .4n, n/2, 2n)) for n in 1:100], x=collect(1:100));

# ╔═╡ 4476df5c-f3a1-11ea-33b0-47454b899746
# Model the data
ols = lm(@formula(y ~ x), data)

# ╔═╡ 4477978a-f3a1-11ea-224e-d54c85e86d65
# Get cutoff points to group data (we’ll use these to generate the distributions)
groups = [percentile(data.x, n) for n in 0:20:100]

# ╔═╡ 44807184-f3a1-11ea-1385-ff7c33546c48
dists = [
    fit(Normal, [data.y[i] for i in 1:length(data.y) if groups[j - 1] < data.x[i] < groups[j]])
    for j in 2:length(groups)
]

# ╔═╡ 4485f988-f3a1-11ea-1770-cd8650cca326
# The distributions are at the 20th, 40th, 60th, 80th, and 100th percentiles so this
# next variable will store values at the 10th, 30th, etc., percentiles so that dists
# appear in the middle of the data points that they represent when plotted
distlocs = [percentile(data.x, n) for n in 10:20:100]

# ╔═╡ 448b723c-f3a1-11ea-2b83-a99fe8bbd82f
xmin = minimum(data.y)

# ╔═╡ 448bfaae-f3a1-11ea-35bf-eb95cb84713a
xmax = maximum(data.y)

# ╔═╡ 4496707e-f3a1-11ea-316b-63ab0ff0df53
# You'll likely have to tweak the xmin/xmax values in xrange to get the desired result
xrange = collect(xmin-25:1:1.5xmax)

# ╔═╡ 44975c32-f3a1-11ea-21bd-abc75f95ba24
# Add scatter points
p = plot(
    data.x,
    data.y,
    seriestype = :scatter,
    markersize = 2,
    markerstrokewidth = 0,
    markeralpha = 0.8
)

# ╔═╡ 44a0e0fe-f3a1-11ea-1d76-29da166c9417
# Add regression line
plot!(data.x, predict(ols), line=:line, linestyle=:dash, linealpha=0.6)

# ╔═╡ 44a911ca-f3a1-11ea-2b8b-25d4075bdbc9
# Add distributions
for i in 1:length(dists)
    plot!(
        zeros(length(xrange)) .+ distlocs[i],
        xrange,
        [pdf(dists[i], x) for x in xrange],
        legend = false,
        fill=(0.0)
    )
end

# ╔═╡ Cell order:
# ╟─ab58a6ec-f3a1-11ea-00a9-49baa8d23645
# ╠═1023a7b4-f3a1-11ea-2ef9-25fc0b399e02
# ╠═4460cd50-f3a1-11ea-0e00-23d86f74a3b8
# ╠═446102a4-f3a1-11ea-1123-5705598143b8
# ╠═4461699c-f3a1-11ea-1d09-3b67c733381c
# ╠═446ec132-f3a1-11ea-1b65-77a8fb1a1060
# ╠═4476df5c-f3a1-11ea-33b0-47454b899746
# ╠═4477978a-f3a1-11ea-224e-d54c85e86d65
# ╠═44807184-f3a1-11ea-1385-ff7c33546c48
# ╠═4485f988-f3a1-11ea-1770-cd8650cca326
# ╠═448b723c-f3a1-11ea-2b83-a99fe8bbd82f
# ╠═448bfaae-f3a1-11ea-35bf-eb95cb84713a
# ╠═4496707e-f3a1-11ea-316b-63ab0ff0df53
# ╠═44975c32-f3a1-11ea-21bd-abc75f95ba24
# ╠═44a0e0fe-f3a1-11ea-1d76-29da166c9417
# ╠═44a911ca-f3a1-11ea-2b8b-25d4075bdbc9
