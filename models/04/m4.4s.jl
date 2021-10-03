# Model m4.4s.jl

using Pkg, DrWatson

begin
    using StanQuap
    using StatisticalRethinking
end

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
    mean_weight = mean(df.weight)
    df.weight_c = df.weight .- mean_weight
end;

stan4_4 = "
data {
    int < lower = 1 > N;               // Sample size
    vector[N] height;                  // Outcome
    vector[N] weight_c;                // Predictor

    int N_new;                         // Number of predictions
    vector[N_new] x_new;               // Predict for x_new
}

parameters {
    real alpha;                        // Intercept
    real beta;                         // Slope (regression coefficients)
    real < lower = 0 > sigma;          // Error SD
}

model {
    height ~ normal(alpha + weight_c * beta , sigma);
}

generated quantities {
    vector[N_new] y_tilde;
    for (n in 1:N_new)
        y_tilde[n] = normal_rng(alpha + beta * x_new[n], sigma);
}
";

data = (
    N = length(df.height), :N_new => 5,
    weight_c = df.weight_c, :height => df.height,
    x_new = [-30, -10, 0, +10, +30]
)
init = (alpha = 180.0, beta = 1.0, sigma = 10.0)
q4_4s, m4_4s, o4_4s = stan_quap("m4.2s", stan4_4; data, init);

if !isnothing(q4_4s)
    quap4_4s_df = sample(q4_4s)          # DataFrame with samples
    precis(quap4_4s_df)
    post4_4s = read_samples(m4_4s)
    post4_4s |> display
end

# End of m4.4s.jl