    Folds.mapreduce(f, op, collections...; [init] [executor_options...])
    Folds.mapreduce(f, op, collections..., executor; [init])

Equivalent to `Folds.reduce(op, (f(x...) for x in zip(collections...)))`.

See [`Folds.reduce`](@ref) for more information.
