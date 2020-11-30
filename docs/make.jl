push!(LOAD_PATH,"../src/")
using Documenter, SimplexGridFactory, ExtendableGrids, Literate

#
# Replace SOURCE_URL marker with github url of source
#
function replace_source_url(input,source_url)
    lines_in = collect(eachline(IOBuffer(input)))
    lines_out=IOBuffer()
    for line in lines_in
        println(lines_out,replace(line,"SOURCE_URL" => source_url))
    end
    return String(take!(lines_out))
end




function mkdocs()
    example_jl_dir = joinpath(@__DIR__,"..","examples")
    example_md_dir  = joinpath(@__DIR__,"src","examples")

    for example_source in readdir(example_jl_dir)
        base,ext=splitext(example_source)
        if ext==".jl" && occursin("Example",base)
            source_url="https://github.com/j-fu/SimplexGridFactory.jl/raw/master/examples/"*example_source
            preprocess(buffer)=replace_source_url(buffer,source_url)
            Literate.markdown(joinpath(@__DIR__,"..","examples",example_source),
                              example_md_dir,
                              documenter=false,
                              info=false,
                              preprocess=preprocess)
        end
    end
    generated_examples=joinpath.("examples",readdir(example_md_dir))



    makedocs(sitename="SimplexGridFactory.jl",
             modules = [SimplexGridFactory],
             doctest = true,
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

