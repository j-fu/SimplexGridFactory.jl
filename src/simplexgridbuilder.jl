"""
$(TYPEDEF)

Simplex grid builder: wrapper around array based mesh generator interface.
It allows build up the input data incrementally.
"""
mutable struct SimplexGridBuilder
    current_facetregion::Cint
    flags::String
    point_identity_tolerance::Cdouble
    facetregions::Vector{Cint}
    facets::Vector{Vector{Cint}}
    points::ElasticArray{Cdouble,2}
    regionpoints::ElasticArray{Cdouble,2}
    regionnumbers::Vector{Cint}
    regionvolumes::Vector{Cdouble}
    unsuitable::Union{Function,Nothing}
    SimplexGridBuilder(x::Nothing) = new()
end


const _triangleflags=Dict(
    :domain => "pAaqDQ",
    :pointset => "Q",
    :convex_hull => "cQ")

"""
$(TYPEDSIGNATURES)

Return some standard triangle control flags.
"""
triangleflags(s::Symbol)=_triangleflags[s]

"""
$(TYPEDSIGNATURES)

Return Dict with  possible standard triangle control flags.
"""
triangleflags()=_triangleflags

"""
$(SIGNATURES)

Create a SimplexGridBuilder.

For the flags parameter
see the  [short](https://juliageometry.github.io/Triangulate.jl/stable/#Triangulate.triangulate-Tuple{String,TriangulateIO})
resp. [long](https://juliageometry.github.io/Triangulate.jl/stable/triangle-h/)  documentation of the Triangle
control flags.

Possible standard Triangle control flags:

$(triangleflags())

"""
function SimplexGridBuilder(;dim_space=2,tol=1.0e-12,flags::String=triangleflags(:domain))
    this=SimplexGridBuilder(nothing)
    this.flags=flags
    this.current_facetregion=1
    this.point_identity_tolerance=tol
    this.facets=[]
    this.facetregions=[]
    this.unsuitable=nothing
    this.points=ElasticArray{Cdouble}(undef,dim_space,0)
    this.regionpoints=ElasticArray{Cdouble}(undef,dim_space,0)
    this.regionvolumes=[]
    this.regionnumbers=[]
    this
end


struct DimensionMismatchError <: Exception
end

"""
    $(TYPEDSIGNATURES)
    Space dimension
"""
ExtendableGrids.dim_space(this::SimplexGridBuilder)=size(this.points,1)


"""
$(TYPEDSIGNATURES)
 Current Triangle contol flags 
"""
flags(this::SimplexGridBuilder)=this.flags

"""
$(TYPEDSIGNATURES)
 Set Triangle Control flags
"""
flags!(this::SimplexGridBuilder,flags::String)=this.flags=flags

"""
$(TYPEDSIGNATURES)
 Set standard Triangle Control flags
"""
flags!(this::SimplexGridBuilder,flags::Symbol)=this.flags=_triangleflags[flags]


"""
$(TYPEDSIGNATURES)
 Append flags to Triangle control flags
"""
appendflags!(this::SimplexGridBuilder,flags::String)=this.flags*=flags

"""
$(TYPEDSIGNATURES)

Set unsuitable function, see
[`triunsuitable`](https://juliageometry.github.io/Triangulate.jl/stable/#Triangulate.triunsuitable-Tuple{Function}).

"""
unsuitable!(this::SimplexGridBuilder,func::Function)= this.unsuitable=func

function _findpoint(this::SimplexGridBuilder,x)
    if this.point_identity_tolerance<0.0
        return 0
    end
    for i=1:size(this.points,2)
        dx=x-this.points[1,i]
        if abs(dx)<this.point_identity_tolerance
            return i
        end
    end
    return 0
end

function _findpoint(this::SimplexGridBuilder,x,y)
    if this.point_identity_tolerance<0.0
        return 0
    end
    for i=1:size(this.points,2)
        dx=x-this.points[1,i]
        dy=y-this.points[2,i]
        if abs(dx^2+dy^2)<this.point_identity_tolerance^2
            return i
        end
    end
    return 0
end

function _findpoint(this::SimplexGridBuilder,x,y,z)
    if this.point_identity_tolerance<0.0
        return 0
    end
    for i=1:size(this.points,2)
        dx=x-this.points[1,i]
        dy=y-this.points[2,i]
        dz=z-this.points[3,i]
        if abs(dx^2+dy^2+dz^2)<this.point_identity_tolerance^2
            return i
        end
    end
    return 0
end

_findpoint(this::SimplexGridBuilder, p::Union{Array,Tuple})=point!(this,p...)

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x)
    dim_space(this)==1||throw(DimensionMismatchError())
    p=_findpoint(this,x)
    if p>0
        return p
    end
    append!(this.points,x)
    size(this.points,2)
end

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x,y)
    dim_space(this)==2||throw(DimensionMismatchError())
    p=_findpoint(this,x,y)
    if p>0
        return p
    end
    append!(this.points,(x,y))
    size(this.points,2)
