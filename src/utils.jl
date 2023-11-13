istetgen(g) = typeof(g) == Module && nameof(g) == :TetGen

istriangulate(g) = typeof(g) == Module && nameof(g) == :Triangulate

abstract type TetGenType end

abstract type TriangulateType end
