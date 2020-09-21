#= 

# 201: Square using SimplexGridBuilder
([source code](SOURCE_URL))

=#

module Example201_Square
using SimplexGridFactory
using ExtendableGrids

function main(;Plotter=nothing)
    
    builder=SimplexGridBuilder(dim_space=2)
    
    p1=point!(builder,0,0)
    p2=point!(builder,1,0)
    p3=point!(builder,1,1)
    p4=point!(builder,0,1)
    facet!(builder,p1,p2,region=1)
    facet!(builder,p2,p3,region=2)
    facet!(builder,p3,p4,region=3)
    facet!(builder,p4,p1,region=4)
    
    cellregion!(builder,0.5,0.5,region=1,volume=0.01)
    grid=simplexgrid(builder)
    @show grid
    
    plot(grid,Plotter=Plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(89,144,32)
end
end
