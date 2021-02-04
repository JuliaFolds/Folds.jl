    Folds.sum([f,] collection; [init,] [executor_options...])
    Folds.sum([f,] collection, executor; [init])

Compute `f(x₁) + f(x₂) + f(x₃) + ... + f(xₙ)` for the elements `xᵢ` in
`collection` with `f` defaults to `identity`. Parallel by default.

`init` should be an object that behaves like the identity of `+`.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Example

```julia
julia> using Folds

julia> f(x) = gcd(x, 42);

julia> Folds.sum(f, 1:1000_000)
4642844

julia> Folds.sum(f, 1:1000_000, SequentialEx())
4642844
```