end

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x,y,z)
    dim_space(this)==3||throw(DimensionMismatchError())
    p=_findpoint(this,x,y,z)
    if p>0
        return p
    end
    append!(this.points,(x,y,z))
    size(this.points,2)
end

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
point!(this::SimplexGridBuilder, p::Union{Vector,Tuple})=point!(this,p...)


"""
$(TYPEDSIGNATURES)
Add a region point marking a region, indicate simplex volume in this region.
"""
function cellregion!(this::SimplexGridBuilder,x;region=1,volume=1.0)
    dim_space(this)==1||throw(DimensionMismatchError())
    append!(this.regionpoints,(x))
    push!(this.regionvolumes,volume)
    push!(this.regionnumbers,region)
    region
end

"""
$(TYPEDSIGNATURES)
Add a region point marking a region, indicate simplex volume in this region.
"""
function cellregion!(this::SimplexGridBuilder,x,y;region=1,volume=1.0)
    dim_space(this)==2||throw(DimensionMismatchError())
    append!(this.regionpoints,(x,y))
    push!(this.regionvolumes,volume)
    push!(this.regionnumbers,region)
end

"""
$(TYPEDSIGNATURES)
Add a region point marking a region, indicate simplex volume in this region.
"""
function cellregion!(this::SimplexGridBuilder,x,y,z;region=1,volume=1.0)
    dim_space(this)==3||throw(DimensionMismatchError())
    append!(this.regionpoints,(x,y,z))
    push!(this.regionvolumes,volume)
    push!(this.regionnumbers,region)
    region
end

"""
$(TYPEDSIGNATURES)
Add a region point marking a region, indicate simplex volume in this region.
"""
cellregion!(this::SimplexGridBuilder,p::Union{Vector,Tuple};region=1,volume=1.0)=cellregion!(this,p...,region=region,volume=volume)

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
hole!(this::SimplexGridBuilder, p::Union{Vector,Tuple})=cellregion!(this,p,region=0,volume=1)

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
hole!(this::SimplexGridBuilder, x)=cellregion!(this,x,region=0,volume=1)

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
hole!(this::SimplexGridBuilder, x,y)=cellregion!(this,x,y,region=0,volume=1)

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
hole!(this::SimplexGridBuilder, x,y,z)=cellregion!(this,x,y,z,region=0,volume=1)



"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i;region=1)
    dim_space(this)==1||throw(DimensionMismatchError())
    push!(this.facets,[i])
    push!(this.facetregions,this.region)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2;region=1)
    dim_space(this)==2||throw(DimensionMismatchError())
    push!(this.facets,[i1,i2])
    push!(this.facetregions,region)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2,i3;region=1)
    dim_space(this)==3||throw(DimensionMismatchError())
    push!(this.facets,[i1,i2,i3])
    push!(this.facetregions,region)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2,i3,i4;region=1)
    dim_space(this)==3||throw(DimensionMismatchError())
    push!(this.facets,[i1,i2,i3,i4])
    push!(this.facetregions,region)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,p::Union{Vector,Tuple};region=1)
    if dim_space(this)==1
        length(p)==1 || throw(DimensionMismatchError())
    end
    if dim_space(this)==2
        length(p)==2 || throw(DimensionMismatchError())
    end
    if dim_space(this)==3
        length(p)>=3 || throw(DimensionMismatchError())
    end
    push!(this.facets,[p...])
    push!(this.facetregions,region)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Build simplex grid from the current state of the builder.
"""
function ExtendableGrids.simplexgrid(this::SimplexGridBuilder)
    dim_space(this)==2 || throw(error("dimension !=2 not implemented"))
    facets=Array{Cint,2}(undef,2,length(this.facets))
    for i=1:length(this.facets)
        facets[1,i]=this.facets[i][1]
        facets[2,i]=this.facets[i][2]
    end
    
    ExtendableGrids.simplexgrid(flags=this.flags,
                                points=this.points,
                                bfaces=facets,
                                bfaceregions=this.facetregions,
                                regionpoints=this.regionpoints,
                                regionnumbers=this.regionnumbers,
                                regionvolumes=this.regionvolumes,
                                unsuitable=this.unsuitable)
end

"""
$(TYPEDSIGNATURES)

Create triangle input from the current state of the builder.
"""
function triangulateio(this::SimplexGridBuilder)
    dim_space(this)==2 || throw(error("dimension !=2 not implemented"))
    facets=Array{Cint,2}(undef,2,length(this.facets))
    for i=1:length(this.facets)
        facets[1,i]=this.facets[i][1]
        facets[2,i]=this.facets[i][2]
    end
    
    triangulateio(flags=this.flags,
                  points=this.points,
                  bfaces=facets,
                  bfaceregions=this.facetregions,
                  regionpoints=this.regionpoints,
                  regionnumbers=this.regionnumbers,
                  regionvolumes=this.regionvolumes)
    
end

