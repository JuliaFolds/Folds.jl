"""
    Folds.foldl(rf, [xf,] collection; [init, simd])
    Folds.reduce(rf, [xf,] collection; [init, simd, basesize])

Left fold and threaded reduce based on Transducers.jl.

# Arguments
- `rf`: A reducing step function `(acc, x) -> acc′`.
- `xf::Transducer`: A transducer.
- `collection`: An array, dictionary, iterator, etc.
- `init`: An initial value fed to the first argument to reducing step
  function `step`.  This argument can be omitted for well know binary
  operations like `+` or `*`.  Supported binary operations are listed
  in InitialValues.jl documentation.
- `simd`: If `true` or `:ivdep`, enable SIMD using `Base.@simd`.  If
  `:ivdep`, use `@simd ivdep for ... end` variant.  Read Julia manual
  of `Base.@simd` to understand when it is appropriate to use this
  option.  This option has no effect if `false` (default).
- `basesize::Integer = amount(reducible) ÷ nthreads()`: A size of
  chunk in `reducible` that is processed by each worker.  A smaller
  size may be required when:
    * computation time for processing each item fluctuates a lot
    * computation can be terminated by `reduced` API.
"""
(Folds.foldl, Folds.reduce)

Folds.foldl(rf, xf::Transducer, xs; kw...) = foldl(rf, xf, xs; kw...)
Folds.foldl(rf, xs::Foldable; kw...) = foldl(rf, xs; kw...)
Folds.foldl(rf, xs; kw...) = foldl(rf, IdentityTransducer(), xs; kw...)

Folds.reduce(rf, xf::Transducer, xs; kw...) = reduce(rf, xf, xs; kw...)
Folds.reduce(rf, xs::Foldable; kw...) = reduce(rf, xs; kw...)
Folds.reduce(rf, xs; kw...) = reduce(rf, IdentityTransducer(), xs; kw...)

"""
    Folds.append!([xf,] dest, src)

Like `Base.append!` but optimized for `append!(dest, src::Foldable)`
including `append!(dest, src::Eduction)`.
"""
Folds.append!
Folds.append!(dest, src) = append!(dest, src)  # fallback
Folds.append!(xf::Transducer, dest, src) = append!(xf, dest, src)
function Folds.append!(dest, src::Foldable)
    xf, from = extract_transducer(src)
    return append!(xf, dest, from)
end

"""
    fold(rf, [xf,] collection; [init], scheduler_options...)
    fold(rf, [xf,] collection, scheduler; [init])

Generic entry point for various fold implementations.

See [`Folds.Scheduler`](@ref) for how to construct `scheduler`.
Keyword arguments `scheduler_options` are passed `Folds.Scheduler`.

# Keyword Arguments
- `init`: An initial value fed to the first argument to reducing step
  function `step`.
$_SCHEDULER_KWARGS

# Examples
```jldoctest
julia> using Folds

julia> xs = 1:10;

julia> fold(+, xs)  # DWIM (threaded)
55

julia> fold(+, xs; sequential = true, simd = true)
55

julia> fold(+, xs; threaded = true)
55

julia> fold(+, xs; distributed = true)  # `threaded = true` implied
55

julia> fold(+, xs; distributed = true, threaded = false)
55

julia> fold(+, xs, Folds.Scheduler(distributed = true, threaded = false))  # equivalent
55
```
"""
Folds.fold

Folds.fold(rf, xs; kw...) = Folds.fold(rf, IdentityTransducer(), xs; kw...)

Folds.fold(rf, xf::Transducer, xs; kw...) = Folds.fold(rf, xf, xs, Scheduler(; kw...))

# To resolve ambiguity:
Folds.fold(rf, ::Transducer, ::Scheduler; kw...) =
    throw(ArgumentError("invalid method `fold(rf, ::Transducer, ::Scheduler)`"))

Folds.fold(rf, xs, sch::Scheduler; kw...) =
    Folds.fold(rf, IdentityTransducer(), xs, sch; kw...)

Folds.fold(rf, xf::Transducer, xs, sch::Sequential; kw...) =
    Folds.foldl(rf, xf, xs; sch.kwargs..., kw...)

Folds.fold(rf, xf::Transducer, xs, sch::Threaded; kw...) =
    Folds.reduce(rf, xf, xs; sch.kwargs..., kw...)

Folds.fold(rf, xf::Transducer, xs, sch::ThreadedUnordered; kw...) =
    reduce_commutative(rf, xf, xs; sch.kwargs..., kw...)

Folds.fold(rf, xf::Transducer, xs, sch::Distributed; kw...) =
    dreduce(rf, xf, xs; sch.kwargs..., kw...)
