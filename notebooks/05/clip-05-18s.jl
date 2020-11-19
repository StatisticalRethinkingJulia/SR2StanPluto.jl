### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 2f736092-fd1c-11ea-1ba5-cd30dadeb5e6
using Pkg, DrWatson

# ╔═╡ e78a7856-fd1b-11ea-362d-838028fbb539
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

# ╔═╡ 48148154-fd1b-11ea-0c7b-175039156f5b
md"## Clip-05-18s.jl"

# ╔═╡ e7bd61a8-fd1b-11ea-2be6-4f9664f14832
begin
	N = 100
	df = DataFrame(:R => rand(Normal(), N))
	df.S = [rand(Normal(df[i, :R]), 1)[1] for i in 1:N]
	df.Y = [rand(Normal(df[i, :R]), 1)[1] for i in 1:N]
	scale!(df, [:R, :S, :Y])
end;

# ╔═╡ 9fc481be-fd1c-11ea-24fc-b5ee354e8434
Text(precis(df; io=String))

# ╔═╡ e7c914b2-fd1b-11ea-3cf6-2bf799ff7370
stan5_4_RS = "
data {
  int N;
  vector[N] R;
  vector[N] S;
}
parameters {
  real a;
  real bRS;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bRS * S;
  a ~ normal( 0 , 0.2 );
  bRS ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  R ~ normal( mu , sigma );
}
";

# ╔═╡ e58a4fa4-fd20-11ea-3e5e-a518a746f06a
begin
	m5_4_RSs = SampleModel("m5.4", stan5_4_RS);
	m5_4_RS_data = Dict("N" => size(df, 1), "R" => df[:, :R_s], "S" => df[:, :S_s]);
	rc5_4_RSs = stan_sample(m5_4_RSs, data=m5_4_RS_data);
	if success(rc5_4_RSs)
		post5_4_RSs_df = read_samples(m5_4_RSs; output_format=:dataframe)
		part5_4_RSs = Particles(post5_4_RSs_df)
		quap5_4_RSs = quap(post5_4_RSs_df)
	end
end

# ╔═╡ 89ee52d2-fd1e-11ea-3c23-dfea31e14847
# Define the Stan language model

stan5_4_SR = "
data {
  int N;
  vector[N] R;
  vector[N] S;
}
parameters {
  real a;
  real bSR;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bSR * R;
  a ~ normal( 0 , 0.2 );
  bSR ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  S ~ normal( mu , sigma );
}
";

# ╔═╡ be0e0f32-fd3a-11ea-0d07-6f89080d556f
begin
	m5_4_SRs = SampleModel("m5.4", stan5_4_SR);
	m5_4_SR_data = Dict("N" => size(df, 1),  "R" => df[:, :R_s], "S" => df[:, :S_s]);
	rc5_4_SRs = stan_sample(m5_4_SRs, data=m5_4_SR_data)
	if success(rc5_4_SRs)
		post5_4_SRs_df = read_samples(m5_4_SRs; output_format=:dataframe)
		part5_4_SRs = Particles(post5_4_SRs_df)
		quap5_4_SRs_df = quap(post5_4_SRs_df)
	end
end

# ╔═╡ e7cb19ce-fd1b-11ea-2ca5-e5f14a1e1d8b
if success(rc5_4_RSs)
	pRS = plotbounds(df, :R, :S, post5_4_RSs_df, [:a, :bRS, :sigma])
end;

# ╔═╡ e7d70126-fd1b-11ea-16ad-31564fc648de
if success(rc5_4_SRs)
	pSR = plotbounds(df, :S, :R, post5_4_SRs_df, [:a, :bSR, :sigma])
end;

# ╔═╡ e7d799e2-fd1b-11ea-27c6-7f2c85fb9b62
plot(pRS, pSR, layout=(1, 2))

