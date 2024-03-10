### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin
    import Pkg as _Pkg
    haskey(ENV, "PLUTO_PROJECT") && _Pkg.activate(ENV["PLUTO_PROJECT"])
    using PlutoUI
    using SimplexGridFactory
    using GridVisualize
    using PlutoVista
    using Triangulate, TetGen
    using ExtendableGrids
    default_plotter!(PlutoVista)
end

# ╔═╡ a40a767c-6a26-4537-9aac-8070ca3aa457
TableOfContents()

# ╔═╡ b7ba2d07-3384-42b4-926a-2c0f442398f1
md"""
## 2D
"""

# ╔═╡ f2e42892-3952-4525-b83d-b432a120b2fa
h = 0.25

# ╔═╡ bbc712db-12ab-4a17-b4a6-4246b00edb04
X = 0:h:10

# ╔═╡ b1c4cc6a-db7d-4fd7-bea7-5a209ef35c50
Y = 0:h:4

# ╔═╡ bc62d60e-f82a-4454-a772-1a64222e37e0
begin
    grid1 = simplexgrid(X, Y)
    bfacemask!(grid1, [0, 2], [10, 2], 7)
    cellmask!(grid1, [0, 0], [10, 2], 2)
end

# ╔═╡ f57f9038-b6f3-4b4d-8b2e-040fc6c554ba
gridplot(grid1)

# ╔═╡ 51273ce2-7830-4eab-9a6f-bbb42454aab6
begin
    b = SimplexGridBuilder(; Generator = Triangulate)
    xmin = -2
    x0min = 0
    x0max = 10
    xmax = 12
    y0min = 0
    ymin = -2
    y0max = 4
    ymax = 6
    facetregion!(b, 8)
    facet!(b, (xmin, ymin), (xmax, ymin))
    facet!(b, (xmax, ymin), (xmax, 2))
    facet!(b, (xmax, 2), (xmax, ymax))
    facet!(b, (xmin, ymax), (xmax, ymax))
    facet!(b, (xmin, ymin), (xmin, 2))
    facet!(b, (xmin, 2), (xmin, ymax))

    facetregion!(b, 7)
    facet!(b, (x0min, 2), (xmin, 2))
    facet!(b, (x0max, 2), (xmax, 2))
    cellregion!(b, 2)
    regionpoint!(b, 5, -1)

    holepoint!(b, 5, 2)

    bregions!(b, grid1, 1:6)
    grid2 = simplexgrid(b; maxvolume = 0.6)
    grid2 = glue(grid1, grid2)
end

# ╔═╡ 53571d11-947b-4a44-90a7-ee633f395f0b
gridplot(grid2)

# ╔═╡ 20b61b08-ec7e-43a8-af33-9c95109e5678
md"""
## 3D
"""

# ╔═╡ d26dbeda-e2cd-4fdf-971d-4415c53a6aad
Z1 = 0:h:2

# ╔═╡ 982aa7e4-ae4e-4e47-87a9-c022cd01c6dc
Z2 = 2:h:4

# ╔═╡ 83651eb7-1286-4fa1-8a1e-1ae1e4524aa8
begin
    grid3_1 = simplexgrid(X, X, Z1)
    cellmask!(grid3_1, [0, 0, 0], [10, 10, 4], 2)
    grid3_2 = simplexgrid(X, X, Z2)
    grid3 = glue(grid3_1, grid3_2;
                 interface = 7, g1regions = [6], g2regions = [5])
end

# ╔═╡ 11ca5bdf-6cf0-4e6d-bf76-7a6aec0b7d42
gridplot(grid3; yplanes = 5)

