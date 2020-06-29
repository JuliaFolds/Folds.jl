# Folds: sequential, threaded, and distributed fold interface for Julia

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/Folds.jl/dev)
[![GitHub Actions](https://github.com/JuliaFolds/Folds.jl/workflows/Run%20tests/badge.svg)](https://github.com/JuliaFolds/Folds.jl/actions?query=workflow%3A%22Run+tests%22)

Folds.jl provides a unified interface for sequential, threaded, and
distributed folds.

```julia
julia> using Folds

julia> fold(+, 1:10; threaded = true)
55

julia> sum(1:10, Folds.Scheduler(distributed = true))
55
```
