#
# Grid data access
# ================
#
# You may want to use the this package to obtain grid data for your application.
# The [ExtendableGrids](https://github.com/j-fu/ExtendableGrids.jl) package provides a lightweight grid data structure which
# in its core is a `Dict{Type,Any}` and the possibility to [dispatch the return type on the key](https://j-fu.github.io/ExtendableGrids.jl/stable/tdict/).
#
function extract_2d()
    builder=SimplexGridBuilder(Generator=Triangulate)
    
    p1=point!(builder,0,0)
    p2=point!(builder,1,0)
    p3=point!(builder,1,1)
    p4=point!(builder,0,1)

    facetregion!(builder,1)
    facet!(builder,p1,p2)
    facetregion!(builder,2)
    facet!(builder,p2,p3)
    facetregion!(builder,3)
    facet!(builder,p3,p4)
    facetregion!(builder,4)
    facet!(builder,p4,p1)
    
    grid=simplexgrid(builder,maxvolume=0.25)

    @show grid[Coordinates]
    @show grid[CellNodes]
    @show grid[CellRegions]
    @show grid[BFaceNodes]
    @show grid[BFaceRegions]
    grid
end
# The output of this call is this:
# ```julia
# grid[Coordinates] = [0.0 1.0 1.0 0.0 0.5; 0.0 0.0 1.0 1.0 0.5]
# grid[CellNodes] = Int32[2 4 5 1; 3 1 3 2; 5 5 4 5]
# grid[CellRegions] = Int32[1, 1, 1, 1]
# grid[BFaceNodes] = Int32[2 3 4 1; 1 2 3 4]
# grid[BFaceRegions] = Int32[1, 2, 3, 4]
# ```
# Thus, the grid is described by five arrays:
# - `2 x npoints` coordinates,
# - `3 x ntriangles` connectivity,
# - `ntriangles` region markers,
# - `2 x nfacets` boundary faces,
# - `nfacets` boundary face markers.