# ╔═╡ dfa012e9-51c8-45be-9bce-730a49df4f93
gx = let
    b = SimplexGridBuilder(; Generator = TetGen)
    xmin = -2
    x0min = 0
    x0max = 10
    xmax = 12

    ymin = -2
    y0min = 0
    y0max = 10
    ymax = 12

    z0min = 0
    zmin = -2
    z0max = 4
    zmax = 6

    p1 = point!(b, xmin, ymin, zmin)
    p2 = point!(b, xmax, ymin, zmin)
    p3 = point!(b, xmax, ymax, zmin)
    p4 = point!(b, xmin, ymax, zmin)
    p5 = point!(b, xmin, ymin, zmax)
    p6 = point!(b, xmax, ymin, zmax)
    p7 = point!(b, xmax, ymax, zmax)
    p8 = point!(b, xmin, ymax, zmax)

    facetregion!(b, 8)
    facet!(b, p1, p2, p3, p4)
    facet!(b, p5, p6, p7, p8)
    facet!(b, p1, p2, p6, p5)
    facet!(b, p2, p3, p7, p6)
    facet!(b, p3, p4, p8, p7)
    facet!(b, p4, p1, p5, p8)

    holepoint!(b, (5, 5, 2))
    facetregion!(b, 7)
    bregions!(b, grid3, 1:6)
    gouter = simplexgrid(b; maxvolume = 0.2)
    #	glue(gouter,grid3,g2regions=7)

    #=	
    	facet!(b,(xmin,ymin,zmin), (xmax,ymax,zmin))
        facet!(b,(xmin,ymin,zmax), (xmax,ymax,zmax))
    	facet!(b,(xmin,ymin,zmin), (xmax,ymin,zmax))
    	facet!(b,(xmin,ymax,zmin), (xmax,ymax,zmax))

    	facet!(b,(xmin,ymin,zmin), (xmin,ymax,zmax))
    	facet!(b,(xmax,ymin,zmin), (xmax,ymax,zmax))
    	facet!(b,(xmax,ymin), (xmax,2))
    	facet!(b,(xmax,2), (xmax,ymax))
    	facet!(b,(xmin,ymax), (xmax,ymax))
    	facet!(b,(xmin,ymin), (xmin,2))
    	facet!(b,(xmin,2), (xmin,ymax))

    	facetregion!(b,7)
    	facet!(b,(x0min,2),(xmin,2))
    	facet!(b,(x0max,2),(xmax,2))
    	cellregion!(b,2)
    	regionpoint!(b,5,-1)

    	holepoint!(b,5,2)

    	bregions!(b,grid1,1:6)
    	grid2=simplexgrid(b,maxvolume=0.6)
    	grid2=glue(grid1,grid2)
    =#
end

# ╔═╡ a89f5f56-abd9-4984-a23f-063a984d0048
gridplot(gx; xplanes = 5)

# ╔═╡ d194ae6d-60a9-4725-904a-9cff9f1b9570
gy = let
    grid1 = simplexgrid(X, X)

    b = SimplexGridBuilder(; Generator = Triangulate)
    xmin = -2
    x0min = 0
    x0max = 10
    xmax = 12
    y0min = 0
    ymin = -2
    y0max = 10
    ymax = 12
    facetregion!(b, 8)
    facet!(b, (xmin, ymin), (xmax, ymin))
    facet!(b, (xmax, ymin), (xmax, ymax))
    facet!(b, (xmin, ymax), (xmax, ymax))
    facet!(b, (xmin, ymin), (xmin, ymax))

    holepoint!(b, 5, 2)

    bregions!(b, grid1, 1:6)
    grid2 = simplexgrid(b; maxvolume = 0.6)
    grid2 = glue(grid1, grid2)
end

# ╔═╡ e1b7ded7-f2d1-4434-a4e2-ff891c3a1584
gridplot(gy; xplanes = 5)

# ╔═╡ 5e572de7-024a-48b9-aa20-5f6104fef4cd
-reverse(Y)

# ╔═╡ 9194c21f-de70-433f-a515-e2e295fc9f57
gxy = simplexgrid(gy, glue(-reverse(Y), Y); top_offset = 8)

# ╔═╡ 8fb2bb3c-7483-43ab-a0e9-a4399021225f


# ╔═╡ 3411a518-c4e3-4ccf-ad5a-fe86b6c5df9d
gridplot(gxy; xplanes = 5)

