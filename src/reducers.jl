Base.sum(f, xs, sch::Scheduler; kw...) = Folds.fold(Base.add_sum, Map(f), xs, sch; kw...)
Base.sum(xs, sch::Scheduler; kw...) =
    Folds.fold(Base.add_sum, IdentityTransducer(), xs, sch; kw...)

Base.collect(xs, sch::Scheduler; kw...) = _collect(xs, sch::Scheduler; kw...)
Base.collect(::Transducer, ::Scheduler) =
    throw(ArgumentError("invalid method `collect(::Transducer, ::Scheduler)`"))
Base.collect(::Type, ::Scheduler) =
    throw(ArgumentError("invalid method `collect(::Type, ::Scheduler)`"))

_rm_simd(; simd = nothing, kw...) = kw   # TODO: don't

_collect(xs, sch::Sequential; kw...) =
    collect(extract_transducer(xs)...; _rm_simd(; sch.kwargs...)..., kw...)
_collect(xs, sch::Threaded; kw...) =
    tcollect(extract_transducer(xs)...; _rm_simd(; sch.kwargs...)..., kw...)
_collect(xs, sch::ThreadedUnordered; kw...) = collect(channel_unordered(
    extract_transducer(xs)...;
    _rm_simd(; sch.kwargs...)...,
    kw...,
))
_collect(xs, sch::Distributed; kw...) =
    dcollect(extract_transducer(xs)...; _rm_simd(; sch.kwargs...)..., kw...)
