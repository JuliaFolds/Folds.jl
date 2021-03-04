module TestInplaceMap

using Folds
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

@testset "increment" begin
    @testset "default" begin
        xs = Vector(1:3)
        ys = similar(xs)
        Folds.map!(identity, ys, xs)
        @test xs == 1:3
    end
    @testset "$label" for (label, ex) in testdata_executors
        xs = Vector(1:3)
        ys = similar(xs)
        Folds.map!(identity, ys, xs, ex)
        @test xs == 1:3
    end
end

@testset "DistributedEx should throw" begin
    xs = ones(3)
    ys = similar(xs)
    err = @test_error Folds.map!(identity, ys, xs, DistributedEx())
    @test "used with a referenceable" ∈ᵉʳʳᵒʳ err
end

end  # module
