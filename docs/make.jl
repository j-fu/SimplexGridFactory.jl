ENV["MPLBACKEND"]="agg"
using Documenter, SimplexGridFactory, ExtendableGrids, Literate, PyPlot
using GridVisualize

example_md_dir  = joinpath(@__DIR__,"src","examples")

examples2d=joinpath(@__DIR__,"..","examples","examples2d.jl")
include(examples2d)

examples3d=joinpath(@__DIR__,"..","examples","examples3d.jl")
include(examples3d)

zzaccessing=joinpath(@__DIR__,"..","examples","zzaccessing.jl")



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

    generated_examples=[]
    for example ∈ [examples2d,examples3d,zzaccessing]
        Literate.markdown(example,
                          example_md_dir,
                          documenter=false,
                          info=false)
    end


    
    generated_examples=joinpath.("examples",filter(x->endswith(x, ".md"),readdir(example_md_dir)))
    push!(generated_examples,"pluto.md")
    makeplots(example_md_dir)
    
    makedocs(sitename="SimplexGridFactory.jl",
             modules = [SimplexGridFactory],
             doctest = false,
             clean = false,
             authors = "J. Fuhrmann, Ch. Merdon",
             repo="https://github.com/j-fu/SimplexGridFactory.jl",
             pages=[
                 "Home"=>"index.md",
                 "API"=>"api.md",
                 "Examples" => generated_examples,
                 "Internals"=>"internals.md",
                 "allindex.md",
             ])
    @show generated_examples
end

mkdocs()

deploydocs(repo = "github.com/j-fu/SimplexGridFactory.jl.git")