# ╔═╡ cbad5c1b-cf22-411e-b142-578fa35df51b
gx2 = let
    b = SimplexGridBuilder(; Generator = TetGen)
    xmin = -2
    xmax = 12

    ymin = -2
    ymax = 12

    zmin = 4
    zmax = 6

    p1 = point!(b, xmin, ymin, zmin)
    p2 = point!(b, xmax, ymin, zmin)
    p3 = point!(b, xmax, ymax, zmin)
    p4 = point!(b, xmin, ymax, zmin)
    p5 = point!(b, xmin, ymin, zmax)
    p6 = point!(b, xmax, ymin, zmax)
    p7 = point!(b, xmax, ymax, zmax)
    p8 = point!(b, xmin, ymax, zmax)

    facetregion!(b, 8)
    facet!(b, p1, p2, p3, p4)
    facet!(b, p5, p6, p7, p8)
    facet!(b, p1, p2, p6, p5)
    facet!(b, p2, p3, p7, p6)
    facet!(b, p3, p4, p8, p7)
    facet!(b, p4, p1, p5, p8)

    #	bregions!(b,gxy,[9])
    simplexgrid(b; maxvolume = 0.6)
end

# ╔═╡ 52024242-c5b5-4d2f-b25f-5803a3f76558
gridplot(gx2; xplanes = 5)

# ╔═╡ 60bc2490-381a-4b51-9154-557bf7dbfc45
function glue_3d()
    h0 = 1.0
    X0 = -2:h0:12
    Z0 = -2:h0:6
    g0 = simplexgrid(X0, X0, Z0)

    h = 0.25
    X = 0:h:10
    Z = 0:h:4

    grid3 = simplexgrid(X, X, Z)
    b = SimplexGridBuilder(; Generator = TetGen)

    bregions!(b, g0, 1:6; facetregions = [8 for i = 1:7])
    cellregion!(b, 2)
    regionpoint!(b, (-1, -1, -1))

    bregions!(b, grid3, 1:6)
    holepoint!(b, (5, 5, 2))
    gouter = simplexgrid(b; maxvolume = 0.4, nosteiner = true)
    glue(gouter, grid3; interface = 7)
end

