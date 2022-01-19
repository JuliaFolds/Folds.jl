    Folds.copy(T::Type, collection; [executor_options...]) :: T
    Folds.copy(T::Type, collection, executor) :: T

Materialize `collection` as a collection of type `T`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds, StructArrays

julia> Folds.copy(StructVector, ((x = x, y = x^2) for x in 1:3))
3-element StructArray(::Vector{Int64}, ::Vector{Int64}) with eltype NamedTuple{(:x, :y), Tuple{Int64, Int64}}:
 (x = 1, y = 1)
 (x = 2, y = 4)
 (x = 3, y = 9)
```
