### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ f4f1a9d4-fcde-11ea-24d9-efff04ac07bc
using Pkg, DrWatson

# ╔═╡ f4f1e034-fcde-11ea-08da-b7f09891f0a5
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
	using GLM
end

# ╔═╡ 1bfdf3ee-fcde-11ea-0161-539e0e2b0932
md"## Clip-05-13-14s.jl"

# ╔═╡ 4fa2fe54-81dd-11eb-00c8-89b0092adf2c
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame)
	df = DataFrame(
		:A => df[:, :MedianAgeMarriage],
		:M => df[:, :Marriage],
		:D => df[:, :Divorce]
	)
	scale!(df, [:M, :A, :D])
end;

# ╔═╡ 6ba505f2-81dd-11eb-311d-5f1944f30ca6
# Define the Stan language model

stan5_4_AM = "
data {
  int N;
  vector[N] A;
  vector[N] M;
}
parameters {
  real a;
  real bAM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bAM * M;
  a ~ normal( 0 , 0.2 );
  bAM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  A ~ normal( mu , sigma );
}
";

# ╔═╡ 6bc53098-81dd-11eb-17d8-23c55ba9bfee
begin
	m5_4_AMs = SampleModel("m5.4.AM", stan5_4_AM)
	m5_4_data = Dict(
		"N" => size(df, 1), 
		"M" => df[:, :M_s],
		"A" => df[:, :A_s] 
	)
	rc5_4_AMs = stan_sample(m5_4_AMs, data=m5_4_data)
	if success(rc5_4_AMs)
		part5_4_AMs = read_samples(m5_4_AMs, :particles)
		part5_4_AMs
	end
end

# ╔═╡ a3421202-81dd-11eb-2583-d9cc66c08963
stan5_4_MA = "
data {
  int N;
  vector[N] A;
  vector[N] M;
}
parameters {
  real a;
  real bMA;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bMA * A;
  a ~ normal( 0 , 0.2 );
  bMA ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  M ~ normal( mu , sigma );
}
";

# ╔═╡ a1eb539c-81de-11eb-2f32-7dfa617502a4
begin
	m5_4_MAs = SampleModel("m5.4", stan5_4_MA);
	rc5_4_MAs = stan_sample(m5_4_MAs, data=m5_4_data);
	if success(rc5_4_MAs)

	  # Rethinking results

	  rethinking_results = "
			   mean   sd  5.5% 94.5%
		a      0.00 0.09 -0.14  0.14
		bMA   -0.69 0.10 -0.85 -0.54
		sigma  0.68 0.07  0.57  0.79
	  ";

	  part5_4_MAs = read_samples(m5_4_MAs, :particles)
	  part5_4_MAs |> display
	end
end

# ╔═╡ f501e93e-fcde-11ea-2bc3-256fb8778233
if success(rc5_4_AMs)
	begin
		post5_4_MAs_df = read_samples(m5_4_MAs, :dataframe)
		post5_4_AMs_df = read_samples(m5_4_AMs, :dataframe)

		pMA = plotbounds(df, :M, :A, post5_4_MAs_df,
			[:a, :bMA, :sigma]; ylims=(10, 30))
		pAM = plotbounds(df, :A, :M, post5_4_AMs_df, 
			[:a, :bAM, :sigma]; ylims=(10, 30))
		plot(pAM, pMA, layout=(1, 2))
	end
end

# ╔═╡ f502a090-fcde-11ea-37d0-233bf56ce068
md"##### Compute standardized residuals."

# ╔═╡ f50ffec0-fcde-11ea-2670-534a1a8a9725
if success(rc5_4_MAs)
	begin
		figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
		a = -2.5:0.1:3.0
		mu_MA = mean(part5_4_MAs.a) .+ mean(part5_4_MAs.bMA)*a
		figs[1] = plot(xlab="Age at marriage (std)", ylab="Marriage rate (std)", leg=false)
		plot!(a, mu_MA)
		scatter!(df[:, :A_s], df[:, :M_s])
		annotate!([(df[9, :A_s]-0.1, df[9, :M_s], Plots.text("DC", 6, :red, :right))])
	end
end

