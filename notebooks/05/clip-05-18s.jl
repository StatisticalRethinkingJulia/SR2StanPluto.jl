### A Pluto.jl notebook ###
# v0.11.14

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
m5_4_RS = "
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
	m5_4_RSs = SampleModel("m5.4", m5_4_RS);
	m5_4_RS_data = Dict("N" => size(df, 1), "R" => df[:, :R_s], "S" => df[:, :S_s]);
	rc1 = stan_sample(m5_4_RSs, data=m5_4_RS_data);
	if success(rc1)
		dfs_RS = read_samples(m5_4_RSs; output_format=:dataframe)
		p_RS = Particles(dfs_RS)
		q_RS = quap(dfs_RS)
	end
end

# ╔═╡ 89ee52d2-fd1e-11ea-3c23-dfea31e14847
# Define the Stan language model

m5_4_SR = "
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
	m5_4_SRs = SampleModel("m5.4", m5_4_SR);
	m5_4_SR_data = Dict("N" => size(df, 1),  "R" => df[:, :R_s], "S" => df[:, :S_s]);
	rc2 = stan_sample(m5_4_SRs, data=m5_4_SR_data)
	if success(rc2)
		dfs_SR = read_samples(m5_4_SRs; output_format=:dataframe)
		p_SR = Particles(dfs_SR)
		q_SR = quap(dfs_SR)
	end
end

# ╔═╡ e7cb19ce-fd1b-11ea-2ca5-e5f14a1e1d8b
if success(rc1)
	pRS = plotbounds(df, :R, :S, dfs_RS, [:a, :bRS, :sigma])
end;

# ╔═╡ e7d70126-fd1b-11ea-16ad-31564fc648de
if success(rc2)
	pSR = plotbounds(df, :S, :R, dfs_SR, [:a, :bSR, :sigma])
end;

# ╔═╡ e7d799e2-fd1b-11ea-27c6-7f2c85fb9b62
plot(pRS, pSR, layout=(1, 2))

# ╔═╡ e7e35a5c-fd1b-11ea-33da-a32b17168eb2
if success(rc1) && success(rc2)
  # Compute standardized residuals

  p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
  
  r = -2.0:0.1:3.0
  mu_SR = mean(p_SR.a) .+ mean(p_SR.bSR)*r

  p[2] = plot(xlab="R (std)", ylab="S (std)", leg=false)
  plot!(r, mu_SR)
  scatter!(df[:, :S_s], df[:, :R_s])
  
  mu_RS_obs = mean(p_RS.a) .+ mean(p_RS.bRS)*df[:, :S_s]
  res_RS = df[:, :R_s] - mu_RS_obs

  s = -2.0:0.1:3.0
  mu_RS = mean(p_RS.a) .+ mean(p_RS.bRS)*s

  p[1] = plot(xlab="S (std)", ylab="R (std)", leg=false)
  plot!(s, mu_RS)
  scatter!(df[:, :R_s], df[:, :S_s])
  
  mu_SR_obs = mean(p_SR.a) .+ mean(p_SR.bSR)*df[:, :R_s]
  res_SR = df[:, :S_s] - mu_SR_obs

  df2 = DataFrame(
    :y => df[:, :Y_s],
    :r => res_RS
  )

  m1 = lm(@formula(y ~ r), df2)
  #coef(m1) |> display

  p[4] = plot(xlab="R residuals", ylab="Y (std)", leg=false)
  plot!(s, coef(m1)[1] .+ coef(m1)[2]*s)
  scatter!(res_RS, df[:, :Y_s])
  vline!([0.0], line=:dash, color=:black)

  mu_SR_obs = mean(p_SR.a) .+ mean(p_SR.bSR)*df[:, :R_s]
  res_SR = df[:, :S_s] - mu_SR_obs

  df3 = DataFrame(
    :y => df[:, :Y_s],
    :s => res_SR
  )

  m2 = lm(@formula(y ~ s), df3)
  #coef(m2) |> display

  p[3] = plot(xlab="S residuals", ylab="Y (std)", leg=false)
  plot!(r, coef(m2)[1] .+ coef(m2)[2]*r)
  scatter!(res_SR, df[:, :Y_s])
  vline!([0.0], line=:dash, color=:black)
end;

# ╔═╡ e7e3f4ec-fd1b-11ea-10db-abd67cab2161
plot(p..., layout=(2,2))

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
