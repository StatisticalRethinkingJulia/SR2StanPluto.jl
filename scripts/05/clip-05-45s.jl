
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Clip-05-44s.jl"

md"### snippet 5.44"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';');
	df = filter(row -> row[:age] > 18, df)
	scale!(df, [:height, :weight])
end;

m5_8 = "
data{
    int N;
    int male[N];
    vector[N] age;
    vector[N] weight;
    vector[N] height;
    int sex[N];
}
parameters{
    vector[2] a;
    real<lower=0,upper=50> sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    a ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = a[sex[i]];
    }
    height ~ normal( mu , sigma );
}
";

md"### Define the SampleModel, etc."

begin
	m5_8s = SampleModel("m5.8", m5_8);
	df[!, :sex] = [df[i, :male] == 1 ? 2 : 1 for i in 1:size(df, 1)]
	df_m = filter(row -> row[:sex] == 2, df)
	df_f = filter(row -> row[:sex] == 1, df)
	m5_8_data = Dict("N" => size(df, 1), "male" => df[:, :male],
		"weight" => df[:, :weight], "height" => df[:, :height], 
		"age" => df[:, :age], "sex" => df[:, :sex])
	rc5_8s = stan_sample(m5_8s, data=m5_8_data)
	dfa5_8s = read_samples(m5_8s; output_format=:dataframe)
end;

if success(rc5_8s)
  part5_8s = Particles(dfa5_8s)
end

if success(rc5_8s)
	quap5_8s = quap(dfa5_8s)
end

if success(rc5_8s)
  plot(title="Densities by sex")
  density!(df_m[:, :height], lab="Male")
  density!(df_f[:, :height], lab="Female")
  vline!([mean(part5_8s[Symbol("a.1")])], lab="Female mean estimate")
  vline!([mean(part5_8s[Symbol("a.2")])], lab="Male mean estimate")
  vline!([mean(quap5_8s[Symbol("a.2")])], lab="Male (quap) mean estimate")
end

md"## End of clip-05-44s.jl"

