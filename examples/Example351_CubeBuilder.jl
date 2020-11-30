#
# # 351: Cube with SimplexGridBuilder
# ([source code](SOURCE_URL))
#

module Example351_CubeBuilder
using ExtendableGrids
using SimplexGridFactory


function main(;plotter=nothing,vol=1)

    builder=SimplexGridBuilder(dim_space=3)
    
    p1=point!(builder,0, 0, 0)
    p2=point!(builder,1, 0, 0)
    p3=point!(builder,1, 1, 0) 
    p4=point!(builder,0, 1, 0)     
    p5=point!(builder,0, 0, 1) 
    p6=point!(builder,1, 0, 1) 
    p7=point!(builder,1, 1, 1) 
    p8=point!(builder,0, 1, 1)

    
    facet!(builder,p1, p2, p3, p4 )
    facet!(builder,p5, p6, p7, p8 )
    facet!(builder,p1, p2, p6, p5 )
    facet!(builder,p2, p3, p7, p6 )
    facet!(builder,p3, p4, p8, p7 )
    facet!(builder,p4, p1, p5, p8 )
    
    cellregion!(builder,0.5,0.5,0.5,region=1,volume=vol)
    grid=simplexgrid(builder)
    ExtendableGrids.plot(grid,Plotter=plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(8,6,12)
end
end
