"""
$(TYPEDEF)
    
Simplex grid builder: wrapper around array based mesh generator interface.
It allows to build up the input data incrementally.

Up to now the implementation complexity is far from optimal.
"""
mutable struct SimplexGridBuilder
    current_facetregion::Cint
    current_cellregion::Cint
    current_cellvolume::Cdouble
    point_identity_tolerance::Cdouble
    facetregions::Vector{Cint}
    facets::Vector{Vector{Cint}}
    pointlist::BinnedPointList{Cdouble}
    regionpoints::ElasticArray{Cdouble,2}
    regionnumbers::Vector{Cint}
    regionvolumes::Vector{Cdouble}
    options::Dict{Symbol, Any}
    checkexisting::Bool
    SimplexGridBuilder(x::Nothing) = new()
end



"""
$(SIGNATURES)
Create a SimplexGridBuilder.
"""
function SimplexGridBuilder(;dim=2,tol=1.0e-12,checkexisting=true)
    this=SimplexGridBuilder(nothing)
    this.current_facetregion=1
    this.current_cellregion=1
    this.current_cellvolume=1
    
    this.point_identity_tolerance=tol
    this.facets=[]
    this.facetregions=[]
    this.pointlist=BinnedPointList(dim,tol=tol)
    this.regionpoints=ElasticArray{Cdouble}(undef,dim,0)
    this.regionvolumes=[]
    this.regionnumbers=[]
    this.options=default_options()
    this.checkexisting=checkexisting
    this
end

"""
$(SIGNATURES)

Whether to check for already existing points
"""
checkexisting!(builder,b)=this.checkexisting=b

"""
$(SIGNATURES)

Set some mesh generation options, see [`default_options`](@ref)
"""
options!(this::SimplexGridBuilder; kwargs...)=blendoptions!(this.options; kwargs...)

ExtendableGrids.dim_space(this::SimplexGridBuilder)=size(this.pointlist.points,1)



"""
$(SIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x::Number)
    dim_space(this)==1||throw(DimensionMismatch())
    insert!(this.pointlist,[x])
end

"""
$(SIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x,y)
    dim_space(this)==2||throw(DimensionMismatch())
    insert!(this.pointlist,[x,y])
end

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
function point!(this::SimplexGridBuilder,x,y,z)
    dim_space(this)==3||throw(DimensionMismatch())
    insert!(this.pointlist,[x,y,z])
end

"""
$(TYPEDSIGNATURES)
Add point or merge with already existing point. Return its index.
"""    
point!(this::SimplexGridBuilder, p::Union{AbstractVector,Tuple})=point!(this,p...)

"""
$(TYPEDSIGNATURES)
Set the current cell region (acts on subsequent regionpoint() calls)
"""
cellregion!(this::SimplexGridBuilder,i)=this.current_cellregion=i

"""
$(TYPEDSIGNATURES)
Set the current cell volume (acts on subsequent regionpoint() calls)
"""
maxvolume!(this::SimplexGridBuilder,vol)=this.current_cellvolume=vol
 
"""
$(TYPEDSIGNATURES)
"""
function regionpoint!(this::SimplexGridBuilder,x)
    dim_space(this)==1||throw(DimensionMismatch())
    append!(this.regionpoints,(x))
    push!(this.regionvolumes,this.current_cellvolume)
    push!(this.regionnumbers,this.current_cellregion)
    region
end



"""
$(TYPEDSIGNATURES)
Add a region point marking a region, using current cell volume an cell region
"""
function regionpoint!(this::SimplexGridBuilder,x,y)
    dim_space(this)==2||throw(DimensionMismatch())
    append!(this.regionpoints,(x,y))
    push!(this.regionvolumes,this.current_cellvolume)
    push!(this.regionnumbers,this.current_cellregion)
end

