module TestForeach

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

@testset "increment" begin
    @testset "default" begin
        xs = zeros(3)
        Folds.foreach(referenceable(xs)) do x
            x[] += 1
        end
        @test xs == ones(3)
    end
    @testset "$label" for (label, ex) in testdata_executors
        xs = zeros(3)
        Folds.foreach(referenceable(xs), ex) do x
            x[] += 1
        end
        @test xs == ones(3)
    end
end

@testset "DistributedEx should throw" begin
    xs = ones(3)
    err = @test_error Folds.foreach(identity, referenceable(xs), DistributedEx())
    @test "used with a referenceable" ∈ᵉʳʳᵒʳ err
end

end  # module
