function circle!(builder::SimplexGridBuilder, center, radius; n=20)
    points=[point!(builder, center[1]+radius*sin(t),center[2]+radius*cos(t)) for t in range(0,2π,length=n)]
    for i=1:n-1
        facet!(builder,points[i],points[i+1])
    end
    facet!(builder,points[end],points[1])
    builder
end


function rect2d!(builder::SimplexGridBuilder,PA,PB;facetregions=nothing)
    if isnothing(facetregions)
        facetregions=fill(builder.current_facetregion,4)
    end
    if isa(facetregions,Number)
        facetregions=ones(4)
    end
    p00=point!(builder,PA[1],PA[2])
    p10=point!(builder,PB[1],PA[2])
    p11=point!(builder,PB[1],PB[2])
    p01=point!(builder,PA[1],PB[2])
    facetregion!(builder,facetregions[1])
    facet!(builder,p00,p10)
    facetregion!(builder,facetregions[2])
    facet!(builder,p10,p11)
    facetregion!(builder,facetregions[3])
    facet!(builder,p11,p01)
    facetregion!(builder,facetregions[4])
    facet!(builder,p01,p00)
    builder
end


function rect3d!(builder::SimplexGridBuilder,PA,PB;facetregions=nothing)
    if isnothing(facetregions)
        facetregions=fill(builder.current_facetregion,6)
    end
    if isa(facetregions,Number)
        facetregions=ones(facetregions,6)
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
    builder
end




function refine(coord,tri)
    # Short and trivial method, without creating edges,
    # so we have this search in the pointlist...
    # Also, we should kill allocations

    function pinsert(p,istop)
        # for i=size(coord,2):-1:istop
        #     @views if p≈coord[:,i]
        #         return i
        #     end
        # end
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


function sphere!(builder::SimplexGridBuilder, center, radius; nref=3)
    q=1.0/sqrt(2)
    
    coord=[-q -q  0;
           -q  q  0;
           q  q  0;
           q -q  0;
           0   0 -1;
           0   0  1]'
    coord=ElasticArray(coord)
    tri=[1 2 5;
         2 3 5;
         3 4 5;
         4 1 5;
         1 2 6;
         2 3 6;
         3 4 6;
         4 1 6]'

    @show nref
    for iref=1:nref
        @time coord,tri=refine(coord,tri)
    end
    
    @time pts=[point!(builder,(radius*coord[:,i].+center)) for i=1:size(coord,2) ]
    for i=1:size(tri,2)
         facet!(builder, pts[tri[1,i]],pts[tri[2,i]],pts[tri[3,i]])
    end

    builder
end






