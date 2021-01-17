module TestWithSequential

using Transducers: DistributedEx, SequentialEx, ThreadedEx
using Folds.Testing: test_with_sequential

test_with_sequential([
    SequentialEx(),
    ThreadedEx(),
    ThreadedEx(basesize = 1),
    DistributedEx(),
    DistributedEx(basesize = 1),
])

end
