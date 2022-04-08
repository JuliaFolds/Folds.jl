module TestReduce

using Folds
using Test

@testset "findmin & findmax" begin
    # Folds = Base  # should work (in Julia 1.7 and later)
    @test Folds.findmin('a':'z') == ('a', 1)
    @test Folds.findmax('a':'z') == ('z', 26)
    @test Folds.findmin(a -> 'z' - a, 'a':'z') == (0, 26)
    @test Folds.findmax(a -> 'z' - a, 'a':'z') == (25, 1)
end

@testset "argmin & argmax" begin
    # Folds = Base  # should work (in Julia 1.7 and later)
    @test Folds.argmin('a':'z') == 1
    @test Folds.argmax('a':'z') == 26
    @test Folds.argmin(a -> 'z' - a, 'a':'z') == 'z'
    @test Folds.argmax(a -> 'z' - a, 'a':'z') == 'a'
end

@testset "dict" begin
    @test Folds.dict(x => x^2 for x in 1:10) ==
          Folds.dict([x => x^2 for x in 1:10]) ==
          Dict(x => x^2 for x in 1:10)
end

end  # module
