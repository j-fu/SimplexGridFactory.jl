### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ d432ad64-f91f-11ea-2e48-4bc7472ac64c
begin
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add(["ExtendableGrids","SimplexGridFactory","PyPlot"])
	using ExtendableGrids, SimplexGridFactory,PyPlot
	
	# Trick pyplot into not using , as floating point decimal delimiter
	# in certain language enviromnents
	ENV["LC_NUMERIC"]="C";
	PyPlot.svg(true);
end

# ╔═╡ 940b1996-fe9d-11ea-2fa4-8b72bee62b76
md"""
## Pluto notebook showing the use of SimplexGridBuilder
"""

# ╔═╡ bc6135b8-451f-11eb-106a-2f9c9a8229d7
md"""
__Prepare the environment__:
"""

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
	    @show area
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
function make_factory()
	factory=SimplexGridBuilder(dim=2)
	
	#  Specfy points
	p1=point!(factory,0,0)
	p2=point!(factory,1,0)
	p3=point!(factory,1,1)
	p4=point!(factory,0,1.5)
	
	# Specify outer boundary
	facetregion!(factory,1)
	facet!(factory,p1,p2)
	facet!(factory,p2,p3)
	facet!(factory,p3,p4)
	facet!(factory,p1,p4)
	
	# specify interionr boundary
	facetregion!(factory,2)
	facet!(factory,p1,p3)
	
	# Coarse elements in upper left region
	cellregion!(factory,1)
	regionpoint!(factory,0.1,0.5)
	
	# Fine elements in lower right region
	cellregion!(factory,2)
	cellvolume!(factory,0.01)
	regionpoint!(factory,0.9,0.5)
	
	# Activate unsuitable callback
	options!(factory,unsuitable=unsuitable)
	factory
end

# ╔═╡ dd85d88e-44b3-11eb-3e31-c7dcbe07d0de
builder=make_factory()

# ╔═╡ 8f0bd5c0-f920-11ea-3b1c-db90fc95f990
ExtendableGrids.plot(builder,Plotter=PyPlot,resolution=(600,600))

# ╔═╡ 54677c86-fa91-11ea-3518-3b8aba2c8488
md"""
These are the Triangle control flags created from the default options:
"""

# ╔═╡ 1067166c-451f-11eb-2916-c94382a220a3
SimplexGridFactory.makeflags(builder.options,:triangle)

# ╔═╡ Cell order:
# ╠═940b1996-fe9d-11ea-2fa4-8b72bee62b76
# ╠═bc6135b8-451f-11eb-106a-2f9c9a8229d7
# ╠═d432ad64-f91f-11ea-2e48-4bc7472ac64c
# ╟─f32d9f04-f923-11ea-3a4a-53cc3df5642c
# ╟─fd27b44a-f923-11ea-2afb-d79f7e62e214
# ╠═b12838f0-fe9c-11ea-2939-155ed907322d
# ╟─d5d8a1d6-fe9d-11ea-0fd8-df6e81492cb5
# ╠═aae2e82a-fe9c-11ea-0427-593f8d2c7746
# ╟─1ae86964-fe9e-11ea-303b-65bb128384a5
# ╠═511b26c6-f920-11ea-1228-51c3750f495c
# ╠═dd85d88e-44b3-11eb-3e31-c7dcbe07d0de
# ╠═8f0bd5c0-f920-11ea-3b1c-db90fc95f990
# ╟─54677c86-fa91-11ea-3518-3b8aba2c8488
# ╠═1067166c-451f-11eb-2916-c94382a220a3
