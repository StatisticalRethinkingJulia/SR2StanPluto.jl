### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ f4f1a9d4-fcde-11ea-24d9-efff04ac07bc
using Pkg, DrWatson

# ╔═╡ f4f1e034-fcde-11ea-08da-b7f09891f0a5
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ f4f26af4-fcde-11ea-0020-45e8f5b3ad00
for suf in ["MA", "AM"]
  include(projectdir("models", "05", "m5.4.$(suf)s.jl"))
end

# ╔═╡ 1bfdf3ee-fcde-11ea-0161-539e0e2b0932
md"## Clip-05-13-14s.jl"

# ╔═╡ f501e93e-fcde-11ea-2bc3-256fb8778233
if success(rc)
	begin
		pMA = plotbounds(df, :M, :A, dfs_MA, [:a, :bMA, :sigma])
		pAM = plotbounds(df, :A, :M, dfs_AM, [:a, :bAM, :sigma])
		plot(pAM, pMA, layout=(1, 2))
	end
end

# ╔═╡ f502a090-fcde-11ea-37d0-233bf56ce068
md"##### Compute standardized residuals."

# ╔═╡ f50ffec0-fcde-11ea-2670-534a1a8a9725
if success(rc)
	begin
		p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
		a = -2.5:0.1:3.0
		mu_MA = mean(p_MA.a) .+ mean(p_MA.bMA)*a
		p[1] = plot(xlab="Age at marriage (std)", ylab="Marriage rate (std)", leg=false)
		plot!(a, mu_MA)
		scatter!(df[:, :A_s], df[:, :M_s])
		annotate!([(df[9, :A_s]-0.1, df[9, :M_s], Plots.text("DC", 6, :red, :right))])
	end
end

# ╔═╡ f510ac4e-fcde-11ea-05a8-fdda93bbfc2a
if success(rc)
	begin
		m = -2.0:0.1:3.0
		mu_AM = mean(p_AM.a) .+ mean(p_AM.bAM)*m
		p[2] = plot(ylab="Age at marriage (std)", xlab="Marriage rate (std)", leg=false)
		plot!(m, mu_AM)
		scatter!(df[:, :M_s], df[:, :A_s])
		annotate!([(df[9, :M_s]+0.2, df[9, :A_s], Plots.text("DC", 6, :red, :left))])
	end
end

# ╔═╡ f51db3b0-fcde-11ea-1be0-eb23b24429e1
if success(rc)
	begin
		mu_MA_obs = mean(p_MA.a) .+ mean(p_MA.bMA)*df[:, :A_s]
		res_MA = df[:, :M_s] - mu_MA_obs

		df2 = DataFrame(
			:d => df[:, :D_s],
			:r => res_MA
		)

		m1 = lm(@formula(d ~ r), df2)
		#coef(m1) |> display

		p[3] = plot(xlab="Marriage rate residuals", ylab="Divorce rate (std)", leg=false)
		plot!(m, coef(m1)[1] .+ coef(m1)[2]*m)
		scatter!(res_MA, df[:, :D_s])
		vline!([0.0], line=:dash, color=:black)
		annotate!([(res_MA[9], df[9, :D_s]+0.1, Plots.text("DC", 6, :red, :bottom))])
	end
end

# ╔═╡ f52450f0-fcde-11ea-066b-153ac07ad60d
if success(rc)
	begin
		mu_AM_obs = mean(p_AM.a) .+ mean(p_AM.bAM)*df[:, :M_s]
		res_AM = df[:, :A_s] - mu_AM_obs
		df3 = DataFrame(
			:d => df[:, :D_s],
			:r => res_AM
		)

		m2 = lm(@formula(d ~ r), df3)
		#coef(m2) |> display

		p[4] = plot(xlab="Age at marriage residuals", ylab="Divorce rate (std)", leg=false)
		plot!(a, coef(m2)[1] .+ coef(m2)[2]*a)
		scatter!(res_AM, df[:, :D_s])
		vline!([0.0], line=:dash, color=:black)
		annotate!([(res_AM[9]-0.1, df[9, :D_s], Plots.text("DC", 6, :red, :right))])
	end
end

# ╔═╡ f533f69a-fcde-11ea-0181-e5e75979c929
plot(p..., layout=(2,2))

# ╔═╡ f53b5e30-fcde-11ea-05c9-41a05f46fa1d
md"## End of clip-05-13-14s.jl"

# ╔═╡ Cell order:
# ╟─1bfdf3ee-fcde-11ea-0161-539e0e2b0932
# ╠═f4f1a9d4-fcde-11ea-24d9-efff04ac07bc
# ╠═f4f1e034-fcde-11ea-08da-b7f09891f0a5
# ╠═f4f26af4-fcde-11ea-0020-45e8f5b3ad00
# ╠═f501e93e-fcde-11ea-2bc3-256fb8778233
# ╠═f502a090-fcde-11ea-37d0-233bf56ce068
# ╠═f50ffec0-fcde-11ea-2670-534a1a8a9725
# ╠═f510ac4e-fcde-11ea-05a8-fdda93bbfc2a
# ╠═f51db3b0-fcde-11ea-1be0-eb23b24429e1
# ╠═f52450f0-fcde-11ea-066b-153ac07ad60d
# ╠═f533f69a-fcde-11ea-0181-e5e75979c929
# ╟─f53b5e30-fcde-11ea-05c9-41a05f46fa1d
