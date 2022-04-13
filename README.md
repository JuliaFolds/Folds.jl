# Folds: sequential, threaded, and distributed fold interface for Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliafolds.github.io/Folds.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/Folds.jl/dev)
[![CI](https://github.com/JuliaFolds/Folds.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaFolds/Folds.jl/actions/workflows/ci.yml)

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

### Iterator transforms and transducers

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

### Package interop

Folds.jl interoperates with various packages. For example,
[StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl) can be used as
an input and/or output:

```julia
julia> using StructArrays

julia> table = StructVector(
           x = [:a, :a, :b, :a, :b],
           y = [1, 2, 3, 4, 5],
       );

julia> Folds.copy(StructVector, (row for row in table if row.x === :a))
3-element StructArray(::Vector{Symbol}, ::Vector{Int64}) with eltype NamedTuple{(:x, :y), Tuple{Symbol, Int64}}:
 (x = :a, y = 1)
 (x = :a, y = 2)
 (x = :a, y = 4)
```

It also works with [OnlineStats.jl](https://github.com/joshday/OnlineStats.jl)
by treating it as a reducing function (or more precisely a monoid):

```julia
julia> using OnlineStats

julia> Folds.reduce(Mean(), 1:10)
Mean: n=10 | value=5.5
```

### Extensible execution mechanism

Folds.jl decouples the implementation and the execution mechanism
("executor"). Additional executors can be installed from
[FoldsThreads.jl](https://github.com/JuliaFolds/FoldsThreads.jl),
[FoldsCUDA.jl](https://github.com/JuliaFolds/FoldsCUDA.jl) (rather WIP), and
[FoldsDagger.jl](https://github.com/JuliaFolds/FoldsDagger.jl) (very WIP).
