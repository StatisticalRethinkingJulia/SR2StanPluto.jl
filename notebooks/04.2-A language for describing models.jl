### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 6a0e1509-a003-4b92-a244-f96a9dd7dd3e
using Pkg

# ╔═╡ ba53534c-c088-4b75-a220-36c09b375978
begin
    # General packages
    using LaTeXStrings

	# Graphics related packages
	using GLMakie
	
	# Stan related packages
	using StanSample
	using StanQuap

	# Project functions
	using StatisticalRethinking: sr_datadir
	using RegressionAndOtherStories
end

# ╔═╡ 6d8c3db8-1705-45d9-9368-02420ded1371
md"## Chapter 4.2 A language for describing models."

# ╔═╡ 462a5453-a918-4649-afb3-6e31c81193cb
md"##### Set page layout for notebook."

# ╔═╡ 0eff3bcb-e3a8-4419-b472-a2e256e04ed3
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(80px, 0%);
    	padding-right: max(200px, 38%);
	}
</style>
"""

# ╔═╡ a6297992-a96d-4c7a-a335-3ac959cdca05
md"In the book and associated R package `rethinking` statistical models are defined as illustrated below:
```
flist <- alist(
  height ~ dnorm( mu , sigma ) ,
  mu <- a + b*weight ,
  a ~ dnorm( 156 , 100 ) ,
  b ~ dnorm( 0 , 10 ) ,
  sigma ~ dunif( 0 , 50 )
)
```
"

# ╔═╡ 5209d2fc-9732-4e76-8669-773e353e545c
md"The author of the book states: *If that (the statistical model) doesn't make much sense, good. ... you're holding the right textbook, since this book teaches you how to read and write these mathematical descriptions* (page 77).
The Pluto notebooks in [SR2StanPluto](https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl) are intended to allow experimenting with this learning process using [Stan](https://github.com/StanJulia) and [Julia](https://julialang.org).
In the R package `rethinking`, posterior values can be approximated by
 
```
# Simulate quadratic approximation (for simpler models)
m4.31 <- quap(flist, data=d2)
```
"

# ╔═╡ d3bae8e4-2eb8-41db-9caa-7d86ebb4de18
md"
or, in the second half of the book, generated using Stan by:
```
# Generate a Stan model and run a simulation
m4.32 <- ulam(flist, data=d2)
```
In SR2StanPluto, R's ulam() has been replaced by StanSample.jl and typically used much earlier on than in the book."

# ╔═╡ 64cef0ce-ba26-4368-9696-b3e1aca5767b
md"
!!! note
	In general SR2StanPluto relies on and shows more details (and capabilities!) of the full Stan Language than the above mentioned `alist`s in the book. In the Julia setting, if your preference is to use something closer to the `alist`s, Turing.jl is a better alternative, e.g. see [SR2TuringPluto](https://github.com/StatisticalRethinkingJulia/SR2TuringPluto.jl).
"

# ╔═╡ d9e5234a-e586-402e-891f-05c88ff6d3c0
md"A few ways to provide similar fuctionality to the R function `quap()` are illustrated in Stan.jl (see Notebook-Examples), i.e. using Optim.jl, using StanOptimize.jl and using StanQuap.jl.

The use of Optim.jl is shown in `Intro-stan-logpdf`. This is probably the best way of obtaining MAP estimates but requires rewriting the models in `logpdf` format.

The use of StanOptimize.jl is shown in `Intro-stan-optimize.jl`.
"

# ╔═╡ ec0fcce1-26e1-432c-a968-ccc5ff3a6095
md"
In the code clips I have opted for a less efficient way of computing the quadratic approximation to the posterior distribution by using StanQuap.jl which uses both StanOptimize.jl and StanSample.jl. The advantage is that this way, as in the StanOptimize.jl approach, the same Stan Language model can be used and it returns both the quapdratic approximation and a full SampleModel which makes comparing the two results easier.
"

# ╔═╡ c301a6a8-aaa2-4cf8-a680-8c0d9ac7ea33
md"##### Introduction to a Stan Language program"

# ╔═╡ 9fefcc0b-d027-4824-917e-a6d9e1da6f72
md"This model represents N experiments each tossing a globe n times and recording the number of times the globe lands on water (`W`) in an array `k`."

# ╔═╡ 1a3bf44c-7239-4902-800e-171271e3c520
md"R's `rethinking` model is defined as:
```
flist <- alist(
  theta ~ Uniform(0, 1)
  k ~ Binomial(n, theta)
)
```"

# ╔═╡ 6b31ced8-a461-4983-8799-c0ac382817b9
md"This model in Stan language could be written as:"

# ╔═╡ bfeb9ae4-4e62-4ddf-8399-55ef24b5779c
stan1_1 = "
// Inferring a rate
data {
  int N;
  int<lower=1> n;
  int<lower=0> k[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);
  // Observed Counts
  k ~ binomial(n, theta);
}";

# ╔═╡ 24ac4bd0-5a2d-4827-a863-fac2626854ab
md"For this model three Stan language blocks are used: data, parameters and the model block."

# ╔═╡ 47a06dbe-7366-4763-ae87-c549b0cde779
md"The first two blocks define the data and the parameter definitions for the model and at the same time can be used to define constraints. As explained in section 2.3 of the book (*'Components of the model'*), variables can be observable or unobservable. Variables known (chosen or observed) are defined in the data block, parameters are not observed but need to be inferred and are defined in the parameter block."

# ╔═╡ 37c5f022-ead3-48b0-81ec-56c6565b4215
md"We know that k can't be negative (k[i] == 0 indicates the globe never landed on `W` in the n tosses). We also assume at least 1 toss is performed, hence n >= 1. In this example we use N=10 experiments of 9 tosses, thus n = 9 in all trials. k[i] is the number of times the globe lands on water in each experiment."

# ╔═╡ 383bf799-de04-4f1a-bc70-1356a7681cd6
md"N, n and the vector k[N] and are all integers."

# ╔═╡ feb1010a-20ff-4e11-bb7d-6b7ad16fe993
md"In this golem, theta, the fraction of water on the globe surface, is assumed to generate the probability a toss lands on `W`. Theta cannot be observed and is the parameter of interest. We know this probability is between 0 an 1. Thus theta is also constrained in the parameters block. Theta is a real number."

# ╔═╡ 8958e4d0-3c56-4a3a-ba5c-dd2d1b0f31a5
md"The third block is the actual model and is pretty much identical to R's alist."

# ╔═╡ 892a9c06-996a-4459-a702-d44c5664c0f0
md"
!!! note
Unfortunately the names of distributions such as Normal and Binomial are not identical between Stan, R and Julia. The Stan language uses the Stan convention (starts with lower case). Also, each Stan language statement ends with a "

# ╔═╡ c06d1922-06b7-4e90-a88b-b43910e772d2
md"##### Running a Stan language program in Julia."

# ╔═╡ 84e39bed-c969-4955-971b-bab0836e6d87
md"Once the Stan language model is defined, in this case stored in the Julia variable stan1_1, below steps execute the program:"

# ╔═╡ 7020d7f7-12ee-4cca-87ee-6bd137bb8c56
md"1. Create a Stanmodel object:"

# ╔═╡ ea4a1dd5-fa89-4e44-a2e2-c357b62d7034
m1_1s = SampleModel("m1.1s", stan1_1);

# ╔═╡ 74c2daa5-d717-4774-809c-3f4a2d5aeb92
md"2. Simulate the results of N repetitions of 9 tosses."

# ╔═╡ 9d066725-2afb-436c-b1f4-525fa56cfc9a
begin
	N = 10                        # Number of globe toss experiment
	d = Binomial(9, 0.66)         # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                # Simulate 15 trial results
	n = 9                         # Each experiment has 9 tosses
end;

# ╔═╡ 91573c60-035d-4b76-8f79-274e99a5b986
md"3. Input data in the form of a Dict"

# ╔═╡ bb6fadae-e336-4df5-a81d-dedbe122f79a
data = (N = N, n = n, k = k);

# ╔═╡ 2b0fd8f8-47f0-48a2-ab81-247bd2e5cbb7
md"4. Sample using stan_sample (the equivalent of `rethinking`'s ulam()."

# ╔═╡ 864aa6c4-cf46-44b6-b883-73ecbf15806d
rc1_1s = stan_sample(m1_1s; data);

# ╔═╡ f041ef25-1dbd-4c02-81db-236f6f76ec23
md"5. Describe and check the results"

# ╔═╡ f2cf4ca2-1632-4754-aa61-5aad4a3f6ccb
if success(rc1_1s)
	describe(m1_1s, [:lp__, :divergent__, :n_leapfrog__, :treedepth__, :theta])
end

# ╔═╡ ab18dd9a-556c-45db-9d9d-ee44118176bb
md"6. Capture the draws in aDataFrame"

# ╔═╡ f82913f0-4d8f-4021-a3c1-f031264c146d
if success(rc1_1s)
	post1_1s_df = read_samples(m1_1s, :dataframe)
	model_summary(post1_1s_df, [:theta])
end

# ╔═╡ 34f7e5ab-164c-4c73-a1f3-f5771eac7ca1
md"### Julia code snippet 4.6"

# ╔═╡ 6bcb5ef8-c053-4ed4-8cff-35acb29c0e90
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1];)
    w = 6
    n = 9
    p_grid = range(0, 1; length=100)
    bin_dens = [pdf(Binomial(n, p), w) for p in p_grid]
    uni_dens = [pdf(Uniform(0, 1), p) for p in p_grid];
    posterior = bin_dens .* uni_dens
    posterior /= sum(posterior)
	density!(posterior; color=(:blue, 0.2), strokecolor=:blue, strokewidth=2)
	f
end

# ╔═╡ Cell order:
# ╠═6d8c3db8-1705-45d9-9368-02420ded1371
# ╠═462a5453-a918-4649-afb3-6e31c81193cb
# ╠═0eff3bcb-e3a8-4419-b472-a2e256e04ed3
# ╠═6a0e1509-a003-4b92-a244-f96a9dd7dd3e
# ╠═ba53534c-c088-4b75-a220-36c09b375978
# ╟─a6297992-a96d-4c7a-a335-3ac959cdca05
# ╟─5209d2fc-9732-4e76-8669-773e353e545c
# ╟─d3bae8e4-2eb8-41db-9caa-7d86ebb4de18
# ╟─64cef0ce-ba26-4368-9696-b3e1aca5767b
# ╟─d9e5234a-e586-402e-891f-05c88ff6d3c0
# ╟─ec0fcce1-26e1-432c-a968-ccc5ff3a6095
# ╟─c301a6a8-aaa2-4cf8-a680-8c0d9ac7ea33
# ╟─9fefcc0b-d027-4824-917e-a6d9e1da6f72
# ╟─1a3bf44c-7239-4902-800e-171271e3c520
# ╟─6b31ced8-a461-4983-8799-c0ac382817b9
# ╠═bfeb9ae4-4e62-4ddf-8399-55ef24b5779c
# ╟─24ac4bd0-5a2d-4827-a863-fac2626854ab
# ╟─47a06dbe-7366-4763-ae87-c549b0cde779
# ╟─37c5f022-ead3-48b0-81ec-56c6565b4215
# ╟─383bf799-de04-4f1a-bc70-1356a7681cd6
# ╟─feb1010a-20ff-4e11-bb7d-6b7ad16fe993
# ╟─8958e4d0-3c56-4a3a-ba5c-dd2d1b0f31a5
# ╟─892a9c06-996a-4459-a702-d44c5664c0f0
# ╟─c06d1922-06b7-4e90-a88b-b43910e772d2
# ╟─84e39bed-c969-4955-971b-bab0836e6d87
# ╟─7020d7f7-12ee-4cca-87ee-6bd137bb8c56
# ╠═ea4a1dd5-fa89-4e44-a2e2-c357b62d7034
# ╟─74c2daa5-d717-4774-809c-3f4a2d5aeb92
# ╠═9d066725-2afb-436c-b1f4-525fa56cfc9a
# ╟─91573c60-035d-4b76-8f79-274e99a5b986
# ╠═bb6fadae-e336-4df5-a81d-dedbe122f79a
# ╟─2b0fd8f8-47f0-48a2-ab81-247bd2e5cbb7
# ╠═864aa6c4-cf46-44b6-b883-73ecbf15806d
# ╟─f041ef25-1dbd-4c02-81db-236f6f76ec23
# ╠═f2cf4ca2-1632-4754-aa61-5aad4a3f6ccb
# ╠═ab18dd9a-556c-45db-9d9d-ee44118176bb
# ╠═f82913f0-4d8f-4021-a3c1-f031264c146d
# ╟─34f7e5ab-164c-4c73-a1f3-f5771eac7ca1
# ╠═6bcb5ef8-c053-4ed4-8cff-35acb29c0e90
