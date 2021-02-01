module TestUtils
using Folds.Implementations: infer_eltype
using Test

@testset "infer_eltype" begin
    @test infer_eltype(1:10) == Int
    @test infer_eltype(string(x) for x in 1:10) == String
    @test infer_eltype(isodd(x) ? x : missing for x in 1:10) == Union{Int,Missing}
    @test infer_eltype(isodd(x) ? x : missing for x in (0, true)) == Union{Int,Bool,Missing}
end

end  # module
