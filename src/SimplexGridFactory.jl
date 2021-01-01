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


export SimplexGridBuilder
export triangleflags,flags!,flags, appendflags!
export point!,facet!, cellregion!, holepoint!,facetregion!,maxvolume!,regionpoint!,options!
export simplexgrid

include("primitives.jl")
export circle!,rect2d!,rect3d!,sphere!

include("plot.jl")

end # module
