Base.sum(f, xs, sch::Scheduler; kw...) = Folds.fold(Base.add_sum, Map(f), xs, sch; kw...)
Base.sum(xs, sch::Scheduler; kw...) =
    Folds.fold(Base.add_sum, IdentityTransducer(), xs, sch; kw...)
