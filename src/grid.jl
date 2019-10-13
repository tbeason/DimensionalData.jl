"""
Indicate the position of coordinates on the grid. 
"""
abstract type CoordLocation end

"""
Indicates dimensions that are defined by their center coordinates/time/position.  
"""
struct Center <: CoordLocation end

"""
Indicates dimensions that are defined by their start coordinates/time/position.
"""
struct Start <: CoordLocation  end

"""
Indicates dimensions that are defined by their end coordinates/time/position
"""
struct End <: CoordLocation  end



"""
Traits describing the grid type of a dimension
"""
abstract type AbstractGrid end

"""
Traits describing regular grids
"""
abstract type AbstractRegularGrid <: AbstractGrid end

"""
Trait describing a regular grid along a dimension. 

The span field indicates the size of a grid step like, such as `Month(1)`.
"""
struct RegularGrid{T,S} <: AbstractRegularGrid 
    span::S
end
RegularGrid(span=nothing) = RegularGrid{Center, typeof(span)}(span) 

"""
Fallback grid type for regular arrays
"""
struct UnknownGrid <: AbstractRegularGrid end



"""
Traits describing a dimension where the dimension values are categories.
"""
abstract type AbstractCategoricalGrid <: AbstractGrid end

struct CategoricalGrid <: AbstractCategoricalGrid end



"""
Traits describing a dimension whos coordinates change along another dimension. 
"""
abstract type AbstractIrregularGrid end

dims(grid::AbstractIrregularGrid) = grid.dims

"""
Grid type using an affine transformation to convert dimension from 
`dim(grid)` to `dims(array)`.
"""
struct TransformedGrid{T,D} <: AbstractIrregularGrid 
    transform::T
    dims::D
end

transform(grid::TransformedGrid) = grid.transform

"""
Grid type using an array lookup to convert dimension from 
`dim(grid)` to `dims(array)`.
"""
struct LookupGrid{L,D} <: AbstractIrregularGrid 
    lookup::L
    dims::D
end

lookup(grid::LookupGrid) = grid.lookup
