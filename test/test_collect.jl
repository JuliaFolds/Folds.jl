module TestCollect

using Folds: Scheduler
using Test

raw_testdata_schedulers = """
Scheduler()
Scheduler(sequential = true)
Scheduler(threaded = true)
Scheduler(threaded = true, basesize = 1)
Scheduler(distributed = true)
Scheduler(distributed = true, basesize = 1)
Scheduler(distributed = true, threaded = false)
Scheduler(distributed = true, threaded = false, basesize = 1)
"""

raw_testdata_iterables = """
(x^2 for x in 1:10)
(x^2 for x in 1:10 if isodd(x))
(y for x in 1:10 if isodd(x) for y in 1:x^2)
"""

testdata_schedulers = map(split(raw_testdata_schedulers, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

testdata_iterables = map(split(raw_testdata_iterables, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

@testset "$slabel" for (slabel, sch) in testdata_schedulers
    @testset "$ilabel" for (ilabel, itr) in testdata_iterables
        @test collect(itr, sch) == collect(itr)
    end
end

end  # module
