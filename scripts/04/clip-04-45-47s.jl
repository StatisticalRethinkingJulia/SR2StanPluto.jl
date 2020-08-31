# Load Julia packages (libraries) needed for clip

cd(@__DIR__)
using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking
using StanSample

include(projectdir("src", "quap.jl"))

# ### snippet 4.7

df = CSV.read(sr_path("..", "data", "Howell1.csv"), delim=';')

# Use only adults

df2 = filter(row -> row[:age] >= 18, df);
mean_weight = mean(df2[:, :weight]);
df2[!, :weight_c] = df2[:, :weight] .- mean_weight;
first(df2, 5)

# Define the Stan language model

weightsmodel = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] height; // Predictor
 vector[N] weight; // Outcome
}

parameters {
 real alpha; // Intercept
 real beta; // Slope (regression coefficients)
 real < lower = 0 > sigma; // Error SD
}

model {
 height ~ normal(alpha + weight * beta , sigma);
}
";

# Define the SampleModel.

sm = SampleModel("weights", weightsmodel);

# Input data for cmdstan

heightsdata = Dict("N" => length(df2[:, :height]), 
  "height" => df2[:, :height], "weight" => df2[:, :weight_c]);

# Sample using cmdstan

rc = stan_sample(sm, data=heightsdata);

# Plot estimates using the N = [10, 50, 150, 352] observations

p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)

nvals = [10, 50, 150, 352];

for i in 1:length(nvals)

  N = nvals[i]

  heightsdataN = Dict(
    "N" => N, 
    "height" => df2[1:N, :height], 
    "weight" => df2[1:N, :weight]
  )
  
  local sm = SampleModel("weights", weightsmodel);
  local rc = stan_sample(sm, data=heightsdataN)

  if success(rc)

    local xi = 30.0:0.1:65.0
    sample_df = read_samples(sm; output_format=:dataframe)
    p[i] = scatter(df2[1:N, :weight], df2[1:N, :height], 
      leg=false, xlab="weight_c")
    for j in 1:N
      local yi = sample_df[j, :alpha] .+ sample_df[j, :beta]*xi
      plot!(p[i], xi, yi, title="N = $N")
    end

    scatter!(p[i], df2[1:N, :weight], df2[1:N, :height], leg=false,
      color=:darkblue, xlab="weight")

  end

end

plot(p..., layout=(2, 2))
savefig(plotsdir("04", "Fig-45-47.png"))

# End of `04/clip-45-47a.jl`
