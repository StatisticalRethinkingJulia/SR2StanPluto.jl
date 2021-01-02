### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 793190e2-fce9-11ea-0f94-8d23919bbda3
using Pkg, DrWatson

# ╔═╡ 7931d048-fce9-11ea-3644-cbdb925b4031
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 79326280-fce9-11ea-2611-614636b5084e
include(projectdir("models", "05", "m5.3s.jl"))

# ╔═╡ 9670408e-fce1-11ea-1d03-51e8376f67e1
md"## Clip-05-15-17s.jl"

# ╔═╡ 794c76b4-fce9-11ea-3d4b-cdb6ca10a383
if success(rc5_3s)
	begin
		part5_3s = read_samples(m5_3s; output_format=:particles)
		N = size(df, 1)
		plot(xlab="Observed divorce", ylab="Predicted divorce",
			title="Posterior predictive plot")
		v = zeros(size(df, 1), 4);
		for i in 1:N
			mu = mean(part5_3s.bM) * df[i, :Marriage_s] + 
				mean(part5_3s.bA) * df[i, :MedianAgeMarriage_s]
			if i == 13
				annotate!([(df[i, :Divorce_s]-0.05, mu, Plots.text("ID", 6, :red, :right))])
			end
			if i == 39
				annotate!([(df[i, :Divorce_s]-0.05, mu, Plots.text("RI", 6, :red, :right))])
			end
			scatter!([df[i, :Divorce_s]], [mu], color=:red)
			s = rand(Normal(mu, mean(part5_3s.sigma)), 1000)
			v[i, :] = [maximum(s), hpdi(s, alpha=0.11)[2], hpdi(s, alpha=0.11)[1], minimum(s)]
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
		#plot!(x, x, line=(2, :dash), color=:green)
		plot!(x, y, line=:dash, color=:red)

	end
end

# ╔═╡ 7957c32a-fce9-11ea-09a4-6fdd2e231a7d
md"## End of clip-05-15-17s.jl"

# ╔═╡ Cell order:
# ╟─9670408e-fce1-11ea-1d03-51e8376f67e1
# ╠═793190e2-fce9-11ea-0f94-8d23919bbda3
# ╠═7931d048-fce9-11ea-3644-cbdb925b4031
# ╠═79326280-fce9-11ea-2611-614636b5084e
# ╠═794c76b4-fce9-11ea-3d4b-cdb6ca10a383
# ╟─7957c32a-fce9-11ea-09a4-6fdd2e231a7d
