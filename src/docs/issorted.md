    Folds.issorted(collection; [lt,] [by,] [rev,] [order,] [executor_options...])
    Folds.issorted(collection, executor; [lt,] [by,] [rev,] [order,])

Check if `collection` is sorted. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.issorted(0:9)
true

julia> Folds.issorted([0:1000_0000; [0]])
false
```
