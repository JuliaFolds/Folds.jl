function Folds.reduce(stat::OnlineStatsBase.OnlineStat, itr, ex::Executor; init = FoldsInit)
    ex isa SequentialEx || validate_reduce_ostat(stat)
    return Folds.reduce(reducingfunction(stat), itr, ex; init = init)
end

const OSNonZeroNObsError = ArgumentError(
    "An `OnlineStat` with one or more observations cannot be used with " *
    "non-`SequentialEx` executor.",
)

function validate_reduce_ostat(stat)
    if OnlineStatsBase.nobs(stat) != 0
        throw(OSNonZeroNObsError)
    end
    return stat
end
