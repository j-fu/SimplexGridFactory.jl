[![linux-macos-windows](https://github.com/j-fu/SimplexGridFactory.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/j-fu/SimplexGridFactory.jl/actions/workflows/ci.yml)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://j-fu.github.io/SimplexGridFactory.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://j-fu.github.io/SimplexGridFactory.jl/dev)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


SimplexGridFactory
==================

Provides `SimplexGridBuilder`, a convenience  interface to rhe triangle (via  [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl)) and
TetGen (via [TetGen.jl](https://github.com/JuliaGeometry/TetGen.jl)) mesh generators.  Code using it  needs to pass the `Triangulate` resp.
the   `TetGen`   module   as   parameter  to   the   constructor of `SimplexGridBuilder`  and thus  needs to
adhere to  their respective license conditions. This package itself is MIT licensed.


## Recent changes
Please look up the list of recent [changes](https://j-fu.github.io/SimplexGridFactory.jl/stable/changes)
