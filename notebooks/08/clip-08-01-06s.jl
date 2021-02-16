### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 63ba08cc-59a8-11eb-0a0f-27efac60d779
using Pkg, DrWatson

# ╔═╡ 6db218c6-59a8-11eb-2a8b-7107354cf590
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

# ╔═╡ 51fc19b8-59a8-11eb-2214-15aca59b807b
md" ## Clip-08-01-06s.jl"

# ╔═╡ 8aaa4bcc-59a8-11eb-2003-f1213b116565
begin
	df = CSV.read(sr_datadir("rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	data = (N = size(df, 1), G = df.log_gdp_s,
		R = df.rugged_s)
	PRECIS(df[:, [:log_gdp, :log_gdp_s, :rugged, :rugged_s]])
end

# ╔═╡ d7d3e626-6a45-11eb-1820-a3ec98e556b1
stan8_1_1 = "
parameters {
	real a;
	real b;
}

model {
	a ~ normal(1, 1);
	b ~ normal(0, 1);
}
";

# ╔═╡ a3e7c070-6a46-11eb-072b-3943db854020
begin
	m8_1_1s = SampleModel("m8.1.1s", stan8_1_1)
	rc8_1_1s = stan_sample(m8_1_1s)
	if success(rc8_1_1s)
		post8_1_1s_df = read_samples(m8_1_1s; output_format=:dataframe)
		PRECIS(post8_1_1s_df[:, [:a, :b]])
	end
end

# ╔═╡ ac6a235c-6a67-11eb-0d6c-c38eb2162598
begin
	x = 0:0.01:1
	p1 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:20:4000
		y = post8_1_1s_df.a[i] .+ post8_1_1s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_1s_df.a) .+ mean(post8_1_1s_df.b) .* x, color=:darkblue)
end;

# ╔═╡ 7f74d204-6a6a-11eb-3931-4de1dfb8d527
stan8_1_2 = "
parameters {
	real a;
	real b;
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.1);
}
";

# ╔═╡ 8f79ecfc-6a6a-11eb-1173-2fa6e4609d72
begin
	m8_1_2s = SampleModel("m8.1.2s", stan8_1_2)
	rc8_1_2s = stan_sample(m8_1_2s)
	if success(rc8_1_2s)
		post8_1_2s_df = read_samples(m8_1_2s; output_format=:dataframe)
		PRECIS(post8_1_2s_df[:, [:a, :b]])
	end
end

# ╔═╡ baaabbf4-6a6a-11eb-091d-cd8a0e80004f
begin
	p2 = plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_2s_df.a[i] .+ post8_1_2s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_2s_df.a) .+ mean(post8_1_2s_df.b) .* x, color=:darkblue)

	plot(p1, p2, layout=(1, 2))
end

# ╔═╡ 9a39b1c0-6a6c-11eb-05ce-ab82a8d58dfe
stan8_1_3 = "
parameters {
	real a;
	real b;
real sigma;
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.3);
sigma ~ exponential(1);
}
";

# ╔═╡ 6269a87e-6a6c-11eb-2e14-39df73ddd6d8
begin
	m8_1_3s = SampleModel("m8.1.3s", stan8_1_3)
	rc8_1_3s = stan_sample(m8_1_3s; data)
	if success(rc8_1_3s)
		post8_1_3s_df = read_samples(m8_1_3s; output_format=:dataframe)
		PRECIS(post8_1_3s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 6b462290-6a6c-11eb-2d9b-97241415b825
begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_3s_df.a[i] .+ post8_1_3s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_3s_df.a) .+ mean(post8_1_3s_df.b) .* x, color=:darkblue)
end

# ╔═╡ e890c59c-6a68-11eb-0d33-4d52a21d0ccf
stan8_1_4 = "
data {
	int N;
	vector[N] G;
	vector[N] R;
}

parameters {
	real a;
	real b;
	real<lower=0> sigma;
}

transformed parameters {
	vector[N] mu;
	mu = a + b * (R - 0.125);
}

model {
	a ~ normal(1, 1);
	b ~ normal(0, 1);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
";

# ╔═╡ 8e815d5c-6a66-11eb-21dc-99734c31f4e1
begin
	m8_1_4s = SampleModel("m8.1.4s", stan8_1_4)
	rc8_1_4s = stan_sample(m8_1_4s; data)
	if success(rc8_1_4s)
		post8_1_4s_df = read_samples(m8_1_4s; output_format=:dataframe)
		PRECIS(post8_1_4s_df[:, [:a, :b, :sigma]])
	end
end

# ╔═╡ 04a39568-6a6c-11eb-19ea-f55be3914a51
begin
	plot(;ylim=(0.6, 1.4), leg=false)
	for i in 1:80:4000
		y = post8_1_4s_df.a[i] .+ post8_1_4s_df.b[i] .* x
		plot!(x, y, color=:lightgrey)
	end
	plot!(x, mean(post8_1_4s_df.a) .+ mean(post8_1_4s_df.b) .* x, color=:darkblue)
end

# ╔═╡ 45767e2e-6a63-11eb-3e12-354a7e32a374
md" ## End of clip-08-01-06s.jl"

# ╔═╡ Cell order:
# ╟─51fc19b8-59a8-11eb-2214-15aca59b807b
# ╠═63ba08cc-59a8-11eb-0a0f-27efac60d779
# ╠═6db218c6-59a8-11eb-2a8b-7107354cf590
# ╠═8aaa4bcc-59a8-11eb-2003-f1213b116565
# ╠═d7d3e626-6a45-11eb-1820-a3ec98e556b1
# ╠═a3e7c070-6a46-11eb-072b-3943db854020
# ╠═ac6a235c-6a67-11eb-0d6c-c38eb2162598
# ╠═7f74d204-6a6a-11eb-3931-4de1dfb8d527
# ╠═8f79ecfc-6a6a-11eb-1173-2fa6e4609d72
# ╠═baaabbf4-6a6a-11eb-091d-cd8a0e80004f
# ╠═9a39b1c0-6a6c-11eb-05ce-ab82a8d58dfe
# ╠═6269a87e-6a6c-11eb-2e14-39df73ddd6d8
# ╠═6b462290-6a6c-11eb-2d9b-97241415b825
# ╠═e890c59c-6a68-11eb-0d33-4d52a21d0ccf
# ╠═8e815d5c-6a66-11eb-21dc-99734c31f4e1
# ╠═04a39568-6a6c-11eb-19ea-f55be3914a51
# ╟─45767e2e-6a63-11eb-3e12-354a7e32a374
