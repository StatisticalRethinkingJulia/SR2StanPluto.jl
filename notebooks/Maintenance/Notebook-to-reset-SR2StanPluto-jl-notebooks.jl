### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 28f7bd2f-3208-4c61-ad19-63b11dd56d30
using Pkg

# ╔═╡ 2846bc48-7972-49bc-8233-80c7ea3326e6
begin
	using DataFrames
    using RegressionAndOtherStories: reset_selected_notebooks_in_notebooks_df!
end

# ╔═╡ 70d5fba2-aec1-444e-a913-39947747a355
#Pkg.activate(expanduser("~/.julia/dev/SR2StanPluto"))

# ╔═╡ 970efecf-9ae7-4771-bff0-089202b1ff1e
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 3500px;
    	padding-left: max(5px, 5%);
    	padding-right: max(5px, 20%);
	}
</style>
"""

# ╔═╡ d98a3a0a-947e-11ed-13a2-61b5b69b4df5
notebook_files = [
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.1-The problem with parameters/clip-07-01-04s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.1-The problem with parameters/clip-07-05-06s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.1-The problem with parameters/clip-07-07-10s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.1-The problem with parameters/clip-07-11s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-12s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-13-14.1s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-13-14.2s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-15.1s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-15.2s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-16-18.1s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.2-Entropy and accuracy/clip-07-16-18.2s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.4-Predicting predictive accuracy/clip-07-19-24s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.5-Model comparison/clip-07-25-31s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.5-Model comparison/clip-07-32-34s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/07/7.5-Model comparison/clip-07-35s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/08/8.0-Fig8.2s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/08/8.1-Building an interaction.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/08/8.2-Symmetry of interactions.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/08/8.3-Continuous interactions.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/10/clip-10-01-04s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/10/clip-10-05-14s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/10/Fig-10.2s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/10/Fig-10.7s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/11/clip-11-01-08s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/11/clip-11-09-14s.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR1/11/clip-11-15-24s.jl",

    "~/.julia/dev/SR2StanPluto/notebooks/SR2/00-Preface.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/02-Small Worlds and Large World.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/03-Sampling the imaginary.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/04.1-Why normal distributions are normal.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/04.2-A language for describing models.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/04.3-Gaussian model of height.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/04.4-Linear prediction.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/04.5-Curves from lines.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/05.1-Spurious associations.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/05.2-Masked relationships.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/05.3-Categorical variables.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/06.1-Multicollinearity.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/06.2-Post-treatment bias.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/06.3-Collider bias.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/06.4-Confronting confounding.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/09.1-Good King Markov.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/09.2-Metropolis algorithm.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/09.3-Hamiltonian Monte Carlo.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/09.4-Easy HMC.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR2/09.5-Care of Markov chains.jl",

    "~/.julia/dev/SR2StanPluto/notebooks/SR3/Adjustment explorations.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR3/GES explorations.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/SR3/Lecture_3_4.jl",
	
    "~/.julia/dev/SR2StanPluto/notebooks/CausalInference/PC and FCI Algorithms: Basic example.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/CausalInference/PC Algorithm: Example with real data.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/CausalInference/PC Algorithm: Further example.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/CausalInference/PC Algorithm: How it works.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/CausalInference/PC Algorithm: Reasoning about experiments.jl",
	
	"~/.julia/dev/SR2StanPluto/notebooks/Maintenance/Notebook-to-reset-SR2StanPluto-jl-notebooks.jl"
];

# ╔═╡ 0f10a758-e442-4cd8-88bc-d82d8de97ede
begin
    files = AbstractString[]
    for i in 1:length(notebook_files)
        append!(files, [split(notebook_files[i], "/")[end]])
    end
    notebooks_df = DataFrame(
        name = files,
        reset = repeat([false], length(notebook_files)),
        done = repeat([false], length(notebook_files)),
        file = notebook_files,
    )
end

# ╔═╡ a4207232-61eb-4da7-8629-1bcc670ab524
notebooks_df.reset .= true;

# ╔═╡ 722d4847-2458-4b23-b6a0-d1c321710a2a
notebooks_df

# ╔═╡ 9d94bebb-fc41-482f-8759-cdf224ec71fb
reset_selected_notebooks_in_notebooks_df!(notebooks_df; reset_activate=true, set_activate=false)

# ╔═╡ 88720478-7f64-4852-8683-6be50793666a
notebooks_df

# ╔═╡ Cell order:
# ╠═28f7bd2f-3208-4c61-ad19-63b11dd56d30
# ╠═70d5fba2-aec1-444e-a913-39947747a355
# ╠═2846bc48-7972-49bc-8233-80c7ea3326e6
# ╠═970efecf-9ae7-4771-bff0-089202b1ff1e
# ╠═d98a3a0a-947e-11ed-13a2-61b5b69b4df5
# ╠═0f10a758-e442-4cd8-88bc-d82d8de97ede
# ╠═a4207232-61eb-4da7-8629-1bcc670ab524
# ╠═722d4847-2458-4b23-b6a0-d1c321710a2a
# ╠═9d94bebb-fc41-482f-8759-cdf224ec71fb
# ╠═88720478-7f64-4852-8683-6be50793666a
