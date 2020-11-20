
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.3s.jl"))

md"## Clip-05-15-17s.jl"

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

md"## End of clip-05-15-17s.jl"

