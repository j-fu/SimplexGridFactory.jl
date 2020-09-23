module SimplexGridFactory
using ExtendableGrids
using Triangulate
using DocStringExtensions
using ElasticArrays

include("triangle.jl")
export triangulateio

include("simplexgridbuilder.jl")
export SimplexGridBuilder
export triangleflags,flags!,flags, appendflags!
export unsuitable!
export point!,facet!, cellregion!, hole!

include("plot.jl")


end # module
