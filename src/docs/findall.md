    Folds.findall([f,] collection; [executor_options...])
    Folds.findall([f,] collection, executor)

Find all indices for which the item is `true` or evaluates to `true` by `f`.
Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> let pidigits = string(BigFloat(π; precision = 2^20))[3:end]
           Folds.findall(1:length(pidigits)) do i
               startswith(SubString(pidigits, i), string(i))
           end
       end
3-element Vector{Int64}:
     1
 16470
 44899
```
