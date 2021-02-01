using Folds
using Folds.Testing: test_uses_threads
using Test

@testset "ThreadedEx(basesize = 1)" begin
    test_uses_threads(ThreadedEx(basesize = 1))
end

@testset "ThreadedEx()" begin
    test_uses_threads(ThreadedEx())
end
