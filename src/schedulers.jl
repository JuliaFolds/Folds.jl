const _SCHEDULER_KWARGS = """
- `sequential::$BoolFlag = false`: Whether or not to use left fold.
- `distributed::$BoolFlag = false`: Whether or not to use Distributed.jl.
- `threaded::$BoolFlag = !sequential`: Whether or not to use multi-threading.
- `ordered::$BoolFlag = true`: Whether or not to respect order; if `false`,
  assume that the reducing step function is commutative (and associative).
- `simd::$SIMDFlag = false`: Whether or not to use SIMD.
"""

"""
    Folds.Scheduler(; sequential, threaded, distributed, ordered, simd, kwargs...)

Schedule how folds are executed.  See [`fold`](@ref).

Currently, the default is `threaded = true`.  It is planned to detect
parallelizability by assuming the purity of user-defined functions.
Pass `sequential = true` or use [`Folds.foldl`](@ref) for sequential
fold.

# Keyword Arguments
$_SCHEDULER_KWARGS
"""
Folds.Scheduler

@noinline function mutually_exclusive_error(; kw...)
    @assert length(kw) == 2
    (k1, v1), (k2, v2) = kw
    v1 = _flagof(v1)
    v2 = _flagof(v2)
    throw(ArgumentError("`$k1=$v1` and `$k2=$v2` are mutually exclusive"))
end

function Folds.Scheduler(;
    simd::SIMDFlag = Val(false),
    sequential::BoolFlag = Val(false),
    distributed::BoolFlag = Val(false),
    threaded::BoolFlag = Val(!_flagof(sequential)),
    ordered::BoolFlag = Val(true),
    kwargs...,
)
    simd = _asval(simd)
    sequential = _asval(sequential)
    threaded = _asval(threaded)
    distributed = _asval(distributed)
    ordered = _asval(ordered)
    if distributed === Val(true)
        sequential === Val(true) &&
            mutually_exclusive_error(distributed = distributed, sequential = sequential)
        if ordered === Val(true)
            if threaded === Val(true)
                return Distributed(; simd = simd, kwargs...)
            else
                return Distributed(;
                    simd = simd,
                    threads_basesize = typemax(Int),
                    kwargs...,
                )
            end
        else
            throw(ArgumentError("combination of `distributed=true` and `ordered=false` is not supported"))
        end
    elseif threaded === Val(true)
        sequential === Val(true) &&
            mutually_exclusive_error(threaded = threaded, sequential = sequential)
        if ordered === Val(true)
            return Threaded(; simd = simd, kwargs...)
        else
            return ThreadedUnordered(; simd = simd, kwargs...)
        end
    else
        @assert sequential === Val(true)
        return Sequential(; simd = simd, kwargs...)
    end
end

struct Sequential{K} <: Scheduler
    kwargs::K
end
struct Threaded{K} <: Scheduler
    kwargs::K
end
struct ThreadedUnordered{K} <: Scheduler
    kwargs::K
end
struct Distributed{K} <: Scheduler
    kwargs::K
end

Sequential(; kw...) = Sequential(kw.data)
Threaded(; kw...) = Threaded(kw.data)
ThreadedUnordered(; kw...) = ThreadedUnordered(kw.data)
Distributed(; kw...) = Distributed(kw.data)
