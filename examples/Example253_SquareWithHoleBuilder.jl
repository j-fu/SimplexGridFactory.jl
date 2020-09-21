#= 

# 253: Square with hole via GridBuilder
([source code](SOURCE_URL))

=#

module Example253_SquareWithHoleBuilder
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


    h1=point!(builder,0.3, 0.3)
    h2=point!(builder,0.3, 0.7)
    h3=point!(builder,0.7, 0.7)
    h4=point!(builder,0.7, 0.3)

    facet!(builder,h1,h2,region=5)
    facet!(builder,h2,h3,region=5)
    facet!(builder,h3,h4,region=5)
    facet!(builder,h4,h1,region=5)

    hole!(builder, 0.5, 0.5)
    cellregion!(builder,0.25,0.25,region=1,volume=0.01)

    grid=simplexgrid(builder)
    
    plot(grid,Plotter=Plotter)
    (num_nodes(grid),num_cells(grid),num_bfaces(grid))
end

function test()
    main()==(93, 139, 47)
end
end
