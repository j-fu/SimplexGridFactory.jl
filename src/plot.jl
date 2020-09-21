"""
$(SIGNATURES)

Two panel plot of gridfactory.


"""
plot!(ctx::PlotterContext,gf::SimplexGridBuilder;kwargs...)=plot!(update_context!(ctx,kwargs),ctx[:backend],gf)


"""
$(SIGNATURES)

Two panel plot of gridfactory with input and resulting grid


"""
plot(gf::SimplexGridBuilder;Plotter=nothing,kwargs...)=plot!(update_context!(PlotterContext(Plotter),kwargs),gf)



function plot!(ctx, ::Type{PyPlotType}, gf::SimplexGridBuilder)
    PyPlot=ctx[:Plotter]

    prepare_figure!(ctx)

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

