    Folds.unique([f,] collection; [executor_options...])
    Folds.unique([f,] collection, executor)

List the unique elements from `collection` in the order that appears in
`collection`. If `f` given, the uniqueness is determined by comparing its
output. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.unique([2, 4, 3, 0, 0, 4, 3, 4, 3, 1, 0, 0, 4, 1, 4, 1, 3, 3, 4, 0])
5-element Array{Int64,1}:
 2
 4
 3
 0
 1

julia> pidigits = deleteat!([x - '0' for x in string(BigFloat(π; precision = 2^20))], 2);

julia> @show pidigits[1:5];
pidigits[1:5] = [3, 1, 4, 1, 5]

julia> Folds.unique(x for x in pidigits if isodd(x))
5-element Array{Int64,1}:
 3
 1
 5
 9
 7
```
