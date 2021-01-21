Folds.collect(itr; kwargs...) = Folds.collect(itr, parallel_executor(itr; kwargs...))

Folds.collect(itr, ex::PreferParallel) = Folds.collect(itr, executor_for(itr, ex))
Folds.collect(itr, ex::SequentialEx) = collect(extract_transducer(itr)...; ex.kwargs...)
Folds.collect(itr, ex::ThreadedEx) = tcollect(extract_transducer(itr)...; ex.kwargs...)
Folds.collect(itr, ex::DistributedEx) = dcollect(extract_transducer(itr)...; ex.kwargs...)

# TODO: generalize this to arbitrary container
Folds.collect(itr, ex::Executor) =
    finish!(unreduced(transduce(
        Map(SingletonVector),
        wheninit(collector, append!!),
        collector(),
        itr,
        ex,
    )))

function as_copy_args(T, itr)
    xf, coll = extract_transducer(itr)
    return (xf, T, coll)
end

Folds.copy(T, itr; kwargs...) = Folds.copy(T, itr, parallel_executor(itr; kwargs...))

Folds.copy(T, itr, ex::SequentialEx) = copy(as_copy_args(T, itr)...; ex.kwargs...)
Folds.copy(T, itr, ex::ThreadedEx) = tcopy(as_copy_args(T, itr)...; ex.kwargs...)
Folds.copy(T, itr, ex::DistributedEx) = dcopy(as_copy_args(T, itr)...; ex.kwargs...)
