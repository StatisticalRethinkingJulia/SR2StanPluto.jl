
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-04-48-49s.jl"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight)
	df.weight_c = (df.weight .- mean_weight)/std(df.weight)
end

md"##### Define the Stan language model."

m4_6 = "
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

md"##### Define the SampleModel."

begin
	m4_6s = SampleModel("weights", m4_6)
	heightsdata = Dict("N" => length(df.height), "height" => df.height, "weight" => df.weight_c)
	rc = stan_sample(m4_6s, data=heightsdata)
end;

if success(rc)
  dfa = read_samples(m4_6s; output_format=:dataframe)
end;

md"### Snippet 4.47"


if success(rc)
  dfa[1:5,:]
end

Text(precis(dfa; io=String))

md"### Snippets 4.48 & 4.49"

md"##### Plot estimates using the N = [10, 50, 150, 352] observations."

begin
	nvals = [10, 50, 150, 352];
	p = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
	for i in 1:length(nvals)
		N = nvals[i]
		heightsdataN = Dict("N" => N, "height" => df[1:N, :height], "weight" => df[1:N, :weight_c])
    
		# Make sure previous sample files are removed!
		sm = SampleModel("weights", m4_6);
		rc = stan_sample(m4_6s, data=heightsdataN)

		if success(rc)

		sample_df = read_samples(m4_6s; output_format=:dataframe)
		xi = -2.5:0.1:3.0
		p[i] = scatter(df[1:N, :weight_c], df[1:N, :height],
			leg=false, xlab="weight_c")

			for j in 1:N
				yi = sample_df[j, :alpha] .+ sample_df[j, :beta]*xi
				plot!(p[i], xi, yi, color=:grey, title="N = $N")
			end
		end
	end
end

plot(p..., layout=(2, 2))

md"## End of clip-04-48-49s.jl"

