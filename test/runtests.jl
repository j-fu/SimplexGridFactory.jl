#
# This test code is released under the license conditions of
# TetGen.jl and Triangulate.jl
#
using Test
using SimplexGridFactory
using ExtendableGrids
using GridVisualize
using Triangulate
using TetGen
using LinearAlgebra

# Generated point numbers depend on floating point operations,
# so we don't insist in exact matches
testgrid(grid::ExtendableGrid,testdata)= all(isapprox.((num_nodes(grid),num_cells(grid), num_bfaces(grid)),testdata, rtol=0.1))
testgrid(builder::SimplexGridBuilder,testdata)=testgrid( simplexgrid(builder),testdata)


@testset " Basic triangulation 2d" begin
    function test_ctriangulateio()
        nodes=Matrix{Cdouble}([1.0 0.0 ; 0.0 1.0 ; -1.0 0.0 ; 0.0 -1.0]')
        faces=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1 ]')
        faceregions=Matrix{Cint}([1 2 3 4]')
        regionpoints=Matrix{Cdouble}([0.5 0.5 1 0.01;]')
        regionnumbers=[1]
        triin=Triangulate.CTriangulateIO()
        triout=Triangulate.CTriangulateIO()
        vorout=Triangulate.CTriangulateIO()
        triin.numberofpoints=Cint(size(nodes,2))
        triin.pointlist=pointer(nodes)
        triin.numberofsegments=size(faces,2)
        triin.segmentlist=pointer(faces)
        triin.segmentmarkerlist=pointer(faceregions)
        triin.numberofregions=size(regionpoints,2)
        triin.regionlist=pointer(regionpoints)
        
        Triangulate.triangulate("paAqQ",triin,triout,vorout)
        points = convert(Array{Float64,2}, Base.unsafe_wrap(Array, triout.pointlist, (2,Int(triout.numberofpoints)), own=true))
        cells  = convert(Array{Int32,2}, Base.unsafe_wrap(Array, triout.trianglelist, (2,Int(triout.numberoftriangles)), own=true))
        bfaces = convert(Array{Int32,2}, Base.unsafe_wrap(Array, triout.segmentlist, (2,Int(triout.numberofsegments)), own=true))
        cellregions=convert(Array{Float64,1}, Base.unsafe_wrap(Array, triout.triangleattributelist, (Int(triout.numberoftriangles)), own=true))
        bfaceregions=convert(Array{Int32,1}, Base.unsafe_wrap(Array, triout.segmentmarkerlist, (Int(triout.numberofsegments)), own=true))
        cellregions=Vector{Int32}(cellregions)
        
        grid=simplexgrid(points,cells,cellregions,bfaces,bfaceregions)
    end
    @test testgrid(test_ctriangulateio(),(177,319,33))
    
    function test_triangulateio()
        triin=Triangulate.TriangulateIO()
        triin.pointlist=Matrix{Float64}([1.0 0.0 ; 0.0 1.0 ; -1.0 0.0 ; 0.0 -1.0]')
        triin.segmentlist=Matrix{Int32}([1 2 ; 2 3 ; 3 4 ; 4 1 ]')
        triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4])
        triin.regionlist=Matrix{Float64}([0.5 0.5 1 0.01;]')
        grid=simplexgrid(SimplexGridFactory.TriangulateType,Triangulate,triin,flags="paAqQ")
    end
    @test testgrid(test_triangulateio(),(177,319,33))
    
end
@testset "        BinnedPointList" begin

    function testbinning(a)
        dim=size(a,1)
        n=size(a,2)
        idx=rand(1:n,n÷4)
        a1=a[:,idx]

        bpl=BinnedPointList(dim)
        for i=1:size(a,2)
            insert!(bpl,a[:,i])
        end
        
        for i=1:size(a1,2)
            ix=insert!(bpl,a1[:,i])
            if ix!=idx[i]
                return false
            end
        end
        true
    end
    function testbinning2()
        A = 50
        B = 100
        Z = 20
        d = 5        
        builder=SimplexGridBuilder(Generator=TetGen)
        p1=point!(builder,0,0,0)
        p2=point!(builder,B,0,0)
        p3=point!(builder,B,A,0)
        p4=point!(builder,B,A+d,0)
        p5=point!(builder,B,2*A+d,0)
        p6=point!(builder,0,2*A+d,0)
        p7=point!(builder,0,A+d,0)
        p8=point!(builder,0,A,0)
    end
    

    
    @test testbinning(rand(1,10))
    @test testbinning(rand(1,10000))
    @test testbinning(rand(2,10))
    @test testbinning(rand(2,10000))
    @test testbinning(rand(3,10))
    @test testbinning(rand(3,10000))

    @test testbinning2() == 8
end



function test_triunsuitable(x1,y1,x2,y2,x3,y3, area)
    refinement_center=[0.5,0.5]
    bary=[(x1+x2+x3)/3,(y2+y2+y3)/3]
    dist=norm(bary-refinement_center)
    if area > 0.01*dist
        return 1
    else
        return 0
    end
end

@testset "Simplexgrid (arrays 2d)" begin
    function test_simplesquare(;kwargs...)
        grid=simplexgrid(Triangulate,
                         points=[0 0 ; 0 1 ; 1 1 ; 1 0]',
                         bfaces=[1 2 ; 2 3 ; 3 4 ; 4 1 ]',
                         bfaceregions=[1, 2, 3, 4],
                         regionpoints=[0.5 0.5;]',
                         regionnumbers=[1],
                         regionvolumes=[0.01];kwargs...)
    end
    
    @test testgrid(test_simplesquare(),(89, 144, 32))
    @test testgrid(test_simplesquare(flags="pAaqQD"),(89, 144, 32))
    @test testgrid(test_simplesquare(maxvolume=0.05),(24, 30, 16))
    @test testgrid(test_simplesquare(quality=false),(88, 142, 32))
    @test testgrid(test_simplesquare(minangle=30),(91, 148, 32))
    
    
    @test testgrid(test_simplesquare(unsuitable=test_triunsuitable),(299, 550, 46))
end

@testset "  SimplexGridBuilder 2d" begin
    
    function test_buildersquare(;kwargs...)
        
        builder=SimplexGridBuilder(Generator=Triangulate)
        cellregion!(builder,1)
        maxvolume!(builder,0.01)
        regionpoint!(builder,0.5,0.5)
        
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
        
        grid=simplexgrid(builder;kwargs...)
    end
    @test testgrid(test_buildersquare(minangle=30),(91, 148, 32))

    function test_buildersquare1(;kwargs...)
        
        builder=SimplexGridBuilder(Generator=Triangulate)
        cellregion!(builder,1)
        maxvolume!(builder,0.01)
        regionpoint!(builder,0.5,0.5)
        
        p1=point!(builder,0,0)
        p2=point!(builder,1,0)
        p3=point!(builder,1,1)
        p4=point!(builder,0,1)
        
        options!(builder, unsuitable=test_triunsuitable)
        
        facetregion!(builder,1)
        facet!(builder,p1,p2)
        facetregion!(builder,2)
        facet!(builder,p2,p3)
        facetregion!(builder,3)
        facet!(builder,p3,p4)
        facetregion!(builder,4)
        facet!(builder,p4,p1)
        
        grid=simplexgrid(builder;kwargs...)
    end
    @test testgrid(test_buildersquare1(),(299, 550, 46))

end
    
function test_tetunsuitable(pa,pb,pc,pd)
    vol=det(hcat(pb-pa,pc-pa,pd-pa))/6
    center=0.25*(pa+pb+pc+pd)-[0.5,0.5,0.5]
    vol> 0.05*norm(center)^2.5
end


@testset "Simplexgrid (arrays 3d)" begin
    
    function test_simplecube(;kwargs...)
        
        grid=simplexgrid(TetGen,
                         points=[0 0 0; 
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
                         bfaceregions=[i for i=1:6],
                         regionpoints=[0.5 0.5 0.5]',
                         regionnumbers=[1],
                         regionvolumes=[0.01];
                         kwargs...
                         )
    end
    
    @test testgrid(test_simplecube(),(109, 286, 198))
    @test testgrid(test_simplecube(flags="pAaqQD"),(109, 286, 198))
    @test testgrid(test_simplecube(maxvolume=0.05),(50, 68, 96))
    
    @test testgrid(test_simplecube(unsuitable=test_tetunsuitable),(223, 971, 198))
    
end

@testset "  SimplexGridBuilder 3d" begin

    function test_buildercube0(;kwargs...)
        
        builder=SimplexGridBuilder(Generator=TetGen)
        cellregion!(builder,1)
        maxvolume!(builder,0.01)
        regionpoint!(builder,0.5,0.5,0.5)
        
        
        p1=point!(builder,0,0,0)
        p2=point!(builder,1, 0, 0)
        p3=point!(builder,1, 1, 0)
        p4=point!(builder,0, 1, 0)
        p5=point!(builder,0, 0, 1)
        p6=point!(builder,1, 0, 1)
        p7=point!(builder,1, 1, 1)
        p8=point!(builder,0 ,1, 1)
        
        
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
        builder
    end
        
    function test_buildercube(;kwargs...)
        builder=test_buildercube0(;kwargs...)
        grid=simplexgrid(builder;kwargs...)
        
    end

    
    @test SimplexGridFactory.tetgenio(test_buildercube0()) isa RawTetGenIO
    @test testgrid(test_buildercube(unsuitable=test_tetunsuitable),(223, 971, 198))


    
end


    
@testset "          examples2d.jl" begin    
    include("../examples/examples2d.jl")
    @test SimplexGridFactory.triangulateio(triangulation_of_domain()) isa TriangulateIO
    @test testgrid(triangulation_of_domain(),(10,8,10))
    @test testgrid(nicer_triangulation_of_domain(),(187,306,66))
    @test testgrid(triangulation_of_domain_with_subregions(),(146,243,55))
    @test testgrid(square_localref(),(299, 550, 46))
    @test testgrid(direct_square(),(89, 144, 32))
    @test testgrid(swiss_cheese_2d(),(1475, 2526,496))
end;

@testset "          examples3d.jl" begin    
    include("../examples/examples3d.jl")
    @test testgrid(tetrahedralization_of_cube(),(718,2456,1094))
    @test testgrid(tet_cube_with_primitives(), (5658,27324,6888))
end;

if !Sys.iswindows()
@testset "    PlutoGridFactory.jl" begin    
    @test testgrid(include("../examples/PlutoGridFactory.jl"),(272,514,40))
end
end

@testset "             primitives" begin
    function prim2d()
        builder=SimplexGridBuilder(Generator=Triangulate)
        rect2d!(builder,[-1,-1], [1,1])
        circle!(builder, [0,0], 0.25)
        simplexgrid(builder,maxvolume=0.05)
    end
    function prim2d_lineto()
        b = SimplexGridBuilder(Generator=Triangulate)
        p = moveto!(b,[0,0])
        facetregion!(b,1);  lineto!(b,[1,0])
        facetregion!(b,2);  lineto!(b,[1,1])
        facetregion!(b,3);  lineto!(b,[0,1])
        facetregion!(b,4);  lineto!(b,p)
        simplexgrid(b,maxvolume=0.05)
    end
    function prim3d()
        builder=SimplexGridBuilder(Generator=TetGen)
        rect3d!(builder,[-1,-1,-1], [1,1,1])
        sphere!(builder, [0,0,0], 0.25)
        simplexgrid(builder,maxvolume=0.05)
    end
    function prim3d_moveto()
        b = SimplexGridBuilder(Generator=TetGen)

        c1=[0,0,0]
        c2=[1,0,0]
        c3=[1,1,0]
        c4=[0,1,0]
        
        c5=[0,0,1]
        c6=[1,0,1]
        c7=[1,1,1]
        c8=[0,1,1]
        
        facetregion!(b,1);
        p1=moveto!(b,c1)
        p2=moveto!(b,c2)
        p3=moveto!(b,c3)
        p4=moveto!(b,c4)
        polyfacet!(b,[p1,p2,p3,p4])
        
        facetregion!(b,2);
        p1=moveto!(b,c5)
        p2=moveto!(b,c6)
        p3=moveto!(b,c7)
        p4=moveto!(b,c8)
        polyfacet!(b,[p1,p2,p3,p4])
        
        facetregion!(b,3);
        p1=moveto!(b,c1)
        p2=moveto!(b,c2)
        p3=moveto!(b,c6)
        p4=moveto!(b,c5)
        polyfacet!(b,[p1,p2,p3,p4])
        
        facetregion!(b,4);
        p1=moveto!(b,c2)
        p2=moveto!(b,c3)
        p3=moveto!(b,c7)
        p4=moveto!(b,c6)
        polyfacet!(b,[p1,p2,p3,p4])
        
        facetregion!(b,5);
        p1=moveto!(b,c3)
        p2=moveto!(b,c4)
        p3=moveto!(b,c8)
        p4=moveto!(b,c7)
        polyfacet!(b,[p1,p2,p3,p4])
        
        facetregion!(b,6);
        p1=moveto!(b,c1)
        p2=moveto!(b,c4)
        p3=moveto!(b,c8)
        p4=moveto!(b,c5)
        polyfacet!(b,[p1,p2,p3,p4])
        
        cellregion!(b,1)
        maxvolume!(b,0.05)
        regionpoint!(b, (c1+c7)/2 )
        
        simplexgrid(b,maxvolume=0.005)        
    end
    @test testgrid(prim2d(), (106,179,50))
    @test testgrid(prim2d_lineto(), (24,30,16))
    @test testgrid(prim3d(), (423,1787,822))
    @test testgrid(prim3d_moveto(), (207,564,368))
end
