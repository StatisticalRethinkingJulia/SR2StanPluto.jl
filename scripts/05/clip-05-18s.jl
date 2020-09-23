
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StructuralCausalModels
	using StatisticalRethinking
end

md"## Clip-05-18s.jl"

begin
	N = 100
	df = DataFrame(:R => rand(Normal(), N))
	df.S = [rand(Normal(df[i, :R]), 1)[1] for i in 1:N]
	df.Y = [rand(Normal(df[i, :R]), 1)[1] for i in 1:N]
	scale!(df, [:R, :S, :Y])
end;

Text(precis(df; io=String))

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

if success(rc1)
	pRS = plotbounds(df, :R, :S, dfs_RS, [:a, :bRS, :sigma])
end;

if success(rc2)
	pSR = plotbounds(df, :S, :R, dfs_SR, [:a, :bSR, :sigma])
end;

plot(pRS, pSR, layout=(1, 2))

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

plot(p..., layout=(2,2))

md"## End of clip-05-18s.jl"

