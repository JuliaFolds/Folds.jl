module TestCollect

using Folds
using Transducers: PreferParallel
using Test

raw_testdata_executors = """
PreferParallel()
SequentialEx()
ThreadedEx()
ThreadedEx(basesize = 1)
DistributedEx()
DistributedEx(basesize = 1)
DistributedEx(threads_basesize = 1)
DistributedEx(threads_basesize = 1, basesize = 1)
"""

raw_testdata_iterables = """
(x^2 for x in 1:10)
(x^2 for x in 1:10 if isodd(x))
(y for x in 1:10 if isodd(x) for y in 1:x^2)
"""

testdata_executors = map(split(raw_testdata_executors, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

testdata_iterables = map(split(raw_testdata_iterables, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

@testset "$elabel" for (elabel, ex) in testdata_executors
    @testset "$ilabel" for (ilabel, itr) in testdata_iterables
        @test Folds.collect(itr, ex) == collect(itr)
    end
end

end  # module
