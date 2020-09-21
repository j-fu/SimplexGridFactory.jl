````@eval
using Markdown
Markdown.parse("""
$(read("../../README.md",String))
""")
````


```@autodocs
Modules = [SimplexGridFactory]
Pages = ["simplexgridbuilder.jl","triangle.jl","plot.jl"]
```
