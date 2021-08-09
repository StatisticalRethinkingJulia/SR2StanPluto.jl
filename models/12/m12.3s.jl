# Load Julia packages (libraries)

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using Random
using StatisticalRethinking

Random.seed!(12345)

stan12_3 = "
data{
    int N;
    int y[N];
}
parameters{
    real ap;
    real al;
}
model{
    real p;
    real lambda;
    al ~ normal( 1 , 0.5 );
    ap ~ normal( -1.5 , 1 );
    lambda = al;
    lambda = exp(lambda);
    p = ap;
    p = inv_logit(p);
    for ( i in 1:N ) {
        if ( y[i]==0 )
            target += log_mix( p , 0 , poisson_lpmf(0|lambda) );
        if ( y[i] > 0 )
            target += log1m( p ) + poisson_lpmf(y[i] | lambda );
    }
}";

# Define the SampleModel.

m12_3s = SampleModel("m12.3s",  stan12_3);

# Input data for cmdstan

prob_drink = 0.2 # 20% of days
rate_work = 1    # average 1 manuscript per day

# sample one year of production
N = 365
drink = rand(Binomial(1, prob_drink ), N)

# simulate manuscripts completed
y = (1 .- drink) .* rand(Poisson(rate_work ), N)

## R code 12.8
#histogram( y , xlab="manuscripts completed" , lwd=4 )

zeros_drink = sum(drink)
zeros_work = sum(y==0 && drink==0)
zeros_total = sum(y==0)

m12_3_data = Dict("N" => length(y), "y" => y);
        
# Sample using cmdstan's sample option

rc12_3s = stan_sample(m12_3s, data=m12_3_data);

# Describe the draws

if success(rc12_3s)
  part12_3s = read_samples(m12_3s, :particles)
  part12_3s |> display
end
