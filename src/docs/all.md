    Folds.all([f,] collection; [executor_options...])
    Folds.all([f,] collection, executor)

Check if all the elements in `collection`, optionally evaluated by `f`, are
`true`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.all([true, true, true])
true

julia> Folds.all([true, true, false])
false

julia> Folds.all(n -> (ℯ * (n/ℯ)^n ≤ factorial(n)), (big(n) for n in 1:100))
true
```
