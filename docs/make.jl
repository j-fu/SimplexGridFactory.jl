ENV["MPLBACKEND"] = "agg"
using Documenter, SimplexGridFactory, ExtendableGrids, Literate
import CairoMakie
using CairoMakie: save
using GridVisualize: GridVisualizer, gridplot!

CairoMakie.activate!(; type = "svg", visible = false)
example_md_dir = joinpath(@__DIR__, "src", "examples")

examples2d = joinpath(@__DIR__, "..", "examples", "examples2d.jl")
include(examples2d)

examples3d = joinpath(@__DIR__, "..", "examples", "examples3d.jl")
include(examples3d)

zzaccessing = joinpath(@__DIR__, "..", "examples", "zzaccessing.jl")

function makeplots(picdir)
    fig = builderplot(triangulation_of_domain(); Plotter = CairoMakie)
    save(joinpath(picdir, "triangulation_of_domain.svg"), fig)

    fig = builderplot(nicer_triangulation_of_domain(); Plotter = CairoMakie)
    save(joinpath(picdir, "nicer_triangulation_of_domain.svg"), fig)

    fig = builderplot(triangulation_of_domain_with_subregions(); Plotter = CairoMakie)
    save(joinpath(picdir, "triangulation_of_domain_with_subregions.svg"), fig)

    fig = builderplot(square_localref(); Plotter = CairoMakie)
    save(joinpath(picdir, "square_localref.svg"), fig)

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, direct_square())
    save(joinpath(picdir, "direct_square.svg"), vis.context[:figure])

    fig = builderplot(swiss_cheese_2d(); Plotter = CairoMakie)
    save(joinpath(picdir, "swiss_cheese_2d.svg"), fig)

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, glue_2d())
    save(joinpath(picdir, "glue_2d.svg"), vis.context[:figure])

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, tetrahedralization_of_cube(); zplane = 0.5)
    save(joinpath(picdir, "tetrahedralization_of_cube.svg"), vis.context[:figure])

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, tet_cube_with_primitives(); zplane = 5, azim = 47, elev = 80, interior = false)
    save(joinpath(picdir, "tet_cube_with_primitives.svg"), vis.context[:figure])

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, glue_3d(); azim = 0, elev = 15, xplanes = [5])
    save(joinpath(picdir, "glue_3d.svg"), vis.context[:figure])

    vis = GridVisualizer(; Plotter = CairoMakie)
    gridplot!(vis, stl_3d(); xplanes = [5])
    save(joinpath(picdir, "stl_3d.svg"), vis.context[:figure])
end

function mkdocs()
    generated_examples = []
    for example ∈ [examples2d, examples3d, zzaccessing]
        Literate.markdown(example,
                          example_md_dir; info = false)
    end

    generated_examples = joinpath.("examples", filter(x -> endswith(x, ".md"), readdir(example_md_dir)))
    push!(generated_examples, "pluto.md")
    makeplots(example_md_dir)

    makedocs(; sitename = "SimplexGridFactory.jl",
             modules = [SimplexGridFactory],
             doctest = false,
             clean = false,
             authors = "J. Fuhrmann, Ch. Merdon",
             repo = "https://github.com/j-fu/SimplexGridFactory.jl",
             pages = [
                 "Home" => "index.md",
                 "API" => "api.md",
                 "Examples" => generated_examples,
                 "Internals" => "internals.md",
                 "allindex.md",
             ])
    @show generated_examples
end

mkdocs()

deploydocs(; repo = "github.com/j-fu/SimplexGridFactory.jl.git")
