# Primitives. These do most of the work in the package. 
# They are all @generated or recusive functions for performance.

"""
Sort dimensions into the order they take in the array.

Missing dimensions are replaced with `nothing`
"""
@inline Base.permutedims(tosort, a::AbstractDimensionalArray) = 
    permutedims(tosort, dims(a))
@inline Base.permutedims(tosort::Tuple{UnionAll,Vararg}, order::AbDimTuple) =
    permutedims(map(u -> u(), tosort), order)
@generated Base.permutedims(tosort::AbDimTuple, order::AbDimTuple) = 
    permutedims_inner(tosort, order)

permutedims_inner(tosort::Type, order::Type) = begin
    indexexps = []
    for dim in order.parameters
        index = findfirst(d -> basetype(d) <: basetype(dim), tosort.parameters)
        if index == nothing
            push!(indexexps, :(nothing))
        else
            push!(indexexps, :(tosort[$index]))
        end
    end
    Expr(:tuple, indexexps...)
end


"""
Convert a tuple of AbstractDimension to indices or ranges to index the parent array.
"""
@inline dims2indices(a::AbstractArray, lookup, emptyval=Colon()) =
    dims2indices(dims(a), lookup, emptyval)
@inline dims2indices(dims::Tuple, lookup, emptyval=Colon()) =
    dims2indices(dims, (lookup,), emptyval)
@inline dims2indices(dims::Tuple, lookup::Tuple, emptyval=Colon()) =
    _dims2indices(dims, permutedims(lookup, dims), emptyval)

@inline _dims2indices(dims::Tuple, lookup::Tuple, emptyval) =
    (dims2indices(dims[1], lookup[1], emptyval),
     _dims2indices(tail(dims), tail(lookup), emptyval)...)
@inline _dims2indices(dims::Tuple, lookup::Tuple{}, emptyval) =
    (emptyval, _dims2indices(tail(dims), (), emptyval)...)
@inline _dims2indices(dims::Tuple{}, lookup::Tuple{}, emptyval) = ()

@inline dims2indices(dim::AbDim, lookup, emptyval) = val(lookup)
@inline dims2indices(dim::AbDim, lookup::Type{<:AbDim}, emptyval) = Colon()
@inline dims2indices(dim::AbDim, lookup::Nothing, emptyval) = emptyval


"""
Slice the dimensions to match the axis values of the new array

All methods returns a tuple conatining two tuples: the new dimensions,
and the reference dimensions. The ref dimensions are no longer used in
the new struct but are useful to give context to plots.

Called at the array level the returned tuple will also include the
previous reference dims.
"""
@inline slicedims(a::AbstractArray, dims::AbDimTuple) = slicedims(a, dims2indices(a, dims))
@inline slicedims(a::AbstractArray, I) = begin
    newdims, newrefdims = slicedims(dims(a), I)
    # Combine new refdims with existing refdims
    newdims, (refdims(a)..., newrefdims...)
end
@inline slicedims(dims::Tuple, I::Tuple) = begin
    d = slicedims(dims[1], I[1])
    ds = slicedims(tail(dims), tail(I))
    (d[1]..., ds[1]...), (d[2]..., ds[2]...)
end
@inline slicedims(dims::Tuple{}, I::Tuple{}) = ((), ())
@inline slicedims(d::AbDim, i::Number) = ((), (basetype(d)(val(d)[i], metadata(d)),))
@inline slicedims(d::AbDim, i::Colon) = ((basetype(d)(val(d), metadata(d)),), ())
@inline slicedims(d::AbDim, i::AbstractVector) = ((basetype(d)(val(d)[i], metadata(d)),), ())
@inline slicedims(d::AbDim{<:LinRange}, i::AbstractRange) = begin
    range = val(d)
    start, stop, len = range[first(i)], range[last(i)], length(i)
    d = typeof(d)(LinRange(start, stop, len), metadata(d))
    ((d,), ())
end


"""
Get the number of an AbstractDimension as ordered in the array
"""
@inline dimnum(a, dims) = dimnum(dimtype(a), dims)
@inline dimnum(dimtypes::Type, dims::AbstractArray) = dimnum(dimtypes, (dims...,))
@inline dimnum(dimtypes::Type, dim::Number) = dim
@inline dimnum(dimtypes::Type, dims::Tuple) =
    (dimnum(dimtypes, dims[1]), dimnum(dimtypes, tail(dims))...,)
@inline dimnum(dimtypes::Type, dims::Tuple{}) = ()
@inline dimnum(dimtypes::Type, dim::AbDim) = dimnum(dimtypes, typeof(dim))
@generated dimnum(dimtypes::Type{DTS}, dim::Type{D}) where {DTS,D} = begin
    index = findfirst(dt -> D <: basetype(dt), DTS.parameters)
    if index == nothing
        :(throw(ArgumentError("No $dim in $dimtypes")))
    else
        :($index)
    end
end


const UnitRangeOrTuple = Union{UnitRange,NTuple{2}}

"""
Format the dimension to match internal standards.

Mostily this means converting tuples and UnitRanges to LinRange,
which is easier to handle.

Errors are thrown if dims don't match the array dims or size.
"""
@inline formatdims(a::AbstractArray{T,N}, dims::Tuple) where {T,N} = begin
    dimlen = length(dims)
    dimlen == N || throw(ArgumentError("dims ($dimlen) don't match array dimensions $(N)"))
    formatdims(a, dims, 1)
end
@inline formatdims(a, dims::Tuple, n) =
    (formatdims(a, dims[1], n), formatdims(a, tail(dims), n + 1)...,)
@inline formatdims(a, dims::Tuple{}, n) = ()
@inline formatdims(a, dim::AbDim{<:AbstractArray}, n) =
    if length(val(dim)) == size(a, n)
        dim
    else
        throw(ArgumentError("length of $dim $(length(val(dim))) does not match size of array dimension $n $(size(a, n))"))
    end
@inline formatdims(a, dim::AbDim{<:UnitRangeOrTuple}, n) = linrange(dim, size(a, n))

linrange(dim, len) = begin
    range = val(dim)
    start, stop = first(range), last(range)
    basetype(dim)(LinRange(start, stop, len))
end


"""
Replace the specified dimensions with an index of 1 to match
a new array size where the dimension has been reduced to a length
of 1, but the number of dimensions has not changed.

Used in mean, reduce, etc.
"""
@inline reducedims(dim) = reducedims((dim,))
@inline reducedims(dims::Tuple) = map(d -> basetype(d)(1), dims)


# """
# Get the dimension(s) matching the type(s) of the lookup dimension.
# """
# @inline getdim(a::AbstractArray, lookup) = getdim(dims(a), dim)
# @inline getdim(dims::Dimensions, lookup::Tuple) =
#     (getdim(dims, lookup[1]), getdim(dims, tail(lookup))...)
# @inline getdim(dims::Dimensions, lookup::Tuple{}) = ()
# @inline getdim(dims::Dimensions, lookup::Integer) = dims[dim]
# @inline getdim(dims::Dimensions, dim) = getdim(dims, basetype(dim))
# @generated getdim(dims::DT, lookup::Type{L}) where {DT<:Dimensions,L} = begin
#     index = findfirst(dt -> dt <: L, DT.parameters)
#     if index == nothing
#         :(throw(ArgumentError("No $lookup in $dims")))
#     else
#         :(dims[$index])
#     end
# end