# ╔═╡ e7e35a5c-fd1b-11ea-33da-a32b17168eb2
if success(rc5_4_RSs) && success(rc5_4_SRs)
  # Compute standardized residuals

  figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
  
  r = -2.0:0.1:3.0
  mu_SR = mean(part5_4_SRs.a) .+ mean(part5_4_SRs.bSR)*r

  figs[2] = plot(xlab="R (std)", ylab="S (std)", leg=false)
  plot!(r, mu_SR)
  scatter!(df[:, :S_s], df[:, :R_s])
  
  mu_RS_obs = mean(part5_4_RSs.a) .+ mean(part5_4_RSs.bRS)*df[:, :S_s]
  res_RS = df[:, :R_s] - mu_RS_obs

  s = -2.0:0.1:3.0
  mu_RS = mean(part5_4_RSs.a) .+ mean(part5_4_RSs.bRS)*s

  figs[1] = plot(xlab="S (std)", ylab="R (std)", leg=false)
  plot!(s, mu_RS)
  scatter!(df[:, :R_s], df[:, :S_s])
  
  mu_SR_obs = mean(part5_4_SRs.a) .+ mean(part5_4_SRs.bSR)*df[:, :R_s]
  res_SR = df[:, :S_s] - mu_SR_obs

  df2 = DataFrame(
    :y => df[:, :Y_s],
    :r => res_RS
  )

  m1 = lm(@formula(y ~ r), df2)
  #coef(m1) |> display

  figs[4] = plot(xlab="R residuals", ylab="Y (std)", leg=false)
  plot!(s, coef(m1)[1] .+ coef(m1)[2]*s)
  scatter!(res_RS, df[:, :Y_s])
  vline!([0.0], line=:dash, color=:black)

  mu_SR_obs = mean(part5_4_SRs.a) .+ mean(part5_4_SRs.bSR)*df[:, :R_s]
  res_SR = df[:, :S_s] - mu_SR_obs

  df3 = DataFrame(
    :y => df[:, :Y_s],
    :s => res_SR
  )

  m2 = lm(@formula(y ~ s), df3)
  #coef(m2) |> display

  figs[3] = plot(xlab="S residuals", ylab="Y (std)", leg=false)
  plot!(r, coef(m2)[1] .+ coef(m2)[2]*r)
  scatter!(res_SR, df[:, :Y_s])
  vline!([0.0], line=:dash, color=:black)
end;

# ╔═╡ e7e3f4ec-fd1b-11ea-10db-abd67cab2161
plot(figs..., layout=(2,2))

# ╔═╡ e7f2ca0a-fd1b-11ea-2f47-ad5208060cbd
md"## End of clip-05-18s.jl"

# ╔═╡ Cell order:
# ╟─48148154-fd1b-11ea-0c7b-175039156f5b
# ╠═2f736092-fd1c-11ea-1ba5-cd30dadeb5e6
# ╠═e78a7856-fd1b-11ea-362d-838028fbb539
# ╠═e7bd61a8-fd1b-11ea-2be6-4f9664f14832
# ╠═9fc481be-fd1c-11ea-24fc-b5ee354e8434
# ╠═e7c914b2-fd1b-11ea-3cf6-2bf799ff7370
# ╠═e58a4fa4-fd20-11ea-3e5e-a518a746f06a
# ╠═89ee52d2-fd1e-11ea-3c23-dfea31e14847
# ╠═be0e0f32-fd3a-11ea-0d07-6f89080d556f
# ╠═e7cb19ce-fd1b-11ea-2ca5-e5f14a1e1d8b
# ╠═e7d70126-fd1b-11ea-16ad-31564fc648de
# ╠═e7d799e2-fd1b-11ea-27c6-7f2c85fb9b62
# ╠═e7e35a5c-fd1b-11ea-33da-a32b17168eb2
# ╠═e7e3f4ec-fd1b-11ea-10db-abd67cab2161
# ╟─e7f2ca0a-fd1b-11ea-2f47-ad5208060cbd
