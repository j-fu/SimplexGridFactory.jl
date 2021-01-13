ENV["MPLBACKEND"]="agg"
using Documenter, SimplexGridFactory, ExtendableGrids, Literate, PyPlot
using GridVisualize

example_md_dir  = joinpath(@__DIR__,"src","examples")

examples2d=joinpath(@__DIR__,"..","examples","examples2d.jl")
include(examples2d)

examples3d=joinpath(@__DIR__,"..","examples","examples3d.jl")
include(examples3d)

function makeplots(picdir)
    clf()
    builderplot(triangulation_of_domain(), Plotter=PyPlot)
    savefig(joinpath(picdir,"triangulation_of_domain.svg"))
    
    clf()
    builderplot(nicer_triangulation_of_domain(), Plotter=PyPlot)
    savefig(joinpath(picdir,"nicer_triangulation_of_domain.svg"))
    
    clf()
    builderplot(triangulation_of_domain_with_subregions(), Plotter=PyPlot)
    savefig(joinpath(picdir,"triangulation_of_domain_with_subregions.svg"))
    
    clf()
    builderplot(square_localref(), Plotter=PyPlot)
    savefig(joinpath(picdir,"square_localref.svg"))
    
    clf()
    gridplot(direct_square(), Plotter=PyPlot)
    savefig(joinpath(picdir,"direct_square.svg"))
    
    clf()
    builderplot(swiss_cheese_2d(), Plotter=PyPlot)
    savefig(joinpath(picdir,"swiss_cheese_2d.svg"))

    clf()
    builderplot(swiss_cheese_2d(), Plotter=PyPlot)
    savefig(joinpath(picdir,"swiss_cheese_2d.svg"))

    clf()
    gridplot(tetrahedralization_of_cube(), Plotter=PyPlot, zplane=0.5)
    savefig(joinpath(picdir,"tetrahedralization_of_cube.svg"))
    
    clf()
    gridplot(tet_cube_with_primitives(), Plotter=PyPlot, zplane=5, azim=47, elev=80, interior=false)
    savefig(joinpath(picdir,"tet_cube_with_primitives.svg"))

 

end

    
    
function mkdocs()

    Literate.markdown(examples2d,
                      example_md_dir,
                      documenter=false,
                      info=false)

    Literate.markdown(examples3d,
                      example_md_dir,
                      documenter=false,
                      info=false)


    
    generated_examples=joinpath.("examples",filter(x->endswith(x, ".md"),readdir(example_md_dir)))

    makeplots(example_md_dir)
    
    makedocs(sitename="SimplexGridFactory.jl",
             modules = [SimplexGridFactory],
             doctest = false,
             clean = true,
             authors = "J. Fuhrmann, Ch. Merdon",
             repo="https://github.com/j-fu/SimplexGridFactory.jl",
             pages=[
                 "Home"=>"index.md",
                 "Examples" => generated_examples,
                 "Pluto Notebook(s)" => "pluto.md"
             ])
end

mkdocs()

deploydocs(repo = "github.com/j-fu/SimplexGridFactory.jl.git")

