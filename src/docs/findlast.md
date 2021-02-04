    Folds.findlast([f,] collection; [executor_options...])
    Folds.findlast([f,] collection, executor)

Find the last index containing `true` or, if `f` is given, an item that
evaluates to `true` by `f`. Parallel by default.

See _Extended help_ in [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds

julia> let s1 = string(BigFloat(π; precision = 2^20))[3:end],
           s2 = string(BigFloat(ℯ; precision = 2^20))[3:end],
           w = 4
           Folds.findlast(1:length(s1)-w; basesize = 10000) do i
               SubString(s1, i, i + w) == SubString(s2, i, i + w)
           end
       end
303001
```
