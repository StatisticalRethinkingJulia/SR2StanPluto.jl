
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Intro-stan-02s.jl"

md"###### Re-execute relevant parts of intro_stan/intro-stan-01.jl"

begin
	stan1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}"
	m1_1s = SampleModel("m1.1s", stan1_1)     # Define Stan language mdeol
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	m1_1_data = Dict("N" => N, "n" => n, "k" => k)
	rc1_1s = stan_sample(m1_1s, data=m1_1_data)
end;

if success(rc1_1s)

  # Allocate array of 4 Normal fits

  fits = Vector{Normal{Float64}}(undef, 4);

  # Fit a normal distribution to each chain.

  post1_1s_df = read_samples(m1_1s; output_format=:dataframes)

  for i in 1:4
    fits[i] = fit_mle(Normal, post1_1s_df[i][:, :theta])
   end

  # Plot the 4 chain densities and mle estimates

  p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
  x = 0:0.001:1
  for i in 1:4
    μ = round(fits[i].μ, digits=2)
    σ = round(fits[i].σ, digits=2)
    p[i] = density(post1_1s_df[i][:, :theta], lab="Chain $i density",
       xlim=(0.0, 1.0), title="$(N) data points", leg=:topleft)
   plot!(p[i], x, pdf.(Normal(fits[i].μ, fits[i].σ), x), lab="Fitted Normal($μ, $σ)")
  end
  plot(p..., layout=(2, 2))
  
end

md"## End of intro-stan/intro-stan-02s.jl"

