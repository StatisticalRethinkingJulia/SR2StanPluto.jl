### A Pluto.jl notebook ###
# v0.12.12

using Markdown
using InteractiveUtils

# ╔═╡ 4ebbc48e-f36d-11ea-1539-f9eba321e104
using Pkg, DrWatson

# ╔═╡ 4ebc01ba-f36d-11ea-09d2-133c45fe6ef6
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 9edef554-f36c-11ea-2444-8536e9175c46
md"## Clip-03-10s.jl"

# ╔═╡ 4ebc87e8-f36d-11ea-14c9-8fad71a03e64
md"##### Define the Stan language model."

# ╔═╡ 4ecc9aa2-f36d-11ea-29da-1983a79088fb
stan3_1 = "
// Inferring a Rate
data {
  int N;
  int<lower=0> k[N];
  int<lower=1> n[N];
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> thetaprior;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);
  thetaprior ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

# ╔═╡ 4ed10010-f36d-11ea-0532-190d793117ae
md"##### Define the SampleModel."

# ╔═╡ 4ed9d668-f36d-11ea-2c95-cd9558ee7092
m3_1s = SampleModel("m3_1ss", stan3_1);

# ╔═╡ 4edf444a-f36d-11ea-39d9-e1df7c43daad
md"##### Use 4 observations."

# ╔═╡ 4ee59bec-f36d-11ea-012c-d5c5c4df711a
begin
	N2 = 4
	n2 = Int.(9 * ones(Int, N2))
	k2 = [6, 5, 7, 6]
end;

# ╔═╡ 4ee6d05c-f36d-11ea-3176-21129362bd4a
md"##### Input data for stan_sample()."

# ╔═╡ 4eede5ae-f36d-11ea-1f0f-b953b1dfecd4
m3_1_data = Dict("N" => length(n2), "n" => n2, "k" => k2);

# ╔═╡ 4efc3d98-f36d-11ea-2bc4-b3ffb525c8f2
md"##### Sample using stan_sample()."

# ╔═╡ 4f040028-f36d-11ea-0331-991166e4f38f
rc3_1s = stan_sample(m3_1s, data=m3_1_data);

# ╔═╡ 4f06f9e0-f36d-11ea-3bcf-51b2ce61f1a5
if success(rc3_1s)
	chn = read_samples(m3_1s; output_format=:mcmcchains)
	CHNS(chn)
end

# ╔═╡ 4f268cc4-f36d-11ea-2311-817925108b74
md"##### Plot the chains."

# ╔═╡ 4f281e9a-f36d-11ea-176e-8d42517d499b
begin
	mixeddensity(chn)
	bnds = MCMCChains.hpd(chn)
	vline!([bnds[:theta, :lower]], line=:dash)
	vline!([bnds[:theta, :upper]], line=:dash)
end

# ╔═╡ 4f14609e-f36d-11ea-22a7-89986a572741
md"##### Look at area of hpd."

# ╔═╡ 4f1b93dc-f36d-11ea-1b30-f7529e8874e3
HPD(chn)

# ╔═╡ 4f2f785c-f36d-11ea-3049-4ddfd1351684
md"## End of clip-03-10s.jl"

# ╔═╡ Cell order:
# ╟─9edef554-f36c-11ea-2444-8536e9175c46
# ╠═4ebbc48e-f36d-11ea-1539-f9eba321e104
# ╠═4ebc01ba-f36d-11ea-09d2-133c45fe6ef6
# ╟─4ebc87e8-f36d-11ea-14c9-8fad71a03e64
# ╠═4ecc9aa2-f36d-11ea-29da-1983a79088fb
# ╟─4ed10010-f36d-11ea-0532-190d793117ae
# ╠═4ed9d668-f36d-11ea-2c95-cd9558ee7092
# ╟─4edf444a-f36d-11ea-39d9-e1df7c43daad
# ╠═4ee59bec-f36d-11ea-012c-d5c5c4df711a
# ╟─4ee6d05c-f36d-11ea-3176-21129362bd4a
# ╠═4eede5ae-f36d-11ea-1f0f-b953b1dfecd4
# ╟─4efc3d98-f36d-11ea-2bc4-b3ffb525c8f2
# ╠═4f040028-f36d-11ea-0331-991166e4f38f
# ╠═4f06f9e0-f36d-11ea-3bcf-51b2ce61f1a5
# ╟─4f268cc4-f36d-11ea-2311-817925108b74
# ╠═4f281e9a-f36d-11ea-176e-8d42517d499b
# ╟─4f14609e-f36d-11ea-22a7-89986a572741
# ╠═4f1b93dc-f36d-11ea-1b30-f7529e8874e3
# ╟─4f2f785c-f36d-11ea-3049-4ddfd1351684
