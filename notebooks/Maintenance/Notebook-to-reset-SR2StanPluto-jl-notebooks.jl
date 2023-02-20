### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 28f7bd2f-3208-4c61-ad19-63b11dd56d30
using Pkg

# ╔═╡ 2846bc48-7972-49bc-8233-80c7ea3326e6
begin
	using DataFrames
    using RegressionAndOtherStories: reset_selected_notebooks_in_notebooks_df!
end

# ╔═╡ 970efecf-9ae7-4771-bff0-089202b1ff1e
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 0%);
    	padding-right: max(160px, 30%);
	}
</style>
"""

# ╔═╡ d98a3a0a-947e-11ed-13a2-61b5b69b4df5
notebook_files = [
    "~/.julia/dev/SR2StanPluto/notebooks/00-Preface.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/02-Small Worlds and Large World.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/03-Sampling the imaginary.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/04.1-Why normal distributions are normal.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/04.2-A language for describing models.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/04.3-Gaussian model of height.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/04.4-Linear prediction.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/04.5-Curves from lines.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/05.1-Spurious associations.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/05.2-Masked relationships.jl",
    "~/.julia/dev/SR2StanPluto/notebooks/05.3-Categorical variables.jl",
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
reset_selected_notebooks_in_notebooks_df!(notebooks_df)

# ╔═╡ 88720478-7f64-4852-8683-6be50793666a
notebooks_df

# ╔═╡ Cell order:
# ╠═28f7bd2f-3208-4c61-ad19-63b11dd56d30
# ╠═2846bc48-7972-49bc-8233-80c7ea3326e6
# ╠═970efecf-9ae7-4771-bff0-089202b1ff1e
# ╠═d98a3a0a-947e-11ed-13a2-61b5b69b4df5
# ╠═0f10a758-e442-4cd8-88bc-d82d8de97ede
# ╠═a4207232-61eb-4da7-8629-1bcc670ab524
# ╠═722d4847-2458-4b23-b6a0-d1c321710a2a
# ╠═9d94bebb-fc41-482f-8759-cdf224ec71fb
# ╠═88720478-7f64-4852-8683-6be50793666a
