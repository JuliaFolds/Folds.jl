    Folds.map(f, collections...; [executor_options...])
    Folds.map(f, collections..., executor)

Equivalent to `Folds.collect(f(x...) for x in zip(collections...))`. Parallel
by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.map(+, 1:3, 2:2:6)
3-element Vector{Int64}:
 3
 6
 9

julia> Folds.map(i -> floor(Int, i / π), (i for i in 1:10_000_000 if sin(i) > 1 - 1e-12))
4-element Vector{Int64}:
  182456
 1542576
 2272402
 2902696
```
