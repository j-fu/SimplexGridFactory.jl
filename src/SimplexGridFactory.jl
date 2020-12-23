module SimplexGridFactory
using ExtendableGrids
using Triangulate
using Printf
using TetGen
using DocStringExtensions
using ElasticArrays


include("options.jl")

include("simplexgridbuilder.jl")

include("simplexgrid.jl")

include("triangle.jl")

include("tetgen.jl")

include("plot.jl")

export SimplexGridBuilder
export triangleflags,flags!,flags, appendflags!
export point!,facet!, cellregion!, holepoint!,facetregion!,maxvolume!,regionpoint!,options!
export simplexgrid

end # module