"""
$(TYPEDSIGNATURES)
Add a region point marking a region, using current cell volume an cell region
"""
function regionpoint!(this::SimplexGridBuilder,x,y,z)
    dim_space(this)==3||throw(DimensionMismatch())
    append!(this.regionpoints,(x,y,z))
    push!(this.regionvolumes,this.current_cellvolume)
    push!(this.regionnumbers,this.current_cellregion)
end

"""
$(TYPEDSIGNATURES)
Add a region point marking a region, using current cell volume an cell region
"""
regionpoint!(this::SimplexGridBuilder,p::Union{Vector,Tuple})=regionpoint!(this,p...)


"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
holepoint!(this::SimplexGridBuilder, p::Union{Vector,Tuple})=holepoint!(this,p...)

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
function holepoint!(this::SimplexGridBuilder, x)
    dim_space(this)==1||throw(DimensionMismatch())
    append!(this.regionpoints,(x))
    push!(this.regionvolumes,0)
    push!(this.regionnumbers,0)
    nothing
end

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
function holepoint!(this::SimplexGridBuilder, x,y)
    dim_space(this)==2||throw(DimensionMismatch())
    append!(this.regionpoints,(x,y))
    push!(this.regionvolumes,0)
    push!(this.regionnumbers,0)
    nothing
end

"""
$(TYPEDSIGNATURES)
Add a point marking a hole region
"""
function holepoint!(this::SimplexGridBuilder, x,y,z)
    dim_space(this)==3||throw(DimensionMismatch())
    append!(this.regionpoints,(x,y,z))
    push!(this.regionvolumes,0)
    push!(this.regionnumbers,0)
    nothing
end


"""
$(TYPEDSIGNATURES)
Set the current cell region (acts on subsequent regionpoint() calls)
"""
facetregion!(this::SimplexGridBuilder,i)=this.current_facetregion=i


"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder)
    dim_space(this)==1||throw(DimensionMismatch())
    push!(this.facets,[i])
    push!(this.facetregions,this.current_facetregion)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2)
    dim_space(this)==2||throw(DimensionMismatch())
    push!(this.facets,[i1,i2])
    push!(this.facetregions,this.current_facetregion)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2,i3)
    dim_space(this)==3||throw(DimensionMismatch())
    push!(this.facets,[i1,i2,i3])
    push!(this.facetregions,this.current_facetregion)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,i1,i2,i3,i4)
    dim_space(this)==3||throw(DimensionMismatch())
    push!(this.facets,[i1,i2,i3,i4])
    push!(this.facetregions,this.current_facetregion)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Add a facet via the corresponding point indices.
"""
function facet!(this::SimplexGridBuilder,p::Union{Vector,Tuple})
    if dim_space(this)==1
        length(p)==1 || throw(DimensionMismatch())
    end
    if dim_space(this)==2
        length(p)==2 || throw(DimensionMismatch())
    end
    if dim_space(this)==3
        length(p)>=3 || throw(DimensionMismatch())
    end
    push!(this.facets,[p...])
    push!(this.facetregions,this.current_facetregion)
    length(this.facets)
end

"""
$(TYPEDSIGNATURES)

Build simplex grid from the current state of the builder.
See [`default_options`](@ref) for available `kwargs`.
"""
function ExtendableGrids.simplexgrid(this::SimplexGridBuilder; kwargs...)

    if dim_space(this)==2
        facets=Array{Cint,2}(undef,2,length(this.facets))
        for i=1:length(this.facets)
            facets[1,i]=this.facets[i][1]
            facets[2,i]=this.facets[i][2]
        end
    else
        facets=this.facets
    end
    
    options=blendoptions!(copy(this.options);kwargs...)
    
    ExtendableGrids.simplexgrid(points=this.pointlist.points,
                                bfaces=facets,
                                bfaceregions=this.facetregions,
                                regionpoints=this.regionpoints,
                                regionnumbers=this.regionnumbers,
                                regionvolumes=this.regionvolumes;
                                options...)
end


