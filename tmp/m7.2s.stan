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
	brain ~ normal(mu , 0.001);
}
generated quantities {
	vector[N] log_lik;
	real sigma;
	for (i in 1:N)
		log_lik[i] = normal_lpdf(brain[i] | mu[i], 0.001);
	sigma = 0.001;
}