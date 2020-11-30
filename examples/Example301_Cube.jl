#
# # 301: Cube
# ([source code](SOURCE_URL))
#

module Example301_Cube
using ExtendableGrids
using SimplexGridFactory


function main(;plotter=nothing,vol=1)

    grid=simplexgrid(points=[0 0 0; 
                             1 0 0; 
                             1 1 0; 
                             0 1 0; 
                             0 0 1; 
                             1 0 1; 
                             1 1 1; 
                             0 1 1]',
                     
                     bfaces=[1 2 3 4;  
                             5 6 7 8;  
                             1 2 6 5;  
                             2 3 7 6;  
                             3 4 8 7;  
                             4 1 5 8]',
                     bfaceregions=ones(6),
                     flags="pAQqa$(vol)"
                     )
    ExtendableGrids.plot(grid,Plotter=plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end
function test()
    main()==(8,6,12)
end
end
