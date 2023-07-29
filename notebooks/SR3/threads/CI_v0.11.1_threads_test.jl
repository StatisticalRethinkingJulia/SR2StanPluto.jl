using DataFrames
using NamedTupleTools
using CausalInference

N = 2000 # number of data points

# define simple linear model with added noise

x = randn(N)
v = x + randn(N)*0.25
w = x + randn(N)*0.25
z = v + w + randn(N)*0.25
s = z + randn(N)*0.25
df = DataFrame(X=x, V=v, W=w, Z=z, S=s)

vars = Symbol.(names(df))
nt = namedtuple(vars, [df[!, k] for k in vars])
@time g = pcalg(nt, 0.25, gausscitest)

@time est_g, score = ges(df; penalty=1.0, parallel=true)

est_g.fadjlist |> display

g.fadjlist |> display

@time g = pcalg(df, 0.25, gausscitest)
