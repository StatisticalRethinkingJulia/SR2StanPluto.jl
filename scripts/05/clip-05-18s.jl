
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
	rc5_4_RSs = stan_sample(m5_4_RSs, data=m5_4_RS_data);
	if success(rc5_4_RSs)
		dfa5_4_RSs = read_samples(m5_4_RSs; output_format=:dataframe)
		part5_4_RSs = Particles(dfa5_4_RSs)
		quap5_4_RSs = quap(dfa5_4_RSs)
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
	rc5_4_SRs = stan_sample(m5_4_SRs, data=m5_4_SR_data)
	if success(rc5_4_SRs)
		dfa5_4_SRs = read_samples(m5_4_SRs; output_format=:dataframe)
		part5_4_SRs = Particles(dfa5_4_SRs)
		quap5_4_SRs = quap(dfa5_4_SRs)
	end
end

if success(rc5_4_RSs)
	pRS = plotbounds(df, :R, :S, dfa5_4_RSs, [:a, :bRS, :sigma])
end;

if success(rc5_4_SRs)
	pSR = plotbounds(df, :S, :R, dfa5_4_SRs, [:a, :bSR, :sigma])
end;

plot(pRS, pSR, layout=(1, 2))

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

plot(figs..., layout=(2,2))

md"## End of clip-05-18s.jl"

