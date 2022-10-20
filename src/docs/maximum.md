    Folds.maximum([f,] collection; [executor_options...])
    Folds.maximum([f,] collection, executor)

Compute the maximum of the items in `collection`, optionally evaluated by
`f`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.maximum([4, 8, 3, 5, 5])
8

julia> Folds.maximum(xor(i, (i + one(i))^i) for i in UInt32(1):UInt32(10_000_000))
0xfffffa3d
```
