
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
	rc = stan_sample(m5_8s, data=m5_8_data)
	dfa = read_samples(m5_8s; output_format=:dataframe)
end;

if success(rc)
  p = Particles(dfa)
end

if success(rc)
	q = quap(dfa)
end

if success(rc)
  plot(title="Densities by sex")
  density!(df_m[:, :height], lab="Male")
  density!(df_f[:, :height], lab="Female")
  vline!([mean(p[Symbol("a.1")])], lab="Female mean estimate")
  vline!([mean(p[Symbol("a.2")])], lab="Male mean estimate")
  vline!([mean(q[Symbol("a.2")])], lab="Male (quap) mean estimate")
end

md"## End of clip-05-44s.jl"

