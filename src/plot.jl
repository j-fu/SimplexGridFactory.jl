

"""
$(TYPEDSIGNATURES)

Two panel gridplot of gridfactory with input and resulting grid
See [`default_options`](@ref) for available `kwargs`.
"""
ExtendableGrids.gridplot(gb::SimplexGridBuilder; Plotter=nothing,kwargs...)= ExtendableGrids.gridplot(plottertype(Plotter), gb,Plotter;kwargs...)

function ExtendableGrids.gridplot(::Type{PyPlotType}, builder::SimplexGridBuilder,PyPlot ;kwargs...)

    p=ExtendableGrids.GridPlotContext(Plotter=PyPlot, layout=(1,2), kwargs...)

    opts=blendoptions!(copy(builder.options);kwargs...)
    
    flags=makeflags(opts,:triangle)

    if opts[:verbose]
        @show flags
    end

    triin=nothing
    try
        triin=triangulateio(builder)
    catch err
        @error "Incomplete geometry description"
        rethrow(err)
    end

    if !isnothing(opts[:unsuitable])
        triunsuitable(opts[:unsuitable])
    end

    triout,vorout=Triangulate.triangulate(flags,triin)
    PyPlot.subplot(121)
    PyPlot.title("In")
    Triangulate.plot(PyPlot,triin)
    PyPlot.subplot(122)
    PyPlot.title("Out")
    Triangulate.plot(PyPlot,triout)
    PyPlot.tight_layout()
    PyPlot.gcf()
end

