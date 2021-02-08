
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md" ## Clip-07-13-14s.jl"

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

md"
!!! note

	Below results need to be further studied. By manipulating `sigma` the overall results have a similar trend as in the book, but I'm not sure I trust this approach.
"

sig = 0.1

stan7_2 = "
data {
	 int < lower = 1 > N; 			// Sample size
	 int < lower = 1 > K;			// Degree of polynomial
	 vector[N] brain; 				// Outcome
	 matrix[N, K] mass; 			// Predictor
}

parameters {
	real a;                        // Intercept
	vector[K] b;                  // K slope(s)
	real log_sigma;
}

transformed parameters {
    vector[N] mu;
    mu = a + mass * b;
}

model {
	a ~ normal(0.5, 1);        
	b ~ normal(0, 10);
	brain ~ normal(mu , $(sig));
}
generated quantities {
	vector[N] log_lik;
	real sigma;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(brain[i] | mu[i], $(sig));
	sigma = $(sig);
}
";

sig6 = 0.001

stan7_6 = "
data {
	 int < lower = 1 > N; 			// Sample size
	 int < lower = 1 > K;			// Degree of polynomial
	 vector[N] brain; 				// Outcome
	 matrix[N, K] mass; 			// Predictor
}

parameters {
	real a;                        // Intercept
	vector[K] b;                  // K slope(s)
	real log_sigma;
}

transformed parameters {
    vector[N] mu;
    mu = a + mass * b;
}

model {
	a ~ normal(0.5, 1);        
	b ~ normal(0, 10);
	brain ~ normal(mu , $(sig6));
}
generated quantities {
	vector[N] log_lik;
	real sigma;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(brain[i] | mu[i], $(sig6));
	sigma = $(sig6);
}
";

begin
	loo = Vector{Float64}(undef, 6)
	loos = Vector{Vector{Float64}}(undef, 6)
	pk = Vector{Vector{Float64}}(undef, 6)
	deviance = Vector{Float64}(undef, 6)
end;

begin
	tmpdir = joinpath(projectdir(), "tmp")
	lppd_res = Matrix{Float64}(undef, 6, 7)

	for K in 1:6
		N = size(df, 1)
		mass = create_observation_matrix(df.mass_s, K)
		data = (N = N, K = K, brain = df.brain_std, mass = mass)
		
		# `sigma` should really be `exp(log_sigma)`!
		
		if K < 6
			m7_2s = SampleModel("m7.2s", stan7_2; tmpdir)
		else
			m7_2s = SampleModel("m7.2s", stan7_6; tmpdir)
		end
		rc7_2s = stan_sample(m7_2s; data=data)

		if success(rc7_2s)
			nt7_2s = read_samples(m7_2s)
			post7_2s_df = read_samples(m7_2s; output_format=:dataframe)
		end

		log_lik = nt7_2s.log_lik'
		lppd_res[K, :] = lppd(log_lik)
		loo[K], loos[K], pk[K] = psisloo(log_lik)
		
		lp = logprob(post7_2s_df, mass, df.brain_std, K)
		deviance[K] = -2sum(lppd(lp))
	end
	deviance
end

-deviance/2

lppd_res'

sum(lppd_res', dims=1)

md"
!!! note

	Take a look at these runs using `psisloo()` from PSIS.jl. This is explained later in chapter 7.
"

loo

sum.(loos)

pk_qualify(pk[1])

pk_plot(pk[1]; title="PSIS diagnostic plot (K = 1)")

begin
	fig = Vector{Plots.Plot{Plots.GRBackend}}(undef, 6)
	for i in 1:6
		fig[i] = pk_plot(pk[i], title="K = $i", leg=false)
	end
	plot(fig..., layout=(3,2))
end

md" ## End of clip-07-13-14s.jl"

