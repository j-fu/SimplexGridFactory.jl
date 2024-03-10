
"""
    istetgen(Generator)

Check if generator is TetGen.
"""
istetgen(g) = typeof(g) == Module && nameof(g) == :TetGen

"""
    istriangulate(Generator)

Check if generator is Triangulate.
"""
istriangulate(g) = typeof(g) == Module && nameof(g) == :Triangulate

abstract type TetGenType end

abstract type TriangulateType end
