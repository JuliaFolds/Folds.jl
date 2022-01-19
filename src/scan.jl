Folds.scan!(op, xs; kwargs...) = Folds.scan!(op, xs, parallel_executor(xs; kwargs...))
Folds.scan!(op, xs, ex::PreferParallel) = Folds.scan!(op, xs, executor_for(xs, ex))

Folds.scan!(op, xs::AbstractArray, _::SequentialEx) =
    ThreadedScans.scan!(op, xs; basesize = typemax(Int))

Folds.scan!(op, xs::AbstractArray, ex::ThreadedEx) =
    ThreadedScans.scan!(op, xs; basesize = get_basesize(ex))

Folds.accumulate(op, xs; kwargs...) =
    Folds.accumulate(op, xs, parallel_executor(xs; kwargs...))
Folds.accumulate(op, xs, ex::PreferParallel) =
    Folds.accumulate(op, xs, executor_for(xs, ex))

Folds.accumulate(op, itr, _::SequentialEx) = Base.accumulate(op, itr)

# TODO: fuse `collect` and the first pass of `scan!`
function Folds.accumulate(op, itr, ex::ThreadedEx)
    xs = Folds.collect(itr, ex)
    Folds.scan!(op, xs, ex)
    return xs
end

Folds.accumulate!(op, ys, xs; kwargs...) =
    Folds.accumulate!(op, ys, xs, parallel_executor(xs; kwargs...))
Folds.accumulate!(op, ys, xs, ex::PreferParallel) =
    Folds.accumulate!(op, ys, xs, executor_for(xs, ex))

Folds.accumulate!(op, ys, xs, _::SequentialEx) = Base.accumulate!(op, ys, xs)

# TODO: fuse `map!` and the first pass of `scan!`
function Folds.accumulate!(op, ys, xs, ex::ThreadedEx)
    Folds.map!(identity, ys, xs, ex)
    Folds.scan!(op, ys, ex)
    return ys
end

Folds.cumsum(xs; kwargs...) = Folds.cumsum(xs, parallel_executor(xs; kwargs...))
Folds.cumsum(xs, ex::Executor) = Folds.accumulate(+, xs, ex)

Folds.cumsum!(ys, xs; kwargs...) = Folds.cumsum!(ys, xs, parallel_executor(xs; kwargs...))
Folds.cumsum!(ys, xs, ex::Executor) = Folds.accumulate!(+, ys, xs, ex)

Folds.cumprod(xs; kwargs...) = Folds.cumprod(xs, parallel_executor(xs; kwargs...))
Folds.cumprod(xs, ex::Executor) = Folds.accumulate(*, xs, ex)

Folds.cumprod!(ys, xs; kwargs...) = Folds.cumprod!(ys, xs, parallel_executor(xs; kwargs...))
Folds.cumprod!(ys, xs, ex::Executor) = Folds.accumulate!(*, ys, xs, ex)
