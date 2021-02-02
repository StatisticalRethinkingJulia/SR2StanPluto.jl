
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-16s.jl"

begin
	sppnames = [:afarensis, :africanus, :hapilis, :boisei, :rudolfensis, :ergaster, :sapiens]
	brainvol = [438, 452, 612, 521, 752, 871, 1350]
	masskg = [37, 35.5, 34.5, 41.5, 55.5, 61, 53.5]
	df = DataFrame(species = sppnames, brain = brainvol, mass = masskg)
	scale!(df, [:mass, :brain])
	df.brain_std = df.brain/maximum(df.brain)
end;

df

begin
	scatter(df.mass, df.brain, xlab="body mass [kg]", ylab="brain vol [cc]", 
		lab="Observations")
	for (ind, species) in pairs(df.species)
		annotate!([(df[ind, :mass] + 1, df[ind, :brain] + 30,
			Plots.text(df[ind, :species], 6, :red, :right))])
	end
	plot!()
end

stan7_6 = "
data{
	int N;
    vector[N] brain_std;
    vector[N] mass_std;
}
parameters{
    real a;
    real b1;
    real b2;
    real b3;
    real b4;
    real b5;
    real b6;
}
model{
    vector[N] mu;
    b6 ~ normal( 0 , 10 );
    b5 ~ normal( 0 , 10 );
    b4 ~ normal( 0 , 10 );
    b3 ~ normal( 0 , 10 );
    b2 ~ normal( 0 , 10 );
    b1 ~ normal( 0 , 10 );
    a ~ normal( 0.5 , 1 );
    for ( i in 1:N ) {
        mu[i] = a + b1 * mass_std[i] + b2 * mass_std[i]^2 + b3 * mass_std[i]^3 + b4 * mass_std[i]^4 + b5 * mass_std[i]^5 + b6 * mass_std[i]^6;
    }
    brain_std ~ normal( mu , 0.001 );
}
generated quantities{
    vector[N] log_lik;
    vector[N] mu;
    for ( i in 1:N ) {
        mu[i] = a + b1 * mass_std[i] + b2 * mass_std[i]^2 + b3 * mass_std[i]^3 + b4 * mass_std[i]^4 + b5 * mass_std[i]^5 + b6 * mass_std[i]^6;
    }
    for ( i in 1:N ) log_lik[i] = normal_lpdf( brain_std[i] | mu[i] , 0.001 );
}
";

begin
	data = (N = 7, brain_std = df.brain_std, mass_std = df.mass_s)
	m7_6s = SampleModel("m7.6s", stan7_6)
	rc7_6s = stan_sample(m7_6s; data=data)

	if success(rc7_6s)
		nt7_6s = read_samples(m7_6s)
	end
end;

begin
	log_lik = nt7_6s.log_lik'
	n_sam, n_obs = size(log_lik)
	lppd = reshape(logsumexp(log_lik .- log(n_sam); dims=1), n_obs)
end

size(log_lik)

sum(lppd)

md"
```
    mean   sd  5.5% 94.5% n_eff Rhat4
a   0.51 0.01  0.50  0.52    47  1.07
b1  0.88 0.01  0.86  0.90    50  1.07
b2  1.71 0.03  1.65  1.76    46  1.07
b3 -0.61 0.03 -0.65 -0.56    49  1.07
b4 -3.48 0.05 -3.56 -3.40    48  1.06
b5 -0.35 0.02 -0.38 -0.32    50  1.06
b6  1.63 0.02  1.59  1.66    49  1.06
```
"

PRECIS(read_samples(m7_6s; output_format=:dataframe))

md" ## End of clip-07-16s.jl"

