    Folds.prod([f,] collection; [init,] [executor_options...])
    Folds.prod([f,] collection, executor; [init])

Compute `f(x₁) * f(x₂) * f(x₃) * ... * f(xₙ)` for the elements `xᵢ` in
`collection` with `f` defaults to `identity`. Parallel by default.

`init` should be an object that behaves like the identity of `*`.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.prod(1:5)
120

julia> floor(Folds.prod(1 + (sin(n) + 1)/10_000_000 for n in 1:10_000_000); digits = 3)
2.718
```
