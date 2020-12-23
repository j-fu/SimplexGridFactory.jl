"""
$(TYPEDSIGNATURES)

Two panel plot of gridfactory and its output.


"""
ExtendableGrids.plot!(ctx::PlotterContext,gf::SimplexGridBuilder;kwargs...)=plot!(ExtendableGrids.update_context!(ctx,kwargs),ctx[:backend],gf)


"""
$(TYPEDSIGNATURES)

Two panel plot of gridfactory with input and resulting grid
See [`default_options`](@ref) for available `kwargs`.
"""
ExtendableGrids.plot(gf::SimplexGridBuilder;Plotter=nothing,kwargs...)=plot!(ExtendableGrids.update_context!(PlotterContext(Plotter),kwargs),gf;kwargs...)


# dispatched version
function ExtendableGrids.plot!(ctx, ::Type{PyPlotType}, builder::SimplexGridBuilder;kwargs...)
    PyPlot=ctx[:Plotter]
    ExtendableGrids.prepare_figure!(ctx)

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
    ctx[:figure]
end

