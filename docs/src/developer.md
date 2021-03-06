# For package developers

## Goals:

- Maximum extensibility: always use method dispatch. Regular types over special
  syntax. Recursion over @generated.
- Flexibility: dims and selectors are parametric types with multiple uses
- Abstraction: never dispatch on concrete types, maximum re-usability of methods
- Clean, readable syntax. Minimise required parentheses, minimise of exported
  methods, and instead extend Base methods whenever possible.
- Minimal interface: implementing a dimension-aware type should be easy.
- Functional style: structs are always rebuilt, and other than the array data,
  fields are not mutated in place.
- Least surprise: everything works the same as in Base, but with named dims. If
  a method accepts numeric indices or `dims=X` in base, you should be able to
  use DimensionalData.jl dims.
- Type stability: dimensional methods should be type stable _more often_ than Base methods
- Zero cost dimensional indexing `a[Y(4), X(5)]` of a single value.
- Low cost indexing for range getindex and views: these cant be zero cost as dim
  ranges have to be updated.
- Plotting is easy: data should plot sensibly and correctly with useful labels -
  after all transformations using dims or indices
- Prioritise spatial data: other use cases are a free bonus of the modular
  approach.

## Why this package

Why not [AxisArrays.jl](https://github.com/JuliaArrays/AxisArrays.jl) or
[NamedDims.jl](https://github.com/invenia/NamedDims.jl/)?

### Structure

Both AxisArrays and NamedDims use concrete types for dispatch on arrays, and for
dimension type `Axis` in AxisArrays. This makes them hard to extend.

Its a little easier with DimensionalData.jl. You can inherit from
`AbstractDimensionalArray`, or just implement `dims` and `rebuild` methods. Dims
and selectors in DimensionalData.jl are also extensible. Recursive primitive
methods allow inserting whatever methods you want to add extra types.
`@generated` is only used to match and permute arbitrary tuples of types, and
contain no type-specific details. The `@generated` functions in AxisArrays
internalise axis/index conversion behaviour preventing extension in external
packages and scripts.

### Syntax

AxisArrays.jl is verbose by default: `a[Axis{:y}(1)]` vs `a[Y(1)]` used here.
NamedDims.jl has concise syntax, but the dimensions are no longer types.


## Data types and the interface

DimensionalData.jl provides the concrete `DimenstionalArray` type. But it's
core purpose is to be easily used with other array types.

Some of the functionality in DimensionalData.jl will work without inheriting
from `AbstractDimensionalArray`. The main requirement define a `dims` method
that returns a `Tuple` of `AbstractDimension` that matches the dimension order
and axis values of your data. Define `rebuild`, and base methods for `similar`
and `parent` if you want the metadata to persist through transformations (see
the `DimensionalArray` and `AbstractDimensionalArray` types). A `refdims` method
returns the lost dimensions of a previous transformation, passed in to the
`rebuild` method. `refdims` can be discarded, the main loss being plot labels.

Inheriting from `AbstractDimensionalArray` will give all the functionality
of using `DimensionalArray`.
