module SimplexGridFactory
using ExtendableGrids
using Triangulate
using DocStringExtensions
using ElasticArrays

include("triangle.jl")
include("simplexgridbuilder.jl")
include("plot.jl")


export SimplexGridBuilder
# todo for 0.2  mehods have been pirated from ExtendableGrids, remove this
# and export

end # module
