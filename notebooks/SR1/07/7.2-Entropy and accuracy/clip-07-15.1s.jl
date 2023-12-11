### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 538f05be-5053-11eb-19a0-959e34e1c2a1
using Pkg

# ╔═╡ 5d84f90c-5053-11eb-076b-5f30fc9685e3
begin
	using Distributions
	using StatsPlots
	using StatsBase
	using LaTeXStrings
	using CSV
	using DataFrames
	using LinearAlgebra
	using Random
	using ParetoSmoothedImportanceSampling
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using RegressionAndOtherStories

end

# ╔═╡ 235c5298-5053-11eb-0608-435d1aa4716c
md" ## Clip-07-15s.jl"

# ╔═╡ 861accd4-5053-11eb-0432-81db212f4f38
begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale_df_cols!(df, [:mass, :brain])
	df.brain_std = df.brain/maximum(df.brain)
end;

# ╔═╡ 290d19ae-59cf-11eb-1636-772efccc7cb9
df

# ╔═╡ 24328f84-541d-11eb-0ec3-4df5b8a8cb19
begin
	scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", 
		lab="Observations")
	for (ind, species) in pairs(df.species)
		annotate!([(df[ind, :mass] + 1, df[ind, :brain] + 30,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
	plot!()
end

# ╔═╡ ee275e7a-5067-11eb-325b-7760b758e85e
stan7_6 = "
data{
	int N;
	int K;
    vector[N] brain_std;
    matrix[N, K] mass;
}
parameters{
    real a;
    vector[K] b;
}
transformed parameters {
    vector[N] mu;
    mu = a + mass * b;
}
model{
    b ~ normal( 0 , 10 );
    a ~ normal( 0.5 , 1 );
    brain_std ~ normal( mu , 0.001 );
}
generated quantities{
    vector[N] log_lik;
    for (i in 1:N) log_lik[i] = normal_lpdf( brain_std[i] | mu[i], 0.001 );
}
";

# ╔═╡ 95cbb456-520e-11eb-2e0a-1d173ddc9dec
begin
	mass = create_observation_matrix(df.mass_s, 6)
	data = (N = 7, K = 6, brain_std = df.brain_std, mass = mass)
	m7_6s = SampleModel("m7.6s", stan7_6)
	rc7_6s = stan_sample(m7_6s; data=data)

	if success(rc7_6s)
		nt7_6s = read_samples(m7_6s, :namedtuple)
	end
end;

# ╔═╡ 172b171a-60b2-11eb-1d99-81f8e7cd6217
begin
	log_lik = nt7_6s.log_lik'
	n_sam, n_obs = size(log_lik)
	lppds = reshape(lppd(log_lik), n_obs)
end

# ╔═╡ 675109fc-59e6-11eb-247d-157746d5c626
sum(lppds)

# ╔═╡ e8343c86-5a79-11eb-1cd4-7b05ac85f7dd
md"
```
    mean   sd  5.5% 94.5% n_eff Rhat4
a   0.51 0.01  0.50  0.52    47  1.07
b1  0.88 0.01  0.86  0.90    50  1.07
b2  1.71 0.03  1.65  1.76    46  1.07
b3 -0.61 0.03 -0.65 -0.56    49  1.07
b4 -3.48 0.05 -3.56 -3.40    48  1.06
b5 -0.35 0.02 -0.38 -0.32    50  1.06
b6  1.63 0.02  1.59  1.66    49  1.06
```
"

# ╔═╡ bc6292b4-5a75-11eb-2a11-a31ae9ae5c4f
describe(read_samples(m7_6s, :dataframe))

# ╔═╡ 77373916-5fe2-11eb-2df1-4bf002248937
begin
	loo, loos, pk = psisloo(log_lik)
	loo
end

# ╔═╡ c429b37a-5fe2-11eb-1345-190b929d58d8
sum(loos)

# ╔═╡ c429ee8a-5fe2-11eb-274e-31490ca32c5e
pk_qualify(pk)

# ╔═╡ c42aa528-5fe2-11eb-0492-1fc418032f9c
pk_plot(pk)

# ╔═╡ 7ce0cadc-61a2-11eb-1c20-353d2ad1df76
waic(log_lik)

# ╔═╡ bb780120-6ee5-11eb-2791-1903f6a16fa6
waic(m7_6s)

# ╔═╡ 91e9af0a-5065-11eb-212c-f751fd114263
md" ## End of clip-07-15s.jl"

# ╔═╡ Cell order:
# ╟─235c5298-5053-11eb-0608-435d1aa4716c
# ╠═538f05be-5053-11eb-19a0-959e34e1c2a1
# ╠═5d84f90c-5053-11eb-076b-5f30fc9685e3
# ╠═861accd4-5053-11eb-0432-81db212f4f38
# ╠═290d19ae-59cf-11eb-1636-772efccc7cb9
# ╠═24328f84-541d-11eb-0ec3-4df5b8a8cb19
# ╠═ee275e7a-5067-11eb-325b-7760b758e85e
# ╠═95cbb456-520e-11eb-2e0a-1d173ddc9dec
# ╠═172b171a-60b2-11eb-1d99-81f8e7cd6217
# ╠═675109fc-59e6-11eb-247d-157746d5c626
# ╟─e8343c86-5a79-11eb-1cd4-7b05ac85f7dd
# ╠═bc6292b4-5a75-11eb-2a11-a31ae9ae5c4f
# ╠═77373916-5fe2-11eb-2df1-4bf002248937
# ╠═c429b37a-5fe2-11eb-1345-190b929d58d8
# ╠═c429ee8a-5fe2-11eb-274e-31490ca32c5e
# ╠═c42aa528-5fe2-11eb-0492-1fc418032f9c
# ╠═7ce0cadc-61a2-11eb-1c20-353d2ad1df76
# ╠═bb780120-6ee5-11eb-2791-1903f6a16fa6
# ╟─91e9af0a-5065-11eb-212c-f751fd114263
