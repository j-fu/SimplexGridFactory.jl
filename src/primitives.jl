"""
```
circle!(builder, center, radius; n=20)
```

Add points and facets approximating a circle.
"""
function circle!(builder::SimplexGridBuilder, center, radius; n=20)
    points=[point!(builder, center[1]+radius*sin(t),center[2]+radius*cos(t)) for t in range(0,2π,length=n)]
    for i=1:n-1
        facet!(builder,points[i],points[i+1])
    end
    facet!(builder,points[end],points[1])
    builder
end


"""
```
bregions!(builder::SimplexGridBuilder,grid, pairs...)
```
Add  boundary facets of `grid`  with region numbers mentioned as first element in `pairs`
with region number mentioned as second element of `pairs` to the geometry description. 


Example:

```
bregions!(builde,grid, 1=>2, 3=>5)
```
"""
bregions!(builder::SimplexGridBuilder,grid, pairs...)=bregions!(builder,grid,first.(pairs); facetregions=last.(pairs))


"""
```
bregions!(builder::SimplexGridBuilder,grid,regionlist;facetregions=nothing)
```
Add all boundary facets of `grid` with region numbers in region list  to geometry description.
The optional parameter `facetregions` allows to overwrite the numbers in `regionlist`.

"""
function bregions!(builder::SimplexGridBuilder,grid,regionlist;facetregions=nothing)
    save_facetregion=builder.current_facetregion
    if isnothing(facetregions)
        facetregions=fill(builder.current_facetregion,length(regionlist))
    end
    if isa(facetregions,Number)
        facetregions=fill(facetregions,length(regionlist))
    end
    coord=grid[Coordinates]
    bfnodes=grid[BFaceNodes]
    bfregions=grid[BFaceRegions]
    
    nfacets=0
    for ibface=1:size(bfnodes,2)
        ireg=findfirst(i->i==bfregions[ibface],regionlist)
        if ireg!=nothing
            if dim_space(builder)==2
                facetregion!(builder,facetregions[ireg])
                @views p1=point!(builder, coord[:,bfnodes[1,ibface]])
                @views p2=point!(builder, coord[:,bfnodes[2,ibface]])
                facet!(builder,p1,p2)
            else
                facetregion!(builder,facetregions[ireg])
                @views p1=point!(builder, coord[:,bfnodes[1,ibface]])
                @views p2=point!(builder, coord[:,bfnodes[2,ibface]])
                @views p3=point!(builder, coord[:,bfnodes[3,ibface]])
                facet!(builder,p1,p2,p3)
            end
            nfacets+=1
        end
    end
    @info "bregions!: added $nfacets facets to builder"
    facetregion!(builder,save_facetregion)
end


"""
```
rect2d!(builder, sw, ne; facetregions=nothing)
```

Add points and facets describing a rectangle via points describing its
south-west and north-east corners. On default, the corresponding facet
regions are deduced from the current facetregion. Alternatively, 
a 4-vector of facetregions can be passed.
"""
function rect2d!(builder::SimplexGridBuilder,PA,PB;facetregions=nothing, nx=1, ny=1)
    save_facetregion=builder.current_facetregion
    if isnothing(facetregions)
        facetregions=fill(builder.current_facetregion,4)
    end
    if isa(facetregions,Number)
        facetregions=fill(facetregions,4)
    end
    p00=point!(builder,PA[1],PA[2])
    p10=point!(builder,PB[1],PA[2])
    p11=point!(builder,PB[1],PB[2])
    p01=point!(builder,PA[1],PB[2])
    
    x=range(PA[1],PB[1],length=nx+1)
    for i=1:nx
        facetregion!(builder,facetregions[1])
        p1=point!(builder,x[i],PA[2])
        p2=point!(builder,x[i+1],PA[2])
        facet!(builder,p1,p2)

        facetregion!(builder,facetregions[3])
        p1=point!(builder,x[i],PB[2])
        p2=point!(builder,x[i+1],PB[2])
        facet!(builder,p1,p2)
    end
    
    y=range(PA[2],PB[2],length=ny+1)
    for i=1:ny
        facetregion!(builder,facetregions[2])
        p1=point!(builder,PB[1],y[i])
        p2=point!(builder,PB[1],y[i+1])
        facet!(builder,p1,p2)

        facetregion!(builder,facetregions[4])
        p1=point!(builder,PA[1],y[i])
        p2=point!(builder,PA[1],y[i+1])
        facet!(builder,p1,p2)
    end

    facetregion!(builder,save_facetregion)
    builder
end


"""
```
rect3d!(builder, bsw, tne; facetregions=nothing)
```

Add points and facets describing a qudrilateral via points describing its
bottom south-west and top north-east corners. On default, the corresponding facet
regions are deduced from the current facetregion. Alternatively, 
a 6-vector of facetregions can be passed (in the sequence s-e-n-w-b-t)
"""
function rect3d!(builder::SimplexGridBuilder,PA,PB;facetregions=nothing)
    save_facetregion=builder.current_facetregion
    if isnothing(facetregions)
        facetregions=fill(builder.current_facetregion,6)
    end
    if isa(facetregions,Number)
        facetregions=fill(facetregions,6)
    end
    p1=point!(builder,PA[1],PA[2],PA[3])
    p2=point!(builder,PB[1],PA[2],PA[3])
    p3=point!(builder,PB[1],PB[2],PA[3])
    p4=point!(builder,PA[1],PB[2],PA[3])
    p5=point!(builder,PA[1],PA[2],PB[3])
    p6=point!(builder,PB[1],PA[2],PB[3])
    p7=point!(builder,PB[1],PB[2],PB[3])
    p8=point!(builder,PA[1],PB[2],PB[3])

    facetregion!(builder,facetregions[1])
    facet!(builder,p1 ,p2 ,p3 ,p4)  
    facetregion!(builder,facetregions[2])
    facet!(builder,p5 ,p6 ,p7 ,p8)  
    facetregion!(builder,facetregions[3])
    facet!(builder,p1 ,p2 ,p6 ,p5)  
    facetregion!(builder,facetregions[4])
    facet!(builder,p2 ,p3 ,p7 ,p6)  
    facetregion!(builder,facetregions[5])
    facet!(builder,p3 ,p4 ,p8 ,p7)  
    facetregion!(builder,facetregions[6])
    facet!(builder,p4 ,p1 ,p5 ,p8)
    facetregion!(builder,save_facetregion)
    builder
