    Folds.scan!(op, xs; [executor_options...]) -> xs
    Folds.scan!(op, xs, executor) -> xs

Inclusive in-place scan.

`Folds.scan!(⊗, xs)` computes

    [xs[1], xs[1] ⊗ xs[2], xs[1] ⊗ xs[2] ⊗ xs[3], ...]

stores the result in `xs`, and returns `xs`.

# Examples

```julia
julia> using Folds

julia> Folds.scan!(+, [1, 2, 3])
3-element Vector{Int64}:
 1
 3
 6
```
