module TestReduce

# import Base as Folds  # should work (in Julia 1.7 and later)
using Folds
using Test

@testset "findmin & findmax" begin
    @test Folds.findmin('a':'z') == ('a', 1)
    @test Folds.findmax('a':'z') == ('z', 26)
    @test Folds.findmin(a -> 'z' - a, 'a':'z') == (0, 26)
    @test Folds.findmax(a -> 'z' - a, 'a':'z') == (25, 1)
end

@testset "argmin & argmax" begin
    @test Folds.argmin('a':'z') == 1
    @test Folds.argmax('a':'z') == 26
    @test Folds.argmin(a -> 'z' - a, 'a':'z') == 'z'
    @test Folds.argmax(a -> 'z' - a, 'a':'z') == 'a'
end

end  # module
