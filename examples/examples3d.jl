#
# 3D Tetrahedralizations
# =================
#
# These examples can be loaded into Julia (Revise.jl recommended)
#
# These examples retur an ExtendableGrid with default simplex grid data.
#
# The control flags for [TetGen](https://github.com/JuliaGeometry/TetGen.jl)
# are created based on default options
# provided by this module which try to ensure "good" grids for
# FEM and FVM computations. These are documented in [`default_options`](@ref)
# Occasional [`options!`](@ref) statements in the examples overwrite these defaults.
#
# ## Domain triangulation
# Here we just describe a domain as a polygon and
# mesh it.
# This test code is released under the license conditions of
# TetGen.jl
#

using SimplexGridFactory
using ExtendableGrids
using LinearAlgebra
using TetGen


function tetrahedralization_of_cube()
    
    builder=SimplexGridBuilder(Generator=TetGen)

    p1=point!(builder,0,0,0)
    p2=point!(builder,1,0,0)
    p3=point!(builder,1,1,0)
    p4=point!(builder,0,1,0)
    p5=point!(builder,0,0,1)
    p6=point!(builder,1,0,1)
    p7=point!(builder,1,1,1)
    p8=point!(builder,0,1,1)

    facetregion!(builder,1)
    facet!(builder,p1 ,p2 ,p3 ,p4)  
    facetregion!(builder,2)
    facet!(builder,p5 ,p6 ,p7 ,p8)  
    facetregion!(builder,3)
    facet!(builder,p1 ,p2 ,p6 ,p5)  
    facetregion!(builder,4)
    facet!(builder,p2 ,p3 ,p7 ,p6)  
    facetregion!(builder,5)
    facet!(builder,p3 ,p4 ,p8 ,p7)  
    facetregion!(builder,6)
    facet!(builder,p4 ,p1 ,p5 ,p8)

    simplexgrid(builder,maxvolume=0.001)
end
# ![](tetrahedralization_of_cube.svg)

# ## Cube based on primitves
#
# We can also use predefined primitives to combine geometries
function tet_cube_with_primitives()
    
    builder=SimplexGridBuilder(Generator=TetGen)
    facetregion!(builder,1)
    cellregion!(builder,1)
    maxvolume!(builder,0.1)
    regionpoint!(builder,(0.5,0.5,0.5))
    rect3d!(builder,(0,0,0), (10,10,10))

    facetregion!(builder, 2)
    cellregion!(builder,2)
    maxvolume!(builder,0.05)
    regionpoint!(builder,(4.5,4.5,4.5))
    rect3d!(builder,(3,3,3), (5,5,6))


    facetregion!(builder, 3)
    cellregion!(builder,3)
    maxvolume!(builder,0.025)
    regionpoint!(builder,(7,7,5))
    sphere!(builder,(7,7,5),2,nref=3)

    facetregion!(builder, 4)
    holepoint!(builder, (2,7,5))
    sphere!(builder,(2,7,5),1.5,nref=3)
    
    simplexgrid(builder)
end

# ![](tet_cube_with_primitives.svg)
