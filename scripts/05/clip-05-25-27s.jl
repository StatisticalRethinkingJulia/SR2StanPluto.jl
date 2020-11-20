
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

include(projectdir("models", "05", "m5.3.As.jl"))

md"## Clip-05-25-27s.jl"

md"##### Rethinking results"

rethinking_results = "
           mean   sd  5.5% 94.5%
  a        0.00 0.10 -0.16  0.16
  bM      -0.07 0.15 -0.31  0.18
  bA      -0.61 0.15 -0.85 -0.37
  sigma    0.79 0.08  0.66  0.91
  aM       0.00 0.09 -0.14  0.14
  bAM     -0.69 0.10 -0.85 -0.54
  sigma_M  0.68 0.07  0.57  0.79
";

part5_3_As = read_samples(m5_3_As; output_format=:particles)

md"## Snippet 5.25"

a_seq = range(-2, stop=2, length=100)

md"## Snippet 5.26"

begin
	post5_3_As_df = read_samples(m5_3_As; output_format=:dataframe)
	m_sim = zeros(size(post5_3_As_df, 1), length(a_seq))
end;

for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.aM[j] + part5_3_As.bAM[j]*a_seq[i], part5_3_As.sigma_M[j])
    m_sim[j, i] = rand(d, 1)[1]
  end
end

md"## Snippet 5.27"

d_sim = zeros(size(post5_3_As_df, 1), length(a_seq));

for j in 1:size(post5_3_As_df, 1)
  for i in 1:length(a_seq)
    d = Normal(part5_3_As.a[j] + part5_3_As.bA[j]*a_seq[i] + part5_3_As.bM[j]*m_sim[j, i], part5_3_As.sigma[j])
    d_sim[j, i] = rand(d, 1)[1]
  end
end

begin
	plot(xlab="Manipulated A", ylab="Counterfactual D",
		title="Total counterfactual effect of A on D")
	plot!(a_seq, mean(d_sim, dims=1)[1, :], leg=false)
	hpdi_array = zeros(length(a_seq), 2)
	for i in 1:length(a_seq)
		hpdi_array[i, :] =  hpdi(d_sim[i, :])
	end
	plot!(a_seq, mean(d_sim, dims=1)[1, :]; ribbon=(hpdi_array[:, 1], -hpdi_array[:, 2]))
end

md"## End of clip-05-25-27s.jl"

