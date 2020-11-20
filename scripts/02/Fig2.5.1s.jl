
using Markdown
using InteractiveUtils

macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StatisticalRethinking
	using PlutoUI
end

md"## Fig 2.5.1s"

md"###### This notebook demonstrates simple PlutoUI interactivity. This clip is only intended to generate part of Fig 2.5 using a PlutoUI slider. It is not intended to show how to use Stan (yet)! "

md"##### The Stan language model:"

stan2_0 = "
// Inferring a rate
data {
  int n;
  int k;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  // Prior distribution for θ
  theta ~ uniform(0, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

md"##### Create a SampleModel object and compile the Stan language program."

m2_0s = SampleModel("m2.0s", stan2_0);

md"#### 2. Generate observed data, sample and display."

md"##### Slider variable `n` can go from 1:9"

@bind n Slider(1:18, default=9)

begin
	k = [1,0,1,1,1,0,1,0,1,1,0,1,1,1,0,1,0,1][1:n]
  	m2_0_data = Dict("n" => n, "k" => sum(k[1:n]));
	rc2_0s = stan_sample(m2_0s, data=m2_0_data)
	if success(rc2_0s)
		post2_0s_df = read_samples(m2_0s; output_format=:dataframe)
		Text(precis(post2_0s_df; io=String))
	end
end

md"#### 6. Show the posterior."

begin
  plot(xlims=(0.0, 1.0), ylims=(0.0, 4.0), leg=false)
  hline!([1.0], line=(:dash))
  density!(post2_0s_df.theta, line=(:dash))
 end

md"## End of Fig2.5.1s.jl"

