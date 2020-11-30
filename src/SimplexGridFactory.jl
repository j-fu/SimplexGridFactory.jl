module SimplexGridFactory
using ExtendableGrids
using Triangulate
using TetGen
using DocStringExtensions
using ElasticArrays

include("triangle.jl")
export triangulateio


include("tetgen.jl")
export triangulateio


include("simplexgridbuilder.jl")
export SimplexGridBuilder
export triangleflags,flags!,flags, appendflags!
export unsuitable!
export point!,facet!, cellregion!, hole!
export simplexgrid

include("plot.jl")


end # module
