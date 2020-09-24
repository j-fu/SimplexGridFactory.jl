### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ d432ad64-f91f-11ea-2e48-4bc7472ac64c
begin
	using Pkg
	Pkg.add("ExtendableGrids")
	Pkg.add("SimplexGridFactory")
	Pkg.add("PyPlot")
end

# ╔═╡ 07ebc9c4-f920-11ea-2545-111b1a4b25b3
using ExtendableGrids, SimplexGridFactory

# ╔═╡ 940b1996-fe9d-11ea-2fa4-8b72bee62b76
md"""
## Pluto notebook showing the use of SimplexGridBuilder

__Prepare the environment__:
"""

# ╔═╡ dd6db2de-fdd9-11ea-28c2-9d6b947114dc
import PyPlot

# ╔═╡ f683cf82-fe9d-11ea-1dbc-dd3cbccbbc73
md"""
__Trick PyPlot into not switching to ',' as floating point indicator:__
"""

# ╔═╡ 3e177bd8-fbeb-11ea-0c9c-c9161a2d36d4
ENV["LC_NUMERIC"]="C"; 

# ╔═╡ f32d9f04-f923-11ea-3a4a-53cc3df5642c
html"""<hr>"""

# ╔═╡ fd27b44a-f923-11ea-2afb-d79f7e62e214
md"""
### Using the SimplexGridBuilder

__Local refinement center:__
"""

# ╔═╡ b12838f0-fe9c-11ea-2939-155ed907322d
center=[0.8,0.2]

# ╔═╡ d5d8a1d6-fe9d-11ea-0fd8-df6e81492cb5
md"""
__Local refinement callback:__
"""

# ╔═╡ aae2e82a-fe9c-11ea-0427-593f8d2c7746
function unsuitable(x1,y1,x2,y2,x3,y3,area)
        bary_x=(x1+x2+x3)/3.0
        bary_y=(y1+y2+y3)/3.0
        dx=bary_x-center[1]
        dy=bary_y-center[2]
        qdist=dx^2+dy^2
        qdist>1.0e-5 && area>0.1*qdist
end;

# ╔═╡ 1ae86964-fe9e-11ea-303b-65bb128384a5
md"""
__Set up a SimplexGridBuilder:__
"""

# ╔═╡ 511b26c6-f920-11ea-1228-51c3750f495c
begin
	global factory=SimplexGridBuilder(flags=triangleflags(:domain))
	# Add points
	p1=point!(factory,(0,0))
	p2=point!(factory,(1,0))
	p3=point!(factory,(1,1))
	p4=point!(factory,(0,1))
	
	# Add facets
	facet!(factory,p1,p2,region=1)
	facet!(factory,p2,p3,region=2)
	facet!(factory,p3,p4,region=3)
	facet!(factory,p1,p4,region=4)
	facet!(factory,p1,p3,region=5)
	
	# Coarse elements in upper left region
	cellregion!(factory,(0.1,0.5),region=1)
	
	# Fine elementa in lower right region
	cellregion!(factory,(0.9,0.5),region=2,volume=0.01)
	
    # local refinement around center_x and center_y 
 	unsuitable!(factory,unsuitable)
	appendflags!(factory,"u")
	factory
end

# ╔═╡ 8f0bd5c0-f920-11ea-3b1c-db90fc95f990
plot(factory,Plotter=PyPlot,resolution=(600,600))

# ╔═╡ 46b7244c-fa91-11ea-3d98-73191a884235


# ╔═╡ 54677c86-fa91-11ea-3518-3b8aba2c8488


# ╔═╡ Cell order:
# ╟─940b1996-fe9d-11ea-2fa4-8b72bee62b76
# ╠═d432ad64-f91f-11ea-2e48-4bc7472ac64c
# ╠═07ebc9c4-f920-11ea-2545-111b1a4b25b3
# ╠═dd6db2de-fdd9-11ea-28c2-9d6b947114dc
# ╟─f683cf82-fe9d-11ea-1dbc-dd3cbccbbc73
# ╠═3e177bd8-fbeb-11ea-0c9c-c9161a2d36d4
# ╟─f32d9f04-f923-11ea-3a4a-53cc3df5642c
# ╟─fd27b44a-f923-11ea-2afb-d79f7e62e214
# ╠═b12838f0-fe9c-11ea-2939-155ed907322d
# ╟─d5d8a1d6-fe9d-11ea-0fd8-df6e81492cb5
# ╠═aae2e82a-fe9c-11ea-0427-593f8d2c7746
# ╟─1ae86964-fe9e-11ea-303b-65bb128384a5
# ╠═511b26c6-f920-11ea-1228-51c3750f495c
# ╠═8f0bd5c0-f920-11ea-3b1c-db90fc95f990
# ╟─46b7244c-fa91-11ea-3d98-73191a884235
# ╟─54677c86-fa91-11ea-3518-3b8aba2c8488
