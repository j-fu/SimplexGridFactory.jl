````@eval
using Markdown
Markdown.parse("""
$(read("../../README.md",String))
""")
````
## API Documentation

### Mesh generator interface

```@autodocs
Modules = [SimplexGridFactory]
Pages = ["triangle.jl"]
```

### SimplexGridBuilder

```@autodocs
Modules = [SimplexGridFactory]
Pages = ["simplexgridbuilder.jl","plot.jl"]
```
