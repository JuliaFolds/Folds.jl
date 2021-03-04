    Folds.map!(f, dest, collections...; [executor_options...]) -> dest
    Folds.map!(f, dest, collections..., executor) -> dest

Equivalent to `dest .= f.(collections...)`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> Folds.map!(+, zeros(Int, 3), 1:3, 2:2:6)
3-element Array{Int64,1}:
 3
 6
 9

julia> Folds.map!(sin, Vector{Float64}(undef, 2^20), 1:2^20);
```
