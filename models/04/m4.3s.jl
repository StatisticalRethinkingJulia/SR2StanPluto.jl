# Model m4.3as.jl

using Pkg, DrWatson

begin
    using StanQuap
    using StatisticalRethinking
end

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
    mean_weight = mean(df.weight)
    #df.weight_c = df.weight .- mean_weight
end;

stan4_3 = "
data {
    int<lower=1> N;
    vector[N] weight;
    vector[N] height;
}
parameters {
    real a;
    real<lower=0> b;
    real<lower=0, upper=50> sigma;
}
model {
    // Define mu as a vector.
    vector[N] mu;

    // Priors for mu and sigma
    sigma ~ uniform(0 , 50);
    a ~ normal($(mean_weight), 20);
    b ~ lognormal(0, 1);

    // Observed heights
    for (i in 1:N) {
    mu[i] = a + b * (weight[i] - $(mean_weight));
    }
    height ~ normal(mu, sigma);
}
";

data = (N = length(df.height), height = df.height, weight = df.weight)
init = (a = 180.0, b = 1.0, sigma = 10.0)
q4_3s, m4_3s, o4_3s = stan_quap("m4.2s", stan4_3; data, init);

if q4_3s.converged  
    quap4_3s_df = sample(q4_3s)          # DataFrame with samples
    precis(quap4_3s_df)
    post4_3s = read_samples(m4_3s)
    post4_3s |> display
end

# End of m4.3as.jl