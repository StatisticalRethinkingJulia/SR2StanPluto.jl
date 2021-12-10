### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 0b19c578-762b-11eb-34b6-01e80cef1406
using Pkg, DrWatson

# ╔═╡ 3f814e9e-762b-11eb-1340-91617ca7b58a
begin
    #@quickactivate "SR2StanPluto"
    using StanSample
    using StatisticalRethinking
end

# ╔═╡ 3faf5b5e-762b-11eb-3a66-41ec8a3030ae
stan9_0 ="
data {
    int N;
    vector[N] x;
    vector[N] y;
}
parameters {
    real mux;
    real muy;
}
model {
    mux ~ normal(0, 0.5);
    muy ~ normal(0, 0.5);
    x ~ normal(mux, 1);
    y ~ normal(muy, 1);
}
";

# ╔═╡ 3fafc7fe-762b-11eb-37da-254b6d75f5ca
begin
	m9_0s = SampleModel("m9.0s", stan9_0)
	data = (N = 100, x = rand(Normal(), 100), y = rand(Normal(), 100))
	rc9_0s = stan_sample(m9_0s; data)

	if success(rc9_0s)
		m9_0s_df = read_samples(m9_0s, :dataframe)
		PRECIS(m9_0s_df)
	end
end

# ╔═╡ 3fccf39e-762b-11eb-0f4d-c120f0c58ffc
begin
	# test data
	#Random.seed!(123)

	y = zscore(rand(Normal(), 50))
	x = zscore(rand(Normal(), 50))
end;

# ╔═╡ 697559da-7ac6-11eb-03b2-373578580a2a
begin
    current_q = [-0.1, 0.2]
    pr = 0.5
    eps = 0.03
    L = 11
    n_samples = 4
end

# ╔═╡ 69b1fcaa-7ac6-11eb-1c91-591ff5af66e6
begin
	Random.seed!(159)
    res = Vector{NamedTuple}(undef, n_samples)
    local q = current_q
    for i in 1:n_samples
        res[i] = hmc(x, y, u, ugrad, eps, L, q)
        q = res[i].q
    end
end;

# ╔═╡ 69bde2a6-7ac6-11eb-314f-f9f9ba80de24
begin
    fig = plot(xlims=[-pr, pr], ylims=[-pr, pr], leg=false)
	k0 = zeros(L, n_samples)
	for i in 1:L
		for j in 1:n_samples
			k0[i, j] = sum(res[j].ptraj[i, :].^2)/2		# kinetic energy
		end
	end

    for i in 1:n_samples
        xpos = res[i].qtraj[:, 1]
        ypos = res[i].qtraj[:, 2]
		for j in 1:L
        	plot!([xpos[j], xpos[j+1]], [ypos[j], ypos[j+1]], color=:lightgrey,
				linewidth=k0[j, i])
		end
		scatter!(xpos, ypos, color=:grey)
		i == 1 && plot!([xpos[1]], [ypos[1]], marker = ([:x :d], 10, 0.9, :black))
		annotate!([(xpos[end] - 0.005, ypos[end] - 0.03,
			Plots.text(i, 10, :red, :right))])
    end
	fig
end

# ╔═╡ 8aef9a52-7aea-11eb-0435-e37fa4d80369
begin
    res50 = Vector{NamedTuple}(undef, 50)
    local q = current_q
    for i in 1:50
        res50[i] = hmc(x, y, u, ugrad, eps, L, q)
        q = res50[i].q
    end
end;

# ╔═╡ b669674e-7aea-11eb-1549-b969f18740e1
begin
   fig50 = plot(xlims=[-pr, pr], ylims=[-pr, pr], leg=false)
   for i in 1:50
		xpos = [res50[i].qtraj[end, 1]]
		ypos = [res50[i].qtraj[end, 2]]
		scatter!(xpos, ypos, color=res50[i].accept==1 ? :grey : :red)
		i == 1 && plot!([xpos[1]], [ypos[1]], marker = ([:x :d], 10, 0.9, :blue))
    end
	fig50
end

# ╔═╡ Cell order:
# ╠═0b19c578-762b-11eb-34b6-01e80cef1406
# ╠═3f814e9e-762b-11eb-1340-91617ca7b58a
# ╠═3faf5b5e-762b-11eb-3a66-41ec8a3030ae
# ╠═3fafc7fe-762b-11eb-37da-254b6d75f5ca
# ╠═3fccf39e-762b-11eb-0f4d-c120f0c58ffc
# ╠═697559da-7ac6-11eb-03b2-373578580a2a
# ╠═69b1fcaa-7ac6-11eb-1c91-591ff5af66e6
# ╠═69bde2a6-7ac6-11eb-314f-f9f9ba80de24
# ╠═8aef9a52-7aea-11eb-0435-e37fa4d80369
# ╠═b669674e-7aea-11eb-1549-b969f18740e1
