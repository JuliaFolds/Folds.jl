module TestTransducers

using Transducers
using Folds.Testing: parse_tests, test_with_sequential

length_partition_by(f) = ReducePartitionBy(f, Map(_ -> 1)'(+), 0)
length_partition_by(f, xs) = length_partition_by(f)(xs)

divby(y) = x -> x ÷ y

rawdata = """
maximum(length_partition_by(divby(8), 1:10))
maximum(length_partition_by(divby(8), 5:19))
extrema(length_partition_by(divby(8), 1:10))
extrema(length_partition_by(divby(8), 5:19))
reduce(TeeRF(min, max), 1:10)
reduce(TeeRF(min, max), (2x for x in 1:10))
reduce(TeeRF(min, max), (2x for x in 1:10 if isodd(x)))
"""

tests = parse_tests(rawdata, @__MODULE__)

test_with_sequential(tests, [
    SequentialEx(),
    ThreadedEx(),
    ThreadedEx(basesize = 1),
])

end  # module
