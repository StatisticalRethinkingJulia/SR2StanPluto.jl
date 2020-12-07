
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
	using StatisticalRethinking
	using PlutoUI
end

md"## Intro-pluto-10.jl"

@bind x Slider(1:20, default=3)

s1 = s2 = [sqrt(i) for i in 1:x]

md"<details><summary>CLICK ME</summary>
<p>


```julia
Text('hello world!')
```

</p>
</details>"





md"## End of intro-pluto-10.jl"