# ╔═╡ 816401f3-d9fb-427b-b595-8dbd055cee5f
gridplot(glue_3d(); xplanes = [-3])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~1.3.2"
GridVisualize = "~1.5.0"
PlutoUI = "~0.7.58"
PlutoVista = "~1.0.1"
SimplexGridFactory = "~1.0.0"
TetGen = "~1.5.1"
Triangulate = "~2.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "48ba9a7286411fc37d21729f45d0c6928f32db93"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cea4ac3f5b4bc4b3000aa55afb6e5626518948fa"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.3"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bijections]]
git-tree-sha1 = "c9b163bd832e023571e86d0b90d9de92a9879088"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.6"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "575cd02e080939a33b6df6c5853d14924c08e35b"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.23.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "c955881e3c981181362ae4088b35995446298b80"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.14.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"
weakdeps = ["IntervalSets", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "0f4b5d62a88d8f59003e43c25a8a90de9eb76317"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.18"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "75e5697f521c9ab89816d3abeea806dfc5afb967"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.12"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Bijections", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "Requires", "SparseArrays", "StaticArrays", "StatsBase", "UUIDs", "WriteVTK"]
git-tree-sha1 = "7c4585a15f4c63dc9d2a13b9825747016961cde8"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "1.3.2"

    [deps.ExtendableGrids.extensions]
    ExtendableGridsGmshExt = "Gmsh"

    [deps.ExtendableGrids.weakdeps]
    Gmsh = "705231aa-382f-11e9-3f0c-b7cb4346fdeb"

[[deps.Extents]]
git-tree-sha1 = "2140cd04483da90b2da7f99b2add0750504fc39c"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.2"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "c5c28c245101bd59154f649e19b038d15901b5dc"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "d4f85701f569584f2cff7ba67a137d03f0cfb7d0"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.3"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "5694b56ccf9d15addedc35e9a4ba9c317721b788"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.10"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "GridVisualizeTools", "HypertextLiteral", "Interpolations", "IntervalSets", "LinearAlgebra", "Observables", "OrderedCollections", "Printf", "StaticArrays"]
git-tree-sha1 = "f88733a32e49542e3237d7e03ddc77d7c79a1825"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "1.5.0"

    [deps.GridVisualize.weakdeps]
    CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
    GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"
    Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
    PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
    PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"

[[deps.GridVisualizeTools]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "StaticArraysCore"]
git-tree-sha1 = "e111f256aa000c4e4662d1119281b751aa66dc37"
uuid = "5573ae12-3b76-41d9-b48c-81d0b6e61cc5"
version = "1.1.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "3a994404d3f6709610701c7dabfc03fed87a81f8"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MeshIO]]
deps = ["ColorTypes", "FileIO", "GeometryBasics", "Printf"]
git-tree-sha1 = "8c26ab950860dfca6767f2bbd90fdf1e8ddc678b"
uuid = "7269a6da-0436-5bbc-96c2-40638cbb6118"
version = "0.4.11"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

[[deps.PlutoVista]]
deps = ["AbstractPlutoDingetjes", "ColorSchemes", "Colors", "DocStringExtensions", "GridVisualizeTools", "HypertextLiteral", "UUIDs"]
git-tree-sha1 = "5be7548065d668761814809e2c7ee33310a3d82f"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "1.0.1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "FileIO", "LinearAlgebra", "MeshIO", "Printf"]
git-tree-sha1 = "ec1a5c088b696eab7862f9960aca5a51031cb173"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "1.0.0"
weakdeps = ["TetGen", "Triangulate"]

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "bf074c045d3d5ffd956fa0a461da38a44685d6b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.3"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "f4dc295e983502292c4c3f951dbb4e985e35b3be"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.18"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = "GPUArraysCore"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "c996d334a5a3bd29c180df777b2977153741c869"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.5.1"

[[deps.TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ceedd691bce040e24126a56354f20d71554a495"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.3+0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "3caa21522e7efac1ba21834a03734c57b4611c7e"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.4"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "fe28e9a4684f6f54e868b9136afb8fd11f1734a7"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.2+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Printf", "Triangle_jll"]
git-tree-sha1 = "864f14dd4733ad8b3bf53b7373291b344a6d87a0"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.3.2"

    [deps.Triangulate.weakdeps]
    CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
    GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"
    PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VTKBase]]
git-tree-sha1 = "c2d0db3ef09f1942d08ea455a9e252594be5f3b6"
uuid = "4004b06d-e244-455f-a6ce-a5f9919cc534"
version = "1.0.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams", "VTKBase"]
git-tree-sha1 = "5817a62d8a1d00ce36bb418aceafaa49cff81b65"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.18.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "07e470dabc5a6a4254ffebc29a1b3fc01464e105"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.5+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╠═a40a767c-6a26-4537-9aac-8070ca3aa457
# ╟─b7ba2d07-3384-42b4-926a-2c0f442398f1
# ╠═f2e42892-3952-4525-b83d-b432a120b2fa
# ╠═bbc712db-12ab-4a17-b4a6-4246b00edb04
# ╠═b1c4cc6a-db7d-4fd7-bea7-5a209ef35c50
# ╠═bc62d60e-f82a-4454-a772-1a64222e37e0
# ╠═f57f9038-b6f3-4b4d-8b2e-040fc6c554ba
# ╠═51273ce2-7830-4eab-9a6f-bbb42454aab6
# ╠═53571d11-947b-4a44-90a7-ee633f395f0b
# ╠═20b61b08-ec7e-43a8-af33-9c95109e5678
# ╠═d26dbeda-e2cd-4fdf-971d-4415c53a6aad
# ╠═982aa7e4-ae4e-4e47-87a9-c022cd01c6dc
# ╠═83651eb7-1286-4fa1-8a1e-1ae1e4524aa8
# ╠═11ca5bdf-6cf0-4e6d-bf76-7a6aec0b7d42
# ╠═dfa012e9-51c8-45be-9bce-730a49df4f93
# ╠═a89f5f56-abd9-4984-a23f-063a984d0048
# ╠═d194ae6d-60a9-4725-904a-9cff9f1b9570
# ╠═e1b7ded7-f2d1-4434-a4e2-ff891c3a1584
# ╠═5e572de7-024a-48b9-aa20-5f6104fef4cd
# ╠═9194c21f-de70-433f-a515-e2e295fc9f57
# ╠═8fb2bb3c-7483-43ab-a0e9-a4399021225f
# ╠═3411a518-c4e3-4ccf-ad5a-fe86b6c5df9d
# ╠═cbad5c1b-cf22-411e-b142-578fa35df51b
# ╠═52024242-c5b5-4d2f-b25f-5803a3f76558
# ╠═60bc2490-381a-4b51-9154-557bf7dbfc45
# ╠═816401f3-d9fb-427b-b595-8dbd055cee5f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
