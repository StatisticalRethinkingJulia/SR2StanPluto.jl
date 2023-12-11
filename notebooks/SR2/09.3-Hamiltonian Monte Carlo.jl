### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ a20974be-c658-11ec-3a53-a185aa9085cb
using Pkg

# ╔═╡ 5fecfda0-af41-430a-8693-b0a408680792
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 3626cf55-ee2b-4363-95ee-75f2444a1542
begin
    using CairoMakie
    using RegressionAndOtherStories
end

# ╔═╡ 4a6f12f9-3b83-42b5-9fed-0296a5a603c6
md" ### 9.3-Hamiltonian Monte Carlo"

# ╔═╡ 2409c72b-cbcc-467f-9e81-23d83d2b703a
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 3500px;
        padding-left: max(10px, 5%);
        padding-right: max(10px, 37%);
    }
</style>
"""

# ╔═╡ 036457b2-4046-4379-bfbc-2e56b562bd54
begin
    # test data
    Random.seed!(1)
    y = zscore(rand(Normal(), 50))
    x = zscore(rand(Normal(), 50))
    
    current_q = [-0.1, 0.2]
    pr = 0.5
    eps = 0.03
    L = 11
    n_samples = 4

end;

# ╔═╡ a0c92dd4-448e-44aa-8bdd-0cc5f09e1307
function u(q, x, y; a=0, b=1, k=0, d=1)
    # muy == q[1]; mux == q[2]
    uval = sum(logpdf.(Normal(q[1], 1), y)) + 
        sum(logpdf.(Normal(q[2], 1), x)) +
        logpdf(Normal(a, b), q[1]) + 
        logpdf(Normal(k, d), q[2])
    -uval
end

# ╔═╡ 03f90e8c-4812-4890-8af5-cd4b197b3816
u(current_q, x, y)

# ╔═╡ 95d8a5ff-df27-4aa7-8203-775799e75868
begin
    f = Figure()
    Axis(f[1, 1])
    
    xs = LinRange(-0.5, 0.5, 100)
    ys = LinRange(-0.5, 0.5, 100)
    zs = [u([qx, qy], x, y) for qx in xs, qy in ys]
    
    contourf!(xs, ys, zs)
    
    f
end

# ╔═╡ 351aaf3b-2194-45f7-9188-285710a89c70
function ugrad( q, x, y; a=0 , b=1 , k=0 , d=1 )
    # muy = q[1]; mux = q[2]
    g1 = sum( y .- q[1] ) .+ (a - q[1]) / b^2  # dU/dmuy
    g2 = sum( x .- q[2] ) .+ (k - q[2]) / d^2  # dU/dmux
    [-g1 , -g2]                                # negative bc energy is neg-log-prob
end


# ╔═╡ adf59549-fef0-4cf5-8468-bb722c43be24
function hmc(x, y, u, ugrad, eps, L, current_q)
  q = current_q
  p = rand(Normal(0, 1), length(q)) # random flick to momentum
  current_p = p

  # Make a half step for momentum at the beginning
  v = u(q, x, y)
  g = ugrad(q, x, y)
  p -= eps * g / 2

  # Initialize bookkeeping
  qtraj = zeros(L+1, length(q)+3)
  qtraj[1, :] = [q[1], q[2], v, g[1], g[2]]

  ptraj = zeros(L+1, length(q))
  ptraj[1, :] = p
  
  # Alternate full steps for position and momentum
  
  for i in 1:L
    # Full position step
    q += eps * p

    # Full step for momentum,, except for last step
    if i !== L
      v - u(q, x, y)
      g = ugrad(q, x, y)
      p -= eps .* g
      ptraj[i+1, :] = p
    end

    # Bookkeeping
    qtraj[i+1, :] = [q[1], q[2], v, g[1], g[2]]
  end
  
  # Make a halfstep for momentum at the end
  
  v = u(q, x, y)
  g = ugrad(q, x, y)
  p -= eps * g / 2

  ptraj[L+1, :] = p

  # Negate momentum to make proposal symmetric
  p = -p

  # Evaluate potential and kinetic energies at beginning and end
  current_U = u([current_q[1], current_q[2]], x, y)
  current_K = sum(current_p .^ 2) / 2
  proposed_U = u([q[1], q[2]], x, y)
  proposed_K = sum(p .^ 2) / 2
  dH = proposed_U + proposed_K - current_U - current_K
  # Accept or reject the state at the end of trajectory
  # Return either position at the end or initial position
  local accept = 0
  local new_q
  if rand(Uniform(0, 1)) < exp(dH)
    new_q = q # Accept
    accept = 1
  else
    new_q = current_q # Reject
  end
  
  (q=new_q, ptraj=ptraj, qtraj=qtraj, accept=accept, dh=dH)
end

# ╔═╡ 589b462c-0056-4016-8a4c-990e5c002317
begin
    Random.seed!(23)
    res = Vector{NamedTuple}(undef, n_samples)
    local q = current_q
    for i in 1:n_samples
        res[i] = hmc(x, y, u, ugrad, eps, L, q)
        q = res[i].q
    end
    res
end;

# ╔═╡ 733d3b02-9bc2-45e5-ba6c-9da0903165ba
keys(res[1])

# ╔═╡ ab5f882e-a5f1-44ab-9668-5c449a719134
res

# ╔═╡ 13054a84-dbf8-41e4-b824-7ab2ae7e1eef
res[1].ptraj

# ╔═╡ e83d0bdb-7671-4a95-b0dd-d2ff29993496
res[2].ptraj[8, :]

# ╔═╡ 8a09cc79-a084-4155-a046-fa95b7738b7c
res[1].qtraj[12, 1:2]

# ╔═╡ 592c46a8-bb89-4137-b45b-2598689c496e
res[2].qtraj[1, 1:2]

# ╔═╡ 943542fa-6f3a-422b-a41b-8065da70c0e8
let
    f = Figure()
    ax = Axis(f[1, 1]; title="First 4 samples in HMC (11 leapfrog steps)", xlabel="x coordinate", ylabel="y coordinate")
    contour!(xs, ys, zs; color=:lightgrey)
    for i in 1:4
        scatter!(res[i].qtraj[:, 1], res[i].qtraj[:, 2])
        lines!(res[i].qtraj[:, 1], res[i].qtraj[:, 2])
    end
    annotations!("1.0", position=(-0.105, 0.205), fontsize=15)
    annotations!("1.3", position=(-0.225, 0.027), fontsize=15)
    annotations!("1.11=2.0", position=(-0.09, -0.285), fontsize=15)
    annotations!("2.8", position=(0.0, -0.1), fontsize=15)
    lines!([-0.12, -0.11], [0.175, 0.14]; color=:black, linewidth=0.6)
    annotations!("p = (-1.30, -1.68)", position=(-0.125, 0.12), fontsize=12)
    lines!([0.021, 0.06], [-0.13, -0.11]; color=:black, linewidth=0.6)
    annotations!("p = (0.46, 2.13)", position=(0.062, -0.11), fontsize=12)
    current_figure()
end

# ╔═╡ bfa04587-7bcb-4035-ac74-df34dbd5cf70
let
    Random.seed!(1)
    global res28 = Vector{NamedTuple}(undef, n_samples)
    q = [-0.1, 0.2]
    l = 28
    eps = 0.03
    for i in 1:n_samples
        res28[i] = hmc(x, y, u, ugrad, eps, l, q)
        q = res28[i].q
    end
    res28
end;

# ╔═╡ ad6a3805-6f58-4716-bd6a-0c1584d460a6
res28[1].qtraj[18, 1:2]

# ╔═╡ a4c25512-9aeb-425a-b833-4216a47ba044
res28[2].qtraj[1, 1:2]

# ╔═╡ f4c45fcb-1061-47c2-87c4-10bd985d0eb6
let
    f = Figure()
    ax = Axis(f[1, 1]; title="First 4 samples in HMC (28 leapfrog steps)", xlabel="x coordinate", ylabel="y coordinate")
    xlims!(ax, [-0.4, 0.4]) # as vector
    ylims!(ax, -0.4, 0.4) # separate, reversed

    contour!(xs, ys, zs; color=:lightgrey)
    for i in 1:4
        scatter!(res28[i].qtraj[:, 1], res28[i].qtraj[:, 2])
        lines!(res28[i].qtraj[:, 1], res28[i].qtraj[:, 2])
    end
    current_figure()
end

# ╔═╡ Cell order:
# ╠═4a6f12f9-3b83-42b5-9fed-0296a5a603c6
# ╠═2409c72b-cbcc-467f-9e81-23d83d2b703a
# ╠═a20974be-c658-11ec-3a53-a185aa9085cb
# ╠═5fecfda0-af41-430a-8693-b0a408680792
# ╠═3626cf55-ee2b-4363-95ee-75f2444a1542
# ╠═036457b2-4046-4379-bfbc-2e56b562bd54
# ╠═a0c92dd4-448e-44aa-8bdd-0cc5f09e1307
# ╠═03f90e8c-4812-4890-8af5-cd4b197b3816
# ╠═95d8a5ff-df27-4aa7-8203-775799e75868
# ╠═351aaf3b-2194-45f7-9188-285710a89c70
# ╠═adf59549-fef0-4cf5-8468-bb722c43be24
# ╠═589b462c-0056-4016-8a4c-990e5c002317
# ╠═733d3b02-9bc2-45e5-ba6c-9da0903165ba
# ╠═ab5f882e-a5f1-44ab-9668-5c449a719134
# ╠═13054a84-dbf8-41e4-b824-7ab2ae7e1eef
# ╠═e83d0bdb-7671-4a95-b0dd-d2ff29993496
# ╠═8a09cc79-a084-4155-a046-fa95b7738b7c
# ╠═592c46a8-bb89-4137-b45b-2598689c496e
# ╠═943542fa-6f3a-422b-a41b-8065da70c0e8
# ╠═bfa04587-7bcb-4035-ac74-df34dbd5cf70
# ╠═ad6a3805-6f58-4716-bd6a-0c1584d460a6
# ╠═a4c25512-9aeb-425a-b833-4216a47ba044
# ╠═f4c45fcb-1061-47c2-87c4-10bd985d0eb6
