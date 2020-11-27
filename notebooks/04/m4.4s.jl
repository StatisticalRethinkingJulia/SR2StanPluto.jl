### A Pluto.jl notebook ###
# v0.12.12

using Markdown
using InteractiveUtils

# ╔═╡ 95e6f4e6-2865-11eb-31bb-f51a1f6f2549
using Pkg, DrWatson

# ╔═╡ 4ed86460-2861-11eb-2bd8-43083b1529de
begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample
    using StatisticalRethinking
end

# ╔═╡ 37525988-2861-11eb-2879-5fd01625649b
md"## Model m4.4s"

# ╔═╡ 4f022e8c-2861-11eb-23ad-5992b76394bd
begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
    mean_weight = mean(df.weight)
    df.weight_c = df.weight .- mean_weight
end;

# ╔═╡ 4f029908-2861-11eb-10aa-7d9fc0eec927
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

# ╔═╡ 4f12dab6-2861-11eb-2ab5-db94af68f01f
begin
	m4_4s = SampleModel("m4_4s", stan4_4)
	m4_4_data = Dict(
	  :N => length(df.height), :N_new => 5,
	  :weight_c => df.weight_c, :height => df.height,
	  :x_new => [-30, -10, 0, +10, +30]
	)
	rc4_4s = stan_sample(m4_4s, data=m4_4_data)
end;

# ╔═╡ 4f138b0a-2861-11eb-0985-1b00943863f2
if success(rc4_4s)
  chns4_4s = read_samples(m4_4s; output_format=:mcmcchains)
  Particles(chns4_4s)
end

# ╔═╡ bb9846a6-2861-11eb-02dc-957c2bda5814
q4_4s = quap(m4_4s)                 			# Stan QuapModel

# ╔═╡ bb98768c-2861-11eb-2d79-29c05cf7320b
Particles(4000, q4_4s.distr)          			# Samples from a QuapModel (Particles)

# ╔═╡ bb990b7e-2861-11eb-0df7-13c6c6413b4b
begin
	quap4_4s_df = sample(q4_4s)				# DataFrame with samples
	first(quap4_4s_df, 10)					# First 10 rows
end

# ╔═╡ bba94750-2861-11eb-0a53-99ef01630bb2
pred4_4s_df = stan_generate_quantities(m4_4s, 1)		# Use draws of chain 1 to simulate predictions

# ╔═╡ bbbf2c8c-2861-11eb-1324-a51c06a16e92
begin
	(ytilde, parameters) = read_generated_quantities(m4_4s)		# Read the generated quantities
	pred4_4s_df2 = DataFrame(ytilde[:, :, 1], parameters)		# Convert to a DataFrame
	PRECIS(pred4_4s_df2)										# Show summary
end

# ╔═╡ 4f20e764-2861-11eb-036a-89b36686b6e4
md"## End of m4.4s"

# ╔═╡ Cell order:
# ╟─37525988-2861-11eb-2879-5fd01625649b
# ╠═95e6f4e6-2865-11eb-31bb-f51a1f6f2549
# ╠═4ed86460-2861-11eb-2bd8-43083b1529de
# ╠═4f022e8c-2861-11eb-23ad-5992b76394bd
# ╠═4f029908-2861-11eb-10aa-7d9fc0eec927
# ╠═4f12dab6-2861-11eb-2ab5-db94af68f01f
# ╠═4f138b0a-2861-11eb-0985-1b00943863f2
# ╠═bb9846a6-2861-11eb-02dc-957c2bda5814
# ╠═bb98768c-2861-11eb-2d79-29c05cf7320b
# ╠═bb990b7e-2861-11eb-0df7-13c6c6413b4b
# ╠═bba94750-2861-11eb-0a53-99ef01630bb2
# ╠═bbbf2c8c-2861-11eb-1324-a51c06a16e92
# ╟─4f20e764-2861-11eb-036a-89b36686b6e4
