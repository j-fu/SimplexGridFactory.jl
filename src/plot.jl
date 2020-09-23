"""
$(SIGNATURES)

Two panel plot of gridfactory.


"""
ExtendableGrids.plot!(ctx::PlotterContext,gf::SimplexGridBuilder;kwargs...)=plot!(ExtendableGrids.update_context!(ctx,kwargs),ctx[:backend],gf)


"""
$(SIGNATURES)

Two panel plot of gridfactory with input and resulting grid


"""
ExtendableGrids.plot(gf::SimplexGridBuilder;Plotter=nothing,kwargs...)=plot!(ExtendableGrids.update_context!(PlotterContext(Plotter),kwargs),gf)


# dispatched version
function ExtendableGrids.plot!(ctx, ::Type{PyPlotType}, gf::SimplexGridBuilder)
    PyPlot=ctx[:Plotter]
    ExtendableGrids.prepare_figure!(ctx)
    triin=nothing
    try
        triin=triangulateio(gf)
    catch err
        @error "Incomplete geometry description"
        rethrow(err)
    end
    if typeof(gf.unsuitable)!=Nothing
        triunsuitable(gf.unsuitable)
    end
    triout,vorout=Triangulate.triangulate(gf.flags,triin)
    PyPlot.subplot(121)
    PyPlot.title("In")
    Triangulate.plot(PyPlot,triin)
    PyPlot.subplot(122)
    PyPlot.title("Out")
    Triangulate.plot(PyPlot,triout)
    PyPlot.tight_layout()
    ctx[:figure]
end

