### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 67824748-fb8a-11ea-2ffd-430bf9a407b7
using Pkg, DrWatson

# ╔═╡ 67828e9e-fb8a-11ea-1ea1-1f3705c329cb
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 225b3552-fb89-11ea-0dbe-611fac11deaf
md"# Clip-04-45-47s.jl"

# ╔═╡ 6790df42-fb8a-11ea-2fef-6771420832e8
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight);
	df.weight_c = df.weight .- mean_weight;
end;

# ╔═╡ 67924116-fb8a-11ea-0715-6fc3b90735b1
md"##### Define the Stan language model."

# ╔═╡ 679e9f60-fb8a-11ea-386c-49c81c17bce6
stan4_5 = "
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

# ╔═╡ 679f40b4-fb8a-11ea-0947-fd9eb9d2cee7
md"##### Define the SampleModel and sample."

# ╔═╡ c14070ca-fb8a-11ea-1442-d782f830e951
begin
	m4_5s = SampleModel("m4.5s", stan4_5)
	m4_5_data = Dict("N" => length(df.height), "height" => df.height, "weight" => df.weight_c)
	rc4_5s = stan_sample(m4_5s, data=m4_5_data)
end;

# ╔═╡ 67af30f0-fb8a-11ea-32d4-37c7c479c9d6
md"###### Plot estimates using the N = [10, 50, 150, 352] observations."

# ╔═╡ 67b872e6-fb8a-11ea-09e0-e7ceda6db093
begin
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
	nvals = [10, 50, 150, 352]
	for i in 1:length(nvals)
		N = nvals[i]
		heightsdataN = Dict(
			"N" => N, 
			"height" => df[1:N, :height], 
			"weight" => df[1:N, :weight]
		)

		m4_5s = SampleModel("m4.5s", stan4_5)
		rc4_5s = stan_sample(m4_5s, data=heightsdataN)

		if success(rc4_5s)

			local xi = 30.0:0.1:65.0
			sample_df = read_samples(m4_5s; output_format=:dataframe)
			figs[i] = scatter(df[1:N, :weight], df[1:N, :height], 
				leg=false, xlab="weight_c")
			for j in 1:N
				local yi = sample_df[j, :alpha] .+ sample_df[j, :beta]*xi
				plot!(figs[i], xi, yi, title="N = $N")
			end

		scatter!(figs[i], df[1:N, :weight], df[1:N, :height], leg=false,
			color=:darkblue, xlab="weight")
		end
	end
end

# ╔═╡ 67c00f38-fb8a-11ea-11fa-61e44b223580
plot(figs..., layout=(2, 2))

# ╔═╡ 67c16860-fb8a-11ea-1275-130c66f8d70c
md"## End of clip-04-45-47a.jl"

# ╔═╡ Cell order:
# ╟─225b3552-fb89-11ea-0dbe-611fac11deaf
# ╠═67824748-fb8a-11ea-2ffd-430bf9a407b7
# ╠═67828e9e-fb8a-11ea-1ea1-1f3705c329cb
# ╠═6790df42-fb8a-11ea-2fef-6771420832e8
# ╟─67924116-fb8a-11ea-0715-6fc3b90735b1
# ╠═679e9f60-fb8a-11ea-386c-49c81c17bce6
# ╟─679f40b4-fb8a-11ea-0947-fd9eb9d2cee7
# ╠═c14070ca-fb8a-11ea-1442-d782f830e951
# ╟─67af30f0-fb8a-11ea-32d4-37c7c479c9d6
# ╠═67b872e6-fb8a-11ea-09e0-e7ceda6db093
# ╠═67c00f38-fb8a-11ea-11fa-61e44b223580
# ╟─67c16860-fb8a-11ea-1275-130c66f8d70c
