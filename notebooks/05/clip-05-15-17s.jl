### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 793190e2-fce9-11ea-0f94-8d23919bbda3
using Pkg, DrWatson

# ╔═╡ 7931d048-fce9-11ea-3644-cbdb925b4031
begin
	#@quickactivate "StatisticalRethinkingStan"
	using StanQuap, GLM
	using StatisticalRethinking
end

# ╔═╡ 9670408e-fce1-11ea-1d03-51e8376f67e1
md"## Clip-05-15-17s.jl"

# ╔═╡ 32dfbbfe-81e2-11eb-29f8-754d6aebcb49
begin
	df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);
	scale!(df, [:Marriage, :MedianAgeMarriage, :Divorce])
end;

# ╔═╡ 851c9784-81e2-11eb-01f0-073edd961499
stan5_3 = "
data {
  int N;
  vector[N] divorce_s;
  vector[N] marriage_s;
  vector[N] medianagemarriage_s;
}
parameters {
  real a;
  real bA;
  real bM;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + + bA * medianagemarriage_s + bM * marriage_s;
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  bM ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  divorce_s ~ normal( mu , sigma );
}
";

# ╔═╡ 851d5eda-81e2-11eb-1174-4fc6ec7295b1
begin
	data = (N = size(df, 1), divorce_s = df.Divorce_s,
		marriage_s = df.Marriage_s, medianagemarriage_s = df.MedianAgeMarriage_s)
	init = (a = 0.0, bM = 0.0, bA = 1.0, sigma = 1.0)
	q5_3s, m5_3s, o5_3s = stan_quap("m5.3s", stan5_3; data, init);
	if !isnothing(q5_3s)
		quap5_3s_df = sample(q5_3s)
	end
	if !isnothing(m5_3s)
		post5_3s_df = read_samples(m5_3s, :dataframe)
		PRECIS(post5_3s_df)
	end
end

# ╔═╡ 952ba332-828b-11eb-2511-bff99eaa1236
md"##### Quadratic approximation:"

# ╔═╡ 851cc740-81e2-11eb-0af3-7f59f78c706e
# Rethinking results
rethinking_results = "
	   mean   sd  5.5% 94.5%
a      0.00 0.10 -0.16  0.16
bM    -0.07 0.15 -0.31  0.18
bA    -0.61 0.15 -0.85 -0.37
sigma  0.79 0.08  0.66  0.91
";

# ╔═╡ 2e11fb74-828b-11eb-012d-67e9445387d5
if !isnothing(q5_3s)
	PRECIS(quap5_3s_df)
end

# ╔═╡ 794c76b4-fce9-11ea-3d4b-cdb6ca10a383
if !isnothing(m5_3s)
	begin
		part5_3s = read_samples(m5_3s, :particles)
		N = size(df, 1)
		plot(xlab="Observed divorce", ylab="Predicted divorce",
			title="Posterior predictive plot")
		v = zeros(size(df, 1), 4);
		for i in 1:N
			mu = mean(part5_3s.bM) * df[i, :Marriage_s] + 
				mean(part5_3s.bA) * df[i, :MedianAgeMarriage_s]
			if i == 13
				annotate!([(df[i, :Divorce_s]-0.05, mu,
					Plots.text("ID", 6, :red, :right))])
			end
			if i == 39
				annotate!([(df[i, :Divorce_s]-0.05, mu,
					Plots.text("RI", 6, :red, :right))])
			end
			scatter!([df[i, :Divorce_s]], [mu], color=:red)
			s = rand(Normal(mu, mean(part5_3s.sigma)), 1000)
			v[i, :] = [maximum(s), hpdi(s, alpha=0.11)[2],
				hpdi(s, alpha=0.11)[1], minimum(s)]
		end
		for i in 1:N
			plot!([df[i, :Divorce_s], df[i, :Divorce_s]], [v[i,1], v[i, 4]], 
				color=:darkblue, leg=false)
			plot!([df[i, :Divorce_s], df[i, :Divorce_s]], [v[i,2], v[i, 3]], 
				line=2, color=:black, leg=false)
		end
		df2 = DataFrame(
			:x => df.Divorce_s,
			:y => [mean(part5_3s.bM) * df[i, :Marriage_s] + 
				mean(part5_3s.bA) * df[i, :MedianAgeMarriage_s] for i in 1:N]
		)
		m1 = lm(@formula(y ~ x), df2)
		x = -2.1:0.1:2.2
		y = coef(m1)[2] * x
		plot!(x, y, line=:dash, color=:red)

	end
end

# ╔═╡ 7957c32a-fce9-11ea-09a4-6fdd2e231a7d
md"## End of clip-05-15-17s.jl"

# ╔═╡ Cell order:
# ╟─9670408e-fce1-11ea-1d03-51e8376f67e1
# ╠═793190e2-fce9-11ea-0f94-8d23919bbda3
# ╠═7931d048-fce9-11ea-3644-cbdb925b4031
# ╠═32dfbbfe-81e2-11eb-29f8-754d6aebcb49
# ╠═851c9784-81e2-11eb-01f0-073edd961499
# ╠═851d5eda-81e2-11eb-1174-4fc6ec7295b1
# ╟─952ba332-828b-11eb-2511-bff99eaa1236
# ╠═851cc740-81e2-11eb-0af3-7f59f78c706e
# ╠═2e11fb74-828b-11eb-012d-67e9445387d5
# ╠═794c76b4-fce9-11ea-3d4b-cdb6ca10a383
# ╟─7957c32a-fce9-11ea-09a4-6fdd2e231a7d
