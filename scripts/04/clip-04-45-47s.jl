
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"# Clip-04-45-47s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight);
	df.weight_c = df.weight .- mean_weight;
end;

md"##### Define the Stan language model."

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

md"##### Define the SampleModel and sample."

begin
	m4_5s = SampleModel("m4.5s", stan4_5)
	m4_5_data = Dict("N" => length(df.height), "height" => df.height, "weight" => df.weight_c)
	rc4_5s = stan_sample(m4_5s, data=m4_5_data)
end;

md"###### Plot estimates using the N = [10, 50, 150, 352] observations."

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

plot(figs..., layout=(2, 2))

md"## End of clip-04-45-47a.jl"

