module SimplexGridFactory

using Printf
using LinearAlgebra

using ExtendableGrids
using GridVisualize
using DocStringExtensions
using ElasticArrays

include("utils.jl")

include("options.jl")
export triangleflags,flags!,flags, appendflags!

include("binnedpointlist.jl")
export  BinnedPointList

include("simplexgridbuilder.jl")
export SimplexGridBuilder
export point!,facet!, cellregion!, holepoint!,facetregion!,maxvolume!,regionpoint!,options!
export istriangulate,istetgen

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