end




function refine(coord,tri)
    # Short and trivial method, without creating edges,
    # and with doubling points (relying on binned point list
    # upon insertion into builder

    function pinsert(p,istop)
        append!(coord,p)
        return size(coord,2)
    end

    rscale(p)=@. p/sqrt(p[1]^2+p[2]^2+p[3]^2)
    
    newtri=ElasticArray{Cint}(undef,3,0)
    istop=size(coord,2)
    ntri=size(tri,2)
    @views for itri=1:ntri
        i1=tri[1,itri]
        i2=tri[2,itri]
        i3=tri[3,itri]
        p1=coord[:,i1]
        p2=coord[:,i2]
        p3=coord[:,i3]

        # new points inserted on the spere
        i12=pinsert(rscale((p1+p2)/2),istop)
        i13=pinsert(rscale((p1+p3)/2),istop)
        i23=pinsert(rscale((p2+p3)/2),istop)

        append!(newtri,(i1,i12,i13))
        append!(newtri,(i2,i12,i23))
        append!(newtri,(i3,i23,i13))
        append!(newtri,(i12,i13,i23))
    end
    coord,newtri
end


"""
```
sphere!(builder, center, radius; nref=3)
```

Add points and facets approximating a sphere. `nref` is a refinement level.
"""
function sphere!(builder::SimplexGridBuilder, center, radius; nref=3)
    # Initial octahedron
    q=1.0/sqrt(2)
    
    coord=ElasticArray([-q -q  0;
                        -q  q  0;
                        q  q  0;
                        q -q  0;
                        0   0 -1;
                        0   0  1]')

    tri=[1 2 5;
         2 3 5;
         3 4 5;
         4 1 5;
         1 2 6;
         2 3 6;
         3 4 6;
         4 1 6]'

    for iref=1:nref
        coord,tri=refine(coord,tri)
    end
    
    @views pts=[point!(builder,(radius*coord[:,i].+center)) for i=1:size(coord,2) ]

    for i=1:size(tri,2)
        facet!(builder, pts[tri[1,i]],pts[tri[2,i]],pts[tri[3,i]])
    end
    
    builder
end


"""
```
moveto!(builder, pt)
```

Move the (virtual) pen to the target point pt (2D, 3D).
pt is either an existing point index or a table of point coordinates.
In the latter case, the point is added.
It returns index of the target point.
"""
function moveto!(b::SimplexGridBuilder,pt)
    local p2,pt2            # index and coordinates of the target point
    if isa(pt,Array)        # the argument is a table of coordinates
      pt2 = pt
      p2  = insert!(b.pointlist, pt2 )
    elseif isa(pt,Integer)  # the argument is an existing point index
      p2  = pt 
    else
      error("moveto!(): no valid target point")
      return -1
    end
    b._savedpoint = p2      # save the point index to mark the pen position
    return p2
end


"""
```
lineto!(builder, pt)
```

Generate a line from the current pen position to the target point pt, s `moveto!()`, (2D, 3D).
pt is either an existing point index or a table of point coordinates.
In the latter case, the point is added.
It returns index of the target point.

# Example 2D: draw a square with different facetregion numbers
```
 p = moveto!(b,[0,0])
 facetregion!(b,1);  lineto!(b,[1,0])
 facetregion!(b,2);  lineto!(b,[1,1])
 facetregion!(b,3);  lineto!(b,[0,1])
 facetregion!(b,4);  lineto!(b,p)
```

# Example 3D: two planar facet with different facetregion numbers
```
 facetregion!(b,1);
 p1 = moveto!(b,[0,0,0])
 p2 = moveto!(b,[1,0,0])
 p3 = moveto!(b,[1,1,0])
 p4 = moveto!(b,[0,1,0])
 polyfacet!(b,[p1,p2,p3,p4])

 facetregion!(b,2);
 p1 = moveto!(b,[0,0,1])
 p2 = moveto!(b,[1,0,1])
 p3 = moveto!(b,[1,1,1])
 p4 = moveto!(b,[0,1,1])
 polyfacet!(b,[p1,p2,p3,p4])
```

"""
function lineto!(b::SimplexGridBuilder,pt)
    local p1 = size(b.pointlist.points,2)  # last index in table points
    if isa(b._savedpoint,Integer) && b._savedpoint>0 && b._savedpoint<p1 
      p1 = b._savedpoint
    end
    
    local p2,pt2                           # index and coordinates of the target point
    if isa(pt,Array)                       # the argument is a table of coordinates
      pt2 = pt
      p2  = insert!(b.pointlist,pt2 )
    elseif isa(pt,Integer)                 # the argument is an existing point index
      p2  = pt 
    else
      error("lineto!(): no valid target point") 
      return -1
    end
    
    if p1>0 
        polyfacet!(b,[p1,p2])
    end
    b._savedpoint = p2                     # save the point index to mark the pen position
    return p2
end




