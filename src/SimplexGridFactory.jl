module SimplexGridFactory

using Printf
using LinearAlgebra

using ExtendableGrids
using GridVisualize
using DocStringExtensions
using ElasticArrays

include("utils.jl")

include("options.jl")

include("binnedpointlist.jl")
export  BinnedPointList

include("simplexgridbuilder.jl")
export SimplexGridBuilder
export point!,facet!,polyfacet!, cellregion!, holepoint!,facetregion!,maxvolume!,regionpoint!,options!
export istriangulate,istetgen
export flags

include("simplexgrid.jl")
export simplexgrid

include("triangle.jl")

include("tetgen.jl")

export SimplexGridBuilder

include("primitives.jl")
export circle!,rect2d!,rect3d!,sphere!,bregions!,moveto!,lineto!

include("plot.jl")
export builderplot

end # module
