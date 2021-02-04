    Folds.any([f,] collection; [executor_options...])
    Folds.any([f,] collection, executor)

Check if any of the elements in `collection`, optionally evaluated by `f`, is
`true`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.any([true, false, false])
true

julia> Folds.any([false, false, false])
false

julia> Folds.any(a/(b+c) + b/(a+c) + c/(a+b) < 3/2 for a in 1:100, b in 1:100, c in 1:100)
false
```
