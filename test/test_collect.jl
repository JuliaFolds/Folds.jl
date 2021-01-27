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
(x^2 for x in reshape(1:6, 2, 3))
((x, y) for x in 1:3, y in 1:4)                                         # nodist
((x, y) for x in 1:3 for y in 1:4)
((x, y) for x in 1:3, y in 1:4 if isodd(x))                             # nodist
"""

testdata_executors = map(split(raw_testdata_executors, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

tests = map(split(raw_testdata_iterables, "\n", keepempty = false)) do x
    if (m = match(r"^(.*?) *# *(.*?) *$", x)) !== nothing
        label = m[1]
        tags = map(Symbol, split(m[2], ","))
    else
        label = x
        tags = Symbol[]
    end
    (label = label, data = Base.include_string((@__MODULE__), x), tags = tags)
end

@testset "$elabel" for (elabel, ex) in testdata_executors
    @testset "$(t.label)" for t in tests
        :nodist ∈ t.tags && ex isa DistributedEx && continue
        itr = t.data
        @test Folds.collect(itr, ex)::Array == collect(itr)
    end
end

end  # module
