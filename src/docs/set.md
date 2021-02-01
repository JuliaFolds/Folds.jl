    Folds.set(collection; [executor_options...]) :: AbstractSet
    Folds.set(collection, executor) :: AbstractSet

Materialize `collection` as a set. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> pidigits = deleteat!([x - '0' for x in string(BigFloat(π; precision = 2^20))], 2);

julia> @show pidigits[1:5];
pidigits[1:5] = [3, 1, 4, 1, 5]

julia> sort!(collect(Folds.set(x for x in Iterators.partition(pidigits, 8) if issorted(x))))
8-element Array{SubArray{Int64,1,Array{Int64,1},Tuple{UnitRange{Int64}},true},1}:
 [0, 0, 1, 1, 4, 4, 4, 6]
 [0, 0, 1, 2, 2, 3, 7, 8]
 [0, 1, 1, 1, 3, 7, 8, 8]
 [0, 1, 3, 4, 5, 6, 6, 8]
 [1, 1, 5, 5, 8, 8, 8, 8]
 [3, 4, 9, 9, 9, 9, 9, 9]
 [4, 4, 5, 5, 6, 8, 8, 9]
 [5, 5, 5, 5, 8, 9, 9, 9]
```
