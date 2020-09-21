#= 

# 202: Locally refined square using GridBuilder
([source code](SOURCE_URL))

=#

module Example202_SquareLocalRef
using SimplexGridFactory
using ExtendableGrids

function main(;plotter=nothing)
    
    builder=SimplexGridBuilder(dim_space=2)
    appendflags!(builder,"u")
    p1=point!(builder,0,0)
    p2=point!(builder,1,0)
    p3=point!(builder,1,1)
    p4=point!(builder,0,1)
    facet!(builder,p1,p2,region=1)
    facet!(builder,p2,p3,region=2)
    facet!(builder,p3,p4,region=3)
    facet!(builder,p4,p1,region=4)
    
    cellregion!(builder,0.5,0.5,region=1,volume=0.01)

    function unsuitable(x1,y1,x2,y2,x3,y3, area)
        bary_x=x1+x2+x3
        bary_y=y2+y2+y3
        if area > 0.001*bary_x
            return 1
        else
            return 0
        end
    end
    unsuitable!(builder, unsuitable)

    grid=simplexgrid(builder)
    @show grid

    
    plot(grid,Plotter=plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(2359, 4128, 588)
end
end
