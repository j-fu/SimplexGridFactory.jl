
"""
$(TYPEDSIGNATURES)

Two panel visualization of gridfactory with input and resulting grid
See [`default_options`](@ref) for available `kwargs`.
"""
builderplot(gb::SimplexGridBuilder; Plotter = nothing, kwargs...) = builderplot(gb, Plotter; kwargs...)

builderplot(builder::SimplexGridBuilder, ::Nothing; kwargs...) = nothing

function builderplot(builder::SimplexGridBuilder, Plotter::Module; size = (650, 300), kwargs...)
    opts = blendoptions!(copy(builder.options); kwargs...)

    Triangulate = builder.Generator
    @assert(istriangulate(Triangulate))

    flags = makeflags(opts, :triangle)

    if opts[:verbose]
        @show flags
    end

    triin = nothing
    try
        triin = triangulateio(builder)
    catch err
        @error "Incomplete geometry description"
        rethrow(err)
    end

    if !isnothing(opts[:unsuitable])
        Triangulate.triunsuitable!(opts[:unsuitable])
    end

    triout, vorout = Triangulate.triangulate(flags, triin)

    figure = nothing
    if Triangulate.ispyplot(Plotter)
        Plotter.close()
        Plotter.clf()
        fig = Plotter.figure(1; dpi = 100)
        fig.set_size_inches(size[1] / 100, size[2] / 100; forward = true)
    end
    if Triangulate.ismakie(Plotter)
        figure = Plotter.Figure(; size)
    end
    Triangulate.plot_in_out(Plotter, triin, triout; figure)
end
