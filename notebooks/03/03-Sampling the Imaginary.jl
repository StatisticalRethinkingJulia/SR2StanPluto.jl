### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
    using Distributions
    using StatsPlots
    using StatsBase
    using KernelDensity
    using StatisticalRethinking
end

md"##### Setting default attributes for plots."
default(labels=false)


md"### Snippet 3.1"

begin
    Pr_Positive_Vampire = 0.95
    Pr_Positive_Mortal = 0.01
    Pr_Vampire = 0.001
    tmp = Pr_Positive_Vampire * Pr_Vampire
    Pr_Positive = tmp + Pr_Positive_Mortal * (1 - Pr_Vampire)
    Pr_Vampire_Positive = tmp / Pr_Positive
    Pr_Vampire_Positive
end

md"### Snippet 3.2"

begin
    size = 1000
    p_grid = range(0, 1; length=size)
    prob_p = repeat([1.0], size);
    prob_data = [pdf(Binomial(9, p), 6) for p in p_grid];
    posterior = prob_data .* prob_p
    posterior /= sum(posterior);
end

md"### Snippet 3.3"

begin
    samples_count = 10_000
    cat = Categorical(posterior);
    indices = rand(cat, samples_count)
    samples = p_grid[indices];
end

md"### Snippet 3.4"

scatter(samples; alpha=0.2)

md"### Snippet 3.5"

density(samples)

md"### Snippet 3.6"

sum(posterior[p_grid .< 0.5])

md"### Snippet 3.7"

sum(samples .< 0.5) / samples_count

md"### Snippet 3.8"

sum(@. (samples > 0.5) & (samples < 0.75)) / samples_count

md"### Snippet 3.9"

quantile(samples, 0.8)

md"### Snippet 3.10"

quantile(samples, [0.1, 0.9])

md"### Snippet 3.11"

let
    size = 1000
    p_grid = range(0, 1; length=size)
    prob_p = repeat([1.0], size);
    prob_data = [pdf(Binomial(3, p), 3) for p in p_grid];
    posterior = prob_data .* prob_p
    posterior /= sum(posterior)

    samples_count = 10_000
    cat = Categorical(posterior);
    samples = p_grid[rand(cat, samples_count)];
end;

md"### Snippet 3.12"

percentile(samples, [25, 75])

md"### Snippet 3.13"

hpdi(samples, alpha=0.5)

md"### Snippet 3.14"

p_grid[argmax(posterior)]

md"### Snippet 3.15"

k = kde(samples, bandwidth=0.01)
k.x[argmax(k.density)]

md"### Snippet 3.16"

mean(samples), median(samples)

md"### Snippet 3.17"

sum(@. posterior * abs(0.5 - p_grid))

md"### Snippet 3.18"

loss = map(d -> sum(@. posterior * abs(d - p_grid)), p_grid);

md"### Snippet 3.19"

p_grid[argmin(loss)]

md"### Snippet 3.20"

[pdf(Binomial(2, 0.7), n) for n ∈ 0:2]

md"### Snippet 3.21"

rand(Binomial(2, 0.7))

md"### Snippet 3.22"

s = rand(Binomial(2, 0.7), 10)
println(s)

md"### Snippet 3.23"

let
    dummy_w = rand(Binomial(2, 0.7), 100_000);
    proportions(dummy_w)  # or counts(dummy_w)/100000
end

md"### Snippet 3.24"

let
    dummy_w = rand(Binomial(9, 0.7), 100_000);
    histogram(dummy_w; xlabel="dummy water count", ylabel="Frequency")
end

md"### Snippet 3.25"

w = rand(Binomial(9, 0.6), 10_000);

md"### Snippet 3.26"

w = [rand(Binomial(9, p)) for p in samples];


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╠═1f4452e6-57af-11ec-3c3a-9b6f651fda27
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
