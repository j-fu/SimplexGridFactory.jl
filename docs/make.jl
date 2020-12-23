#push!(LOAD_PATH,"../src/")
ENV["MPLBACKEND"]="agg"
using Documenter, SimplexGridFactory, ExtendableGrids, Literate, PyPlot


examples2d=joinpath(@__DIR__,"..","examples","examples2d.jl")
example_md_dir  = joinpath(@__DIR__,"src","examples")

include(examples2d)

function makeplots(picdir)
    clf()
    ExtendableGrids.plot(triangulation_of_domain(), Plotter=PyPlot)
    savefig(joinpath(picdir,"triangulation_of_domain.svg"))
    
    clf()
    ExtendableGrids.plot(nicer_triangulation_of_domain(), Plotter=PyPlot)
    savefig(joinpath(picdir,"nicer_triangulation_of_domain.svg"))
    
    clf()
    ExtendableGrids.plot(triangulation_of_domain_with_subregions(), Plotter=PyPlot)
    savefig(joinpath(picdir,"triangulation_of_domain_with_subregions.svg"))
    
    clf()
    ExtendableGrids.plot(square_localref(), Plotter=PyPlot)
    savefig(joinpath(picdir,"square_localref.svg"))
    
    clf()
    ExtendableGrids.plot(direct_square(), Plotter=PyPlot)
    savefig(joinpath(picdir,"direct_square.svg"))
    
    clf()
    ExtendableGrids.plot(swiss_cheese_2d(), Plotter=PyPlot)
    savefig(joinpath(picdir,"swiss_cheese_2d.svg"))
end

    
    
function mkdocs()

    Literate.markdown(examples2d,
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

