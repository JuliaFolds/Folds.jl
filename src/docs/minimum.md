    Folds.maximum([f,] collection; [executor_options...])
    Folds.maximum([f,] collection, executor)

Compute the maximum of the items in `collection`, optionally evaluated by
`f`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.minimum([4, 8, 3, 5, 5])
3

julia> Folds.minimum(xor(i, (i + one(i))^i) for i in UInt32(1):UInt32(10_000_000))
0x00000003
```
