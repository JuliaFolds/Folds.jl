module TestMap

using Folds
using Test
include("utils.jl")

@testset begin
    @test Folds.map(identity, 1:10) == 1:10
    @test Folds.map(identity, reshape(1:6, 2, 3))::Matrix{Int} == reshape(1:6, 2, 3)
    @test Folds.map(tuple, 1:3, 4:6, 7:9) == collect(zip(1:3, 4:6, 7:9))
    @test Folds.map(identity, 1:10, SequentialEx()) == 1:10
    @test Folds.map(tuple, 1:3, 4:6, 7:9, SequentialEx()) == collect(zip(1:3, 4:6, 7:9))
    @test Folds.map(identity, reshape(1:6, 2, 3), SequentialEx())::Matrix{Int} ==
          reshape(1:6, 2, 3)
end

@testset "executor with keyword arguments" begin
    err = @test_error Folds.map(identity, 1:2, SequentialEx(); foo = :bar)
    @test "not accept any keyword arguments" ∈ᵉʳʳᵒʳ err
end

end  # module
