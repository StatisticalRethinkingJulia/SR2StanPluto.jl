## This file contains some ideas to work on for SR v4.x.y

1. Currently `precis()` is a functions which dispalys its result. This will change such that the output of precis becomes a DataFrame and e.g. displayed with `HTMLTable()` in Pluto.

2. The big picture will be mapped out, e.g. what are the main functione SR adds, like `plot_models()`, particularly for hierachical models.

3. Some of these ideas might affect StanJulia packages. e.g. what already happened for StanQuap.jl and making a NamedTuple the default option for the return value of read_samples().

4. ...