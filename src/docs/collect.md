    Folds.collect(collection; [executor_options...]) :: AbstractArray
    Folds.collect(collection, executor) :: AbstractArray

Materialize `collection` as an array. Parallel by default.

Iterator transformations such as `(f(x) for x in xs if p(x))` wrapping
parallelizable container(s) `xs` are executed in parallel. See _Extended
help_ in [`Folds.reduce`](@ref) for more information.

Unlike `Base.collect`, the output can be an array of type other than `Array`.

# Examples

```julia
julia> using Folds

julia> Folds.collect(x^2 for x in 1:4 if isodd(x))
2-element Vector{Int64}:
 1
 9

julia> Folds.collect(i for i in 1:10_000_000 if sin(i) > 1 - 1e-12)
4-element Vector{Int64}:
  573204
 4846147
 7138963
 9119090
```
