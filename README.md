# Folds: sequential, threaded, and distributed fold interface for Julia

Folds.jl provides a unified interface for sequential, threaded, and
distributed folds.

```julia
julia> using Folds

julia> fold(+, 1:10; threaded = true)
55

julia> sum(1:10, Folds.Scheduler(distributed = true))
55
```
