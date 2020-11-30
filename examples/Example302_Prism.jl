#
# # 302: Prism
# ([source code](SOURCE_URL))
#

module Example302_Prism
using ExtendableGrids
using SimplexGridFactory


function main(;plotter=nothing,vol=2)
 
    grid=simplexgrid(points=[0 0 0;  
                             1 0 0;  
                             0 1 0;  
                             0 0 1;  
                             1 0 1;  
                             0 1 1]', 
                     
                     bfaces=[[1,2,3],  
                             [4,5,6],  
                             [1,2,5,4],
                             [2,3,6,5],
                             [3,1,4,6]],

                     regionpoints=[0.25 0.25 0.25;],
                     regionvolumes=[vol],
                     regionnumbers=[1],
                     bfaceregions=ones(5),
                     flags="pAQa"
                     )
    ExtendableGrids.plot(grid,Plotter=plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(6,3,8)
end
end
