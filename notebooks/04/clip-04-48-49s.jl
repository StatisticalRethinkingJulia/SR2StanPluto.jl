### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ dcce92b6-fb8c-11ea-38c3-8fe2806332c5
using Pkg, DrWatson

# ╔═╡ dccecdd0-fb8c-11ea-0845-cf3d76112352
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

# ╔═╡ 81d0320a-fb8b-11ea-1b06-cf4512e17696
md"## Clip-04-48-49s.jl"

# ╔═╡ dccf6e2a-fb8c-11ea-0d03-171f21d6a0f2
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight)
	df.weight_c = (df.weight .- mean_weight)/std(df.weight)
end;

# ╔═╡ 0ca80566-01ab-11eb-0928-4d965069247a
Text(precis(df; io=String))

# ╔═╡ dcdd23a8-fb8c-11ea-0f39-f9b9174dd154
md"##### Define the Stan language model."

# ╔═╡ dcdde1bc-fb8c-11ea-0430-b1893316491d
stan4_6 = "
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

# ╔═╡ dcea0212-fb8c-11ea-097c-ff41624b17e5
md"##### Define the SampleModel."

# ╔═╡ dcef8aca-fb8c-11ea-1230-21768d10856e
begin
	m4_6s = SampleModel("weights", stan4_6)
	m4_6_data = Dict("N" => length(df.height), "height" => df.height, "weight" => df.weight_c)
	rc4_6s = stan_sample(m4_6s, data=m4_6_data)
end;

# ╔═╡ dcf7ac28-fb8c-11ea-09ee-9fe5c75f668a
if success(rc4_6s)
  post4_6s_df = read_samples(m4_6s; output_format=:dataframe)
end;

# ╔═╡ dcf84386-fb8c-11ea-18ef-0b8ff5c50351
md"### Snippet 4.47"

# ╔═╡ dd05a5bc-fb8c-11ea-3975-c3ffe53fc995
# Show first 5 draws of correlated parameter values in chain 1

if success(rc4_6s)
  post4_6s_df[1:5,:]
end

# ╔═╡ 18413a74-fb8d-11ea-2c54-7ba333cc282e
PRECIS(post4_6s_df)

# ╔═╡ dd09e4ce-fb8c-11ea-1b16-6d5afe600ab1
md"### Snippets 4.48 & 4.49"

# ╔═╡ dd15ae06-fb8c-11ea-31c3-0384c46a30a4
md"##### Plot estimates using the N = [10, 50, 150, 352] observations."

# ╔═╡ dd1eb0a2-fb8c-11ea-10a6-9719064d2e92
begin
	nvals = [10, 50, 150, 352];
	figs = Vector{Plots.Plot{Plots.GRBackend}}(undef, 4)
	for i in 1:length(nvals)
		N = nvals[i]
		heightsdataN = Dict("N" => N, "height" => df[1:N, :height], "weight" => df[1:N, :weight_c])
    
		# Make sure previous sample files are removed!
		sm = SampleModel("weights", stan4_6);
		rc = stan_sample(m4_6s, data=heightsdataN)

		if success(rc)

		sample_df = read_samples(m4_6s; output_format=:dataframe)
		xi = -2.5:0.1:3.0
		figs[i] = scatter(df[1:N, :weight_c], df[1:N, :height],
			leg=false, xlab="weight_c")

			for j in 1:N
				yi = sample_df[j, :alpha] .+ sample_df[j, :beta]*xi
				plot!(figs[i], xi, yi, color=:grey, title="N = $N")
			end
		end
	end
end

# ╔═╡ dd272abe-fb8c-11ea-0374-97c8ceb7ab2e
plot(figs..., layout=(2, 2))

# ╔═╡ dd2a1988-fb8c-11ea-32bc-41ce8259539f
md"## End of clip-04-48-49s.jl"

# ╔═╡ Cell order:
# ╟─81d0320a-fb8b-11ea-1b06-cf4512e17696
# ╠═dcce92b6-fb8c-11ea-38c3-8fe2806332c5
# ╠═dccecdd0-fb8c-11ea-0845-cf3d76112352
# ╠═dccf6e2a-fb8c-11ea-0d03-171f21d6a0f2
# ╠═0ca80566-01ab-11eb-0928-4d965069247a
# ╟─dcdd23a8-fb8c-11ea-0f39-f9b9174dd154
# ╠═dcdde1bc-fb8c-11ea-0430-b1893316491d
# ╟─dcea0212-fb8c-11ea-097c-ff41624b17e5
# ╠═dcef8aca-fb8c-11ea-1230-21768d10856e
# ╠═dcf7ac28-fb8c-11ea-09ee-9fe5c75f668a
# ╟─dcf84386-fb8c-11ea-18ef-0b8ff5c50351
# ╠═dd05a5bc-fb8c-11ea-3975-c3ffe53fc995
# ╠═18413a74-fb8d-11ea-2c54-7ba333cc282e
# ╟─dd09e4ce-fb8c-11ea-1b16-6d5afe600ab1
# ╟─dd15ae06-fb8c-11ea-31c3-0384c46a30a4
# ╠═dd1eb0a2-fb8c-11ea-10a6-9719064d2e92
# ╠═dd272abe-fb8c-11ea-0374-97c8ceb7ab2e
# ╟─dd2a1988-fb8c-11ea-32bc-41ce8259539f
