module TestCopy

using Folds
using Folds.Testing: eval_call_data, test_with_sequential
using Test
using Transducers: DistributedEx, PreferParallel, SequentialEx, ThreadedEx

preamble = quote
    using DataFrames: DataFrame
    using StructArrays: StructVector
end

rawdata = """
copy(StructVector, ((x = x, y = x^2) for x in 1:10))
copy(StructVector, ((x = x, y = x^2) for x in 1:10 if isodd(x)))
copy(DataFrame, ((x = x, y = x^2) for x in 1:10))
copy(DataFrame, ((x = x, y = x^2) for x in 1:10 if isodd(x)))
"""

tests = eval_call_data(rawdata, preamble)
executors = [
    SequentialEx(),
    ThreadedEx(),
    ThreadedEx(basesize = 1),
    DistributedEx(),
    DistributedEx(basesize = 1),
    PreferParallel(),
    PreferParallel(basesize = 1),
]

test_with_sequential(tests, executors)

end  # module
