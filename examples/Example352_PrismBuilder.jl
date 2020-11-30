#
# # 352: Prism with SimplexGridBuilder
# ([source code](SOURCE_URL))
#

module Example352_PrismBuilder
using ExtendableGrids
using SimplexGridFactory


function main(;plotter=nothing,vol=2)

    builder=SimplexGridBuilder(dim_space=3)

    p1=point!(builder,0, 0, 0)
    p2=point!(builder,1, 0, 0)
    p3=point!(builder,0, 1, 0)     
    p4=point!(builder,0, 0, 1) 
    p5=point!(builder,1, 0, 1) 
    p6=point!(builder,0, 1, 1)


                     bfaces=[[1,2,3],  
                             [4,5,6],  
                             [1,2,5,4],
                             [2,3,6,5],
                             [3,1,4,6]],
    
    
    
    
    facet!(builder,p1, p2, p3 )
    facet!(builder,p4, p5, p6 )
    facet!(builder,p1, p2, p5, p4 )
    facet!(builder,p2, p3, p6, p5 )
    facet!(builder,p3, p1, p4, p6 )
    
    cellregion!(builder,0.25,0.25,0.5,region=1,volume=vol)
    flags!(builder,"pAQa")
    grid=simplexgrid(builder)


    ExtendableGrids.plot(grid,Plotter=plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(6,3,8)
end
end
