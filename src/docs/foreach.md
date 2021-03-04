    Folds.foreach(f, collections...; [executor_options...])
    Folds.foreach(f, collections..., executor)

Call `f` on the elements of `collections` in parallel.

This is equivalent to

```Julia
for x in zip(collections...)
    f(x...)
end
```

except that `f` may be applied in parallel and in unspecified order.

[Referenceables.jl](https://github.com/tkf/Referenceables.jl) can be used to
update the elements in (a subset of) `collections`.

See [`Folds.reduce`](@ref) for more information.

# Examples

```julia
julia> using Folds, Referenceables

julia> xs = 1:2^20;

julia> ys = ones(length(xs));

julia> Folds.foreach(referenceable(ys), xs) do y, x
           y[] = sin(y[] * x)
       end
```
