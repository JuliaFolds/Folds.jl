module TestScan

using Folds
using Referenceables
using Test
using Transducers: PreferParallel
include("utils.jl")

raw_testdata_executors = """
PreferParallel()
SequentialEx()
ThreadedEx()
ThreadedEx(basesize = 1)
"""

testdata_executors = map(split(raw_testdata_executors, "\n", keepempty = false)) do x
    x => Base.include_string((@__MODULE__), x)
end

@testset "scan!" begin
    @testset "default" begin
        xs = [1:3;]
        @test Folds.scan!(+, xs) === xs == cumsum(1:3)
    end
    @testset "$label" for (label, ex) in testdata_executors
        xs = [1:3;]
        @test Folds.scan!(+, xs, ex) === xs == cumsum(1:3)
    end
end

@testset "default" begin
    @test Folds.cumsum(1:3) == cumsum(1:3)
    @test Folds.cumprod(1:3) == cumprod(1:3)
    @test Folds.accumulate(max, 1:3) == accumulate(max, 1:3)

    ys = zeros(Int, 3)
    @test Folds.cumsum!(ys, 1:3) === ys == cumsum(1:3)

    ys = zeros(Int, 3)
    @test Folds.cumprod!(ys, 1:3) === ys == cumprod(1:3)
end

end  # module
