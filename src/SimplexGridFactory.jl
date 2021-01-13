module SimplexGridFactory

using Printf
using LinearAlgebra


using ExtendableGrids
using GridVisualize
using Triangulate
using TetGen
using DocStringExtensions
using ElasticArrays


include("options.jl")
export triangleflags,flags!,flags, appendflags!

include("binnedpointlist.jl")
export  BinnedPointList

include("simplexgridbuilder.jl")
export SimplexGridBuilder
export point!,facet!, cellregion!, holepoint!,facetregion!,maxvolume!,regionpoint!,options!

include("simplexgrid.jl")
export simplexgrid

include("triangle.jl")

include("tetgen.jl")

export SimplexGridBuilder

include("primitives.jl")
export circle!,rect2d!,rect3d!,sphere!

include("plot.jl")
export builderplot

end # module
