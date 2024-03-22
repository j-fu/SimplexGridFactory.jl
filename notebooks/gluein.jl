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
