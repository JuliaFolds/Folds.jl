module TestWithSequential

using Transducers: DistributedEx, SequentialEx, ThreadedEx
using Folds.Testing: test_with_sequential, eval_call_data

executors = [
    SequentialEx(),
    ThreadedEx(),
    ThreadedEx(basesize = 1),
    DistributedEx(),
    DistributedEx(basesize = 1),
]

test_with_sequential(executors)


raw_extra_testdata = """
reduce(Mean(), 1:10)
reduce(Mean(), (x for x in 1:10 if isodd(x)))
reduce(KHist(25), 1.0:10.0)
"""

preamble = quote
    using OnlineStats
end

extra_testdata = eval_call_data(raw_extra_testdata, preamble)

test_with_sequential(extra_testdata, executors)

end
