# Folds: sequential, threaded, and distributed fold interface for Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliafolds.github.io/Folds.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/Folds.jl/dev)
[![GitHub Actions](https://github.com/JuliaFolds/Folds.jl/workflows/Run%20tests/badge.svg)](https://github.com/JuliaFolds/Folds.jl/actions?query=workflow%3A%22Run+tests%22)

**NOTE:** For information on the released version, please see
<https://juliafolds.github.io/Folds.jl/stable>

Folds.jl provides a unified interface for sequential, threaded, and
distributed folds.

```julia
julia> using Folds

julia> Folds.sum(1:10)
55

julia> Folds.sum(1:10, ThreadedEx())  # equivalent to above
55

julia> Folds.sum(1:10, DistributedEx())
55
```

Most of the functions can be used with iterator comprehensions:

```julia
julia> Folds.sum(y for x in 1:10 if isodd(x) for y in 1:x^2)
4917
```

and [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl):

```julia
julia> using Transducers

julia> 1:10 |> Filter(isodd) |> MapCat(x -> 1:x^2) |> Folds.sum
4917
```

Folds.jl decouples the implementation and the execution mechanism
("executor"). Additional executors can be installed from
[FoldsThreads.jl](https://github.com/JuliaFolds/FoldsThreads.jl),
[FoldsCUDA.jl](https://github.com/JuliaFolds/FoldsCUDA.jl) (rather WIP), and
[FoldsDagger.jl](https://github.com/JuliaFolds/FoldsDagger.jl) (very WIP)
