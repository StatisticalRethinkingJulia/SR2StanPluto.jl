
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
end

md"## Model m10_4s"

df = CSV.read(sr_datadir("chimpanzees.csv"), DataFrame);


stan10_4s = "
data{
    int N;
    int N_actors;
    int pulled_left[N];
    int prosoc_left[N];
    int condition[N];
    int actor[N];
}
parameters{
    vector[N_actors] a;
    real bp;
    real bpC;
}
model{
    vector[N] p;
    bpC ~ normal( 0 , 10 );
    bp ~ normal( 0 , 10 );
    a ~ normal( 0 , 10 );
    for ( i in 1:504 ) {
        p[i] = a[actor[i]] + (bp + bpC * condition[i]) * prosoc_left[i];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

begin

	m10_4s = SampleModel("m10.4s", stan10_4s);

	m10_4_data = Dict("N" => size(df, 1), "N_actors" => length(unique(df[!, :actor])), 
		"actor" => df[!, :actor], "pulled_left" => df[!, :pulled_left],
		"prosoc_left" => df[!, :prosoc_left], "condition" => df[!, :condition]);

	rc10_4s = stan_sample(m10_4s, data=m10_4_data);
end


rethinking = "
      mean   sd  5.5% 94.5% n_eff Rhat
bp    0.84 0.26  0.43  1.26  2271    1
bpC  -0.13 0.29 -0.59  0.34  2949    1

a[1] -0.74 0.27 -1.16 -0.31  3310    1
a[2] 10.88 5.20  4.57 20.73  1634    1
a[3] -1.05 0.28 -1.52 -0.59  4206    1
a[4] -1.05 0.28 -1.50 -0.60  4133    1
a[5] -0.75 0.27 -1.18 -0.32  4049    1
a[6]  0.22 0.27 -0.22  0.65  3877    1
a[7]  1.81 0.39  1.22  2.48  3807    1
";


if success(rc10_4s)
	
	chns = read_samples(m10_4s; output_format=:mcmcchains, include_internals=true)

	chn10_4s = set_section(chns, 
		Dict(
		  :parameters => ["bp", "bpC"],
		  :pooled => ["a.$i" for i in 1:7],
		  :internals => ["lp__", "accept_stat__", "stepsize__", "treedepth__", "n_leapfrog__",
			"divergent__", "energy__"]
		)
	)

	# Output will go to terminal.
	
	
	
	Text(sprint(show, "text/plain", chn10_4s))
end

Text(sprint(show, "text/plain", Chains(chn10_4s, [:pooled])))

Text(sprint(show, "text/plain", Chains(chn10_4s, [:internals])))

