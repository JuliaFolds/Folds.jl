    Folds.count([f,] collection; [executor_options...])
    Folds.count([f,] collection, executor)

Count the number of `true` items in `collection` or items that evaluates to
`true` by `f`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.count([true, true, false])
2

julia> Folds.count(gcd(x, 857142) == 1 for x in 1:10_000_000)
2721603
```
