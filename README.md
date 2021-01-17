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