# ╔═╡ f510ac4e-fcde-11ea-05a8-fdda93bbfc2a
if success(rc5_4_AMs)
	begin
		m = -2.0:0.1:3.0
		mu_AM = mean(part5_4_AMs.a) .+ mean(part5_4_AMs.bAM)*m
		figs[2] = plot(ylab="Age at marriage (std)", xlab="Marriage rate (std)", leg=false)
		plot!(m, mu_AM)
		scatter!(df[:, :M_s], df[:, :A_s])
		annotate!([(df[9, :M_s]+0.2, df[9, :A_s], Plots.text("DC", 6, :red, :left))])
	end
end

# ╔═╡ f51db3b0-fcde-11ea-1be0-eb23b24429e1
if success(rc5_4_MAs)
	begin
		mu_MA_obs = mean(part5_4_MAs.a) .+ mean(part5_4_MAs.bMA)*df[:, :A_s]
		res_MA = df[:, :M_s] - mu_MA_obs

		df2 = DataFrame(
			:d => df[:, :D_s],
			:r => res_MA
		)

		m1 = lm(@formula(d ~ r), df2)
		#coef(m1) |> display

		figs[3] = plot(xlab="Marriage rate residuals", ylab="Divorce rate (std)", leg=false)
		plot!(m, coef(m1)[1] .+ coef(m1)[2]*m)
		scatter!(res_MA, df[:, :D_s])
		vline!([0.0], line=:dash, color=:black)
		annotate!([(res_MA[9], df[9, :D_s]+0.1, Plots.text("DC", 6, :red, :bottom))])
	end
end

# ╔═╡ f52450f0-fcde-11ea-066b-153ac07ad60d
if success(rc5_4_AMs)
	begin
		mu_AM_obs = mean(part5_4_AMs.a) .+ mean(part5_4_AMs.bAM)*df[:, :M_s]
		res_AM = df[:, :A_s] - mu_AM_obs
		df3 = DataFrame(
			:d => df[:, :D_s],
			:r => res_AM
		)

		m2 = lm(@formula(d ~ r), df3)
		#coef(m2) |> display

		figs[4] = plot(xlab="Age at marriage residuals", ylab="Divorce rate (std)", leg=false)
		plot!(a, coef(m2)[1] .+ coef(m2)[2]*a)
		scatter!(res_AM, df[:, :D_s])
		vline!([0.0], line=:dash, color=:black)
		annotate!([(res_AM[9]-0.1, df[9, :D_s], Plots.text("DC", 6, :red, :right))])
	end
end

# ╔═╡ f533f69a-fcde-11ea-0181-e5e75979c929
plot(figs..., layout=(2,2))

# ╔═╡ f53b5e30-fcde-11ea-05c9-41a05f46fa1d
md"## End of clip-05-13-14s.jl"

# ╔═╡ Cell order:
# ╟─1bfdf3ee-fcde-11ea-0161-539e0e2b0932
# ╠═f4f1a9d4-fcde-11ea-24d9-efff04ac07bc
# ╠═f4f1e034-fcde-11ea-08da-b7f09891f0a5
# ╠═4fa2fe54-81dd-11eb-00c8-89b0092adf2c
# ╠═6ba505f2-81dd-11eb-311d-5f1944f30ca6
# ╠═6bc53098-81dd-11eb-17d8-23c55ba9bfee
# ╠═a3421202-81dd-11eb-2583-d9cc66c08963
# ╠═a1eb539c-81de-11eb-2f32-7dfa617502a4
# ╠═f501e93e-fcde-11ea-2bc3-256fb8778233
# ╟─f502a090-fcde-11ea-37d0-233bf56ce068
# ╠═f50ffec0-fcde-11ea-2670-534a1a8a9725
# ╠═f510ac4e-fcde-11ea-05a8-fdda93bbfc2a
# ╠═f51db3b0-fcde-11ea-1be0-eb23b24429e1
# ╠═f52450f0-fcde-11ea-066b-153ac07ad60d
# ╠═f533f69a-fcde-11ea-0181-e5e75979c929
# ╟─f53b5e30-fcde-11ea-05c9-41a05f46fa1d
