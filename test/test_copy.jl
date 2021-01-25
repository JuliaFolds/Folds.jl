module TestCopy

using DataFrames: DataFrame
using Folds
using Folds.Testing: parse_tests, test_with_sequential
using StructArrays: StructVector
using Test
using Transducers: DistributedEx, PreferParallel, SequentialEx, ThreadedEx

rawdata = """
copy(StructVector, ((x = x, y = x^2) for x in 1:10))
copy(StructVector, ((x = x, y = x^2) for x in 1:10 if isodd(x)))
copy(DataFrame, ((x = x, y = x^2) for x in 1:10))
copy(DataFrame, ((x = x, y = x^2) for x in 1:10 if isodd(x)))
"""

tests = parse_tests(rawdata, @__MODULE__)
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